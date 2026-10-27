import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:get/get.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'package:toefl_pro/app/routes/app_routes.dart';

/// Runs in a separate isolate when an FCM message arrives while the app is
/// in the background or terminated.
///
/// - Messages WITH a `notification` block: Android shows them itself when the
///   app is terminated and may not call this handler at all.
/// - Messages that are DATA-ONLY (`title` and `body` inside `data`): this
///   handler always runs, shows the notification and saves it to the inbox.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  final title = (message.data['title'] as String?) ??
      message.notification?.title ??
      'TOEFL Practice';
  final body = (message.data['body'] as String?) ??
      message.notification?.body ??
      '';

  // Data-only message: the system will not show anything, so we do it.
  if (message.notification == null && (title.isNotEmpty || body.isNotEmpty)) {
    final local = FlutterLocalNotificationsPlugin();
    await local.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
    );
    await local.show(
      id: (message.messageId ?? title).hashCode & 0x7FFFFFFF,
      title: title,
      body: body,
      notificationDetails: NotificationService.details,
      payload: 'fcm',
    );
  }

  await NotificationService._saveInBackground(
    id: message.messageId,
    title: title,
    body: body,
  );
}

class NotificationService extends GetxService with WidgetsBindingObserver {
  static NotificationService get to => Get.find();

  static const _reminderId = 1001;
  static const _channelId = 'study_reminder';

  final _local = FlutterLocalNotificationsPlugin();
  final _fcm = FirebaseMessaging.instance;
  final _db = FirebaseFirestore.instance;

  bool openInboxOnStart = false;
  bool _syncing = false;

  /// Public so the background handler can use it too.
  static const details = NotificationDetails(
    android: AndroidNotificationDetails(
      _channelId,
      'Study reminders',
      channelDescription: 'Daily TOEFL practice reminders and updates',
      importance: Importance.high,
      priority: Priority.high,
    ),
    iOS: DarwinNotificationDetails(),
  );

  AndroidFlutterLocalNotificationsPlugin? get _android =>
      _local.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

  // ───────────── Init ─────────────
  Future<NotificationService> init() async {
    tzdata.initializeTimeZones();
    try {
      final dynamic r = await FlutterTimezone.getLocalTimezone();
      final String name = r is String ? r : r.identifier as String;
      tz.setLocalLocation(tz.getLocation(name));
    } catch (e) {
      debugPrint('Time zone lookup failed: $e');
      _fallbackTimezone();
    }
    debugPrint('Local time zone: ${tz.local.name}');

    await _local.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: _onTap,
    );

    // Make sure the high-importance channel exists (Android 8+)
    await _android?.createNotificationChannel(const AndroidNotificationChannel(
      _channelId,
      'Study reminders',
      description: 'Daily TOEFL practice reminders and updates',
      importance: Importance.high,
    ));

    final launch = await _local.getNotificationAppLaunchDetails();
    if (launch?.didNotificationLaunchApp ?? false) {
      openInboxOnStart = true;
    }

    await _fcm.setForegroundNotificationPresentationOptions(
        alert: true, badge: true, sound: true);

    FirebaseMessaging.onMessage.listen(_onForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen((m) async {
      await _saveRemoteMessage(m);
      Get.toNamed(Routes.notifications);
    });
    final initial = await _fcm.getInitialMessage();
    if (initial != null) {
      await _saveRemoteMessage(initial);
      openInboxOnStart = true;
    }

    _fcm.onTokenRefresh.listen((_) => syncToken());
    FirebaseAuth.instance.authStateChanges().listen((u) {
      if (u != null) {
        syncToken();
        syncInbox();
        restoreReminder();
      }
    });

    // Re-sync every time the app comes back to the foreground
    WidgetsBinding.instance.addObserver(this);

    syncToken();
    syncInbox();
    restoreReminder();
    return this;
  }

  /// If the time zone lookup fails, pick a zone with the same UTC offset
  /// instead of silently staying on UTC (which fires reminders hours off).
  void _fallbackTimezone() {
    final offset = DateTime.now().timeZoneOffset;
    final nowUtc = DateTime.now().toUtc();
    for (final loc in tz.timeZoneDatabase.locations.values) {
      if (!loc.name.contains('/')) continue;
      if (tz.TZDateTime.from(nowUtc, loc).timeZoneOffset == offset) {
        tz.setLocalLocation(loc);
        return;
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      syncInbox();
      // Also upgrades to exact alarms after the user grants the permission
      restoreReminder();
    }
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  // ───────────── Permission ─────────────
  Future<bool> ensurePermission({bool ask = true}) async {
    var s = await _fcm.getNotificationSettings();
    if (s.authorizationStatus == AuthorizationStatus.notDetermined && ask) {
      s = await _fcm.requestPermission();
    }
    final fcmOk = s.authorizationStatus == AuthorizationStatus.authorized ||
        s.authorizationStatus == AuthorizationStatus.provisional;

    final android = _android;
    if (android != null) {
      // Android: trust the real OS state (Android 13+ POST_NOTIFICATIONS)
      var enabled = await android.areNotificationsEnabled() ?? fcmOk;
      if (!enabled && ask) {
        enabled = await android.requestNotificationsPermission() ?? false;
      }
      return enabled;
    }
    return fcmOk;
  }

  // ═════════════ Daily reminder ═════════════
  Future<AndroidScheduleMode> _scheduleMode({bool ask = true}) async {
    final android = _android;
    if (android == null) return AndroidScheduleMode.inexactAllowWhileIdle;

    var can = await android.canScheduleExactNotifications() ?? false;
    if (!can && ask) {
      // Opens Settings → "Alarms & reminders" for this app
      await android.requestExactAlarmsPermission();
      can = await android.canScheduleExactNotifications() ?? false;
    }
    return can
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;
  }

  Future<void> _zonedSchedule({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime when,
    required AndroidScheduleMode mode,
    required String payload,
    DateTimeComponents? repeat,
  }) async {
    Future<void> go(AndroidScheduleMode m) => _local.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: when,
      notificationDetails: details,
      androidScheduleMode: m,
      matchDateTimeComponents: repeat,
      payload: payload,
    );
    try {
      await go(mode);
    } catch (e) {
      // e.g. exact alarms revoked in the meantime → fall back to inexact
      debugPrint('Exact schedule failed ($e), using inexact');
      await go(AndroidScheduleMode.inexactAllowWhileIdle);
    }
  }

  /// Returns false if notification permission is missing.
  Future<bool> scheduleDailyReminder(TimeOfDay time,
      {bool ask = true}) async {
    if (!await ensurePermission(ask: ask)) {
      debugPrint('Reminder NOT scheduled: notification permission denied');
      return false;
    }

    final mode = await _scheduleMode(ask: ask);

    final now = tz.TZDateTime.now(tz.local);
    var when = tz.TZDateTime(
        tz.local, now.year, now.month, now.day, time.hour, time.minute);
    if (!when.isAfter(now)) when = when.add(const Duration(days: 1));

    await _zonedSchedule(
      id: _reminderId,
      title: 'Time to practise 📚',
      body: 'Your daily TOEFL practice is waiting. Keep your streak going!',
      when: when,
      mode: mode,
      payload: 'reminder',
      repeat: DateTimeComponents.time,
    );

    final pending = await _local.pendingNotificationRequests();
    debugPrint('Reminder scheduled for $when ($mode) tz=${tz.local.name}. '
        'Pending: ${pending.length}');
    return true;
  }

  /// Re-creates the saved reminder. Runs on app start, on resume and after
  /// sign-in, so a cleared alarm (reboot, app update, permission change)
  /// comes back.
  Future<void> restoreReminder() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      final d = (await _db.collection('users').doc(uid).get()).data();
      if (d?['reminderEnabled'] != true) return;
      final h = d?['reminderHour'];
      final m = d?['reminderMinute'];
      if (h is int && m is int) {
        await scheduleDailyReminder(TimeOfDay(hour: h, minute: m), ask: false);
      }
    } catch (e) {
      debugPrint('Restore reminder failed: $e');
    }
  }

  Future<void> cancelReminder() => _local.cancel(id: _reminderId);

  /// Debug helper: fires one notification in 1 minute (closed-app testing)
  Future<void> scheduleTestInOneMinute() async {
    if (!await ensurePermission()) return;
    final mode = await _scheduleMode();
    final when = tz.TZDateTime.now(tz.local).add(const Duration(minutes: 1));
    await _zonedSchedule(
      id: 1002,
      title: 'Closed-app test ⏰',
      body: 'This arrived while the app was closed.',
      when: when,
      mode: mode,
      payload: 'test',
    );
    debugPrint('Test scheduled for $when ($mode)');
  }

  // ───────────── Instant test notification ─────────────
  Future<void> showTest() async {
    await _local.show(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: 'Test notification ✅',
      body: 'Notifications are working on this device.',
      notificationDetails: details,
      payload: 'test',
    );
    await addToInbox(
      title: 'Test notification ✅',
      body: 'Notifications are working on this device.',
      type: 'test',
    );
  }

  // ───────────── FCM token ─────────────
  Future<void> syncToken() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      final token = await _fcm.getToken();
      if (token == null) return;
      debugPrint('FCM token: $token');
      await _db.collection('users').doc(uid).set({
        'fcmTokens': FieldValue.arrayUnion([token]),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Token sync failed: $e');
    }
  }

  // ───────────── Handlers ─────────────
  void _onTap(NotificationResponse r) async {
    await syncInbox();
    Get.toNamed(Routes.notifications);
  }

  Future<void> _onForegroundMessage(RemoteMessage m) async {
    final title = (m.data['title'] as String?) ?? m.notification?.title;
    final text = (m.data['body'] as String?) ?? m.notification?.body;
    if (title == null && text == null) return;

    await _local.show(
      id: m.hashCode,
      title: title,
      body: text,
      notificationDetails: details,
      payload: 'fcm',
    );
    await _saveRemoteMessage(m);
  }

  Future<void> _saveRemoteMessage(RemoteMessage m) => addToInbox(
    id: m.messageId,
    title: (m.data['title'] as String?) ??
        m.notification?.title ??
        'TOEFL Practice',
    body: (m.data['body'] as String?) ?? m.notification?.body ?? '',
    type: 'fcm',
  );

  void handlePendingNavigation() {
    if (openInboxOnStart) {
      openInboxOnStart = false;
      Get.toNamed(Routes.notifications);
    }
  }

  // ═════════════ Inbox sync ═════════════
  /// Call whenever the app opens or the notification screen is visible.
  Future<void> syncInbox() async {
    if (_syncing) return;
    _syncing = true;
    try {
      await _syncMissedReminders();
      await _captureTrayNotifications();
    } catch (e) {
      debugPrint('Inbox sync failed: $e');
    } finally {
      _syncing = false;
    }
  }

  /// Adds one inbox entry for every daily reminder that has fired since the
  /// last sync. Android fires reminders without running app code, so this is
  /// how they get into the list.
  Future<void> _syncMissedReminders() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final col = _inbox;
    if (uid == null || col == null) return;

    final userRef = _db.collection('users').doc(uid);
    final d = (await userRef.get()).data();
    if (d == null || d['reminderEnabled'] != true) return;

    final h = d['reminderHour'];
    final m = d['reminderMinute'];
    if (h is! int || m is! int) return;

    final now = DateTime.now();
    final since = (d['reminderSince'] as Timestamp?)?.toDate();
    final synced = (d['reminderSyncedUntil'] as Timestamp?)?.toDate();

    // Never go back more than 7 days
    var lower = now.subtract(const Duration(days: 7));
    for (final t in [since, synced]) {
      if (t != null && t.isAfter(lower)) lower = t;
    }
    if (since == null && synced == null) {
      lower = now.subtract(const Duration(days: 1));
    }

    final today = DateTime(now.year, now.month, now.day);
    for (var i = 6; i >= 0; i--) {
      final day = today.subtract(Duration(days: i));
      final at = DateTime(day.year, day.month, day.day, h, m);
      if (at.isAfter(now) || !at.isAfter(lower)) continue;

      final id = 'reminder_${day.year}'
          '${day.month.toString().padLeft(2, '0')}'
          '${day.day.toString().padLeft(2, '0')}';
      final ref = col.doc(id);
      if ((await ref.get()).exists) continue;
      await ref.set({
        'title': 'Time to practise 📚',
        'body': 'Your daily TOEFL practice is waiting. Keep your streak going!',
        'type': 'reminder',
        'read': false,
        'createdAt': Timestamp.fromDate(at),
      });
    }

    // Remember this point so deleted entries don't come back
    await userRef.set({
      'reminderSyncedUntil': Timestamp.fromDate(now),
    }, SetOptions(merge: true));
  }

  /// FCM messages shown by the system while the app was closed or in the
  /// background are still in the tray. Copy any that are not saved yet.
  Future<void> _captureTrayNotifications() async {
    if (defaultTargetPlatform != TargetPlatform.android) return;
    final col = _inbox;
    if (col == null) return;

    final active = await _local.getActiveNotifications();
    for (final n in active) {
      if (n.channelId == _channelId) continue; // ours (already handled)
      final title = n.title ?? '';
      final text = n.body ?? '';
      if (title.isEmpty && text.isEmpty) continue;

      final key = 'tray_${_stableHash('${n.tag}|${n.id}|$title|$text')}';
      final ref = col.doc(key);
      if ((await ref.get()).exists) continue;
      await ref.set({
        'title': title.isEmpty ? 'TOEFL Practice' : title,
        'body': text,
        'type': 'fcm',
        'read': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  String _stableHash(String s) {
    var h = 0x811C9DC5;
    for (final c in s.codeUnits) {
      h ^= c;
      h = (h * 0x01000193) & 0xFFFFFFFF;
    }
    return h.toRadixString(16);
  }

  // ───────────── Inbox helpers ─────────────
  CollectionReference<Map<String, dynamic>>? get _inbox {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    return _db.collection('users').doc(uid).collection('notifications');
  }

  Future<void> addToInbox({
    required String title,
    required String body,
    String type = 'general',
    String? id,
  }) async {
    final col = _inbox;
    if (col == null) return;
    try {
      final data = {
        'title': title,
        'body': body,
        'type': type,
        'read': false,
        'createdAt': FieldValue.serverTimestamp(),
      };
      if (id != null) {
        final ref = col.doc(id);
        if ((await ref.get()).exists) return;
        await ref.set(data);
      } else {
        await col.add(data);
      }
    } catch (e) {
      debugPrint('Inbox save failed: $e');
    }
  }

  /// Used by the background isolate (no GetX, no service instance there).
  static Future<void> _saveInBackground({
    String? id,
    required String title,
    required String body,
  }) async {
    try {
      // The signed-in user is restored asynchronously in a fresh isolate
      final user = FirebaseAuth.instance.currentUser ??
          await FirebaseAuth.instance
              .authStateChanges()
              .first
              .timeout(const Duration(seconds: 4), onTimeout: () => null);
      if (user == null) return;

      final col = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('notifications');
      final docId = id ?? DateTime.now().millisecondsSinceEpoch.toString();
      final ref = col.doc(docId);
      if ((await ref.get()).exists) return;
      await ref.set({
        'title': title,
        'body': body,
        'type': 'fcm',
        'read': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Background inbox save failed: $e');
    }
  }

  Stream<int> unreadCount() {
    final col = _inbox;
    if (col == null) return Stream.value(0);
    return col
        .where('read', isEqualTo: false)
        .snapshots()
        .map((s) => s.docs.length);
  }
}