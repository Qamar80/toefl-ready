
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:toefl_pro/app/core/services/auth_service.dart';
import 'package:toefl_pro/app/routes/app_routes.dart';

import '../../../core/services/notification_service.dart';
import '../../../core/widgets/app_dialog.dart';

class ProfileController extends GetxController {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  final firebaseUser = Rxn<User>();
  final goalOptions = const [15, 30, 60, 90];
  final goal = 60.obs;
  final themeMode = ThemeMode.light.obs;

  /// Off until a reminder is really scheduled or loaded from Firestore
  final reminder = false.obs;
  final reminderTime = const TimeOfDay(hour: 19, minute: 30).obs;
  final signingIn = false.obs;

  StreamSubscription<User?>? _sub;

  // ───────────── Lifecycle ─────────────
  @override
  void onInit() {
    super.onInit();
    firebaseUser.value = _auth.currentUser;
    // Fires on sign-in, sign-out, guest-to-Google link and reload
    _sub = _auth.userChanges().listen((u) {
      final uidChanged = u?.uid != firebaseUser.value?.uid;
      firebaseUser.value = u;
      firebaseUser.refresh();
      if (uidChanged) _loadSettings();
    });
    _loadSettings();
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }

  // ───────────── User info (read inside Obx) ─────────────
  bool get isGuest => firebaseUser.value?.isAnonymous ?? true;

  // After a guest links Google, displayName / photoURL can be null on the
  // top-level user, so fall back to the provider data.
  String? _fromProviders(String? Function(UserInfo) pick) {
    final u = firebaseUser.value;
    if (u == null) return null;
    for (final p in u.providerData) {
      final v = pick(p);
      if (v != null && v.isNotEmpty) return v;
    }
    return null;
  }

  String get name {
    final n = firebaseUser.value?.displayName;
    if (n != null && n.isNotEmpty) return n;
    return _fromProviders((p) => p.displayName) ??
        (isGuest ? 'Guest' : 'TOEFL learner');
  }

  String? get email {
    final e = firebaseUser.value?.email;
    if (e != null && e.isNotEmpty) return e;
    return _fromProviders((p) => p.email);
  }

  String? get photoUrl {
    final p = firebaseUser.value?.photoURL;
    if (p != null && p.isNotEmpty) return p;
    return _fromProviders((p) => p.photoURL);
  }

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    final a = parts.first[0];
    final b = parts.length > 1 ? parts.last[0] : '';
    return (a + b).toUpperCase();
  }

  // ───────────── Settings in Firestore ─────────────
  Future<void> _loadSettings() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    try {
      final data = (await _db.collection('users').doc(uid).get()).data();

      final g = data?['dailyGoalMinutes'];
      if (g is int && goalOptions.contains(g)) goal.value = g;

      final h = data?['reminderHour'];
      final m = data?['reminderMinute'];
      if (h is int && m is int) {
        reminderTime.value = TimeOfDay(hour: h, minute: m);
      }

      final enabled = data?['reminderEnabled'] == true;
      reminder.value = enabled; // false when nothing is saved
      if (enabled) {
        // Re-schedule silently (useful after reinstall or on a new phone)
        NotificationService.to
            .scheduleDailyReminder(reminderTime.value, ask: false);
      }
    } catch (e) {
      debugPrint('Failed to load settings: $e');
    }
  }

  // ───────────── Reminder ─────────────
  Future<void> toggleReminder(bool on) async {
    if (on) {
      final ok = await NotificationService.to
          .scheduleDailyReminder(reminderTime.value);
      if (!ok) {
        reminder.value = false;
        _permissionSnack();
        return;
      }
      reminder.value = true;
    } else {
      await NotificationService.to.cancelReminder();
      reminder.value = false;
    }
    await _saveReminder();
  }

  Future<void> pickReminderTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: reminderTime.value,
      helpText: 'Daily study reminder',
    );
    if (picked == null) return;

    final ok = await NotificationService.to.scheduleDailyReminder(picked);
    if (!ok) {
      // Keep the old time and tell the user why nothing was set
      _permissionSnack();
      return;
    }

    reminderTime.value = picked;
    reminder.value = true; // picking a time turns the reminder on
    await _saveReminder();

    if (context.mounted) {
      Get.snackbar('Reminder set',
          'We will remind you every day at ${picked.format(context)}.',
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16));
    }
  }

  Future<void> _saveReminder() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    try {
      await _db.collection('users').doc(uid).set({
        'reminderEnabled': reminder.value,
        'reminderHour': reminderTime.value.hour,
        'reminderMinute': reminderTime.value.minute,
        // Only restart the inbox "since" point when the reminder is on
        if (reminder.value) 'reminderSince': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Failed to save reminder: $e');
    }
  }

  void _permissionSnack() => Get.snackbar(
    'Notifications blocked',
    'Allow notifications for this app in your phone Settings to get reminders.',
    snackPosition: SnackPosition.BOTTOM,
    margin: const EdgeInsets.all(16),
  );

  // ───────────── Goal & theme ─────────────
  Future<void> setGoal(int g) async {
    goal.value = g;
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    try {
      await _db.collection('users').doc(uid).set(
        {'dailyGoalMinutes': g},
        SetOptions(merge: true),
      );
    } catch (e) {
      debugPrint('Failed to save goal: $e');
    }
  }

  void setTheme(ThemeMode m) {
    themeMode.value = m;
    Get.changeThemeMode(m);
  }

  // ───────────── Auth actions ─────────────
  Future<void> signInWithGoogle() async {
    signingIn.value = true;
    try {
      await AuthService.to.signInWithGoogle();
      await _auth.currentUser?.reload();
      Get.snackbar('Signed in', 'Your scores now sync to your Google account.',
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16));
    } on GoogleSignInException catch (e) {
      if (e.code != GoogleSignInExceptionCode.canceled) {
        _error('Google sign-in failed (${e.code.name}).');
      }
    } on FirebaseAuthException catch (e) {
      _error('Google sign-in failed (${e.code}).');
    } catch (_) {
      _error('Something went wrong. Please try again.');
    } finally {
      signingIn.value = false;
    }
  }
  Future<void> confirmSignOut() async {
    final ok = await AppDialog.confirm(
      title: 'Sign out?',
      message: isGuest
          ? 'You are using a guest account. If you sign out, your scores '
          'will be lost. Sign in with Google first to keep them.'
          : 'You can sign back in any time to see your score history.',
      confirmText: isGuest ? 'Sign out anyway' : 'Sign out',
      cancelText: 'Cancel',
      type: isGuest ? AppDialogType.danger : AppDialogType.warning,
      icon: Icons.logout_rounded,
    );
    if (!ok) return;

    // Stop this account's daily alarm. It is restored on the next sign-in.
    await NotificationService.to.cancelReminder();
    reminder.value = false;

    await AuthService.to.signOut();
    Get.offAllNamed(Routes.welcome);
  }

/*  Future<void> confirmSignOut() async {
    final ok = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Sign out?'),
        content: Text(isGuest
            ? 'You are using a guest account. If you sign out, your scores '
            'will be lost. Sign in with Google first to keep them.'
            : 'You can sign back in any time to see your score history.'),
        actions: [
          TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Get.back(result: true),
              child: Text(isGuest ? 'Sign out anyway' : 'Sign out')),
        ],
      ),
    );
    if (ok != true) return;

    // Stop this account's daily alarm. It is restored on the next sign-in.
    await NotificationService.to.cancelReminder();
    reminder.value = false;

    await AuthService.to.signOut();
    Get.offAllNamed(Routes.welcome);
  }*/

  void _error(String msg) => Get.snackbar('Sign in', msg,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      backgroundColor: const Color(0xFFEF4444),
      colorText: Colors.white);

}