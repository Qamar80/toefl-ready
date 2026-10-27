
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toefl_pro/app/core/services/notification_service.dart';
import 'package:toefl_pro/app/data/models/models.dart';

import '../../../core/theme/app_colors.dart';
import '../../../routes/app_routes.dart';
import '../../bottom_bar/controllers/main_controller.dart';

// ⚠️ Fix these paths to where your stores and models really are
import '../../listening/listening_models.dart';
import '../../listening/listening_store.dart';

import '../../reading/reading_models.dart';
import '../../reading/reading_store.dart';

import '../../speaking/speaking_models.dart';
import '../../speaking/speaking_store.dart';

import '../../writing/writing_models.dart';
import '../../writing/writing_store.dart';




class HomeController extends GetxController {
  // ───────────── Signed-in user (reactive) ─────────────
  final name = 'Guest'.obs;
  final photoUrl = RxnString();
  StreamSubscription<User?>? _sub;

  void _updateUser(User? u) {
    _listenGoal(u);

    if (u == null || u.isAnonymous) {
      name.value = 'Guest';
      photoUrl.value = null;
      return;
    }

    String? full = u.displayName;
    String? photo = u.photoURL;

    if (full == null || full.isEmpty) {
      for (final p in u.providerData) {
        if (p.displayName != null && p.displayName!.isNotEmpty) {
          full = p.displayName;
          break;
        }
      }
    }

    if (photo == null || photo.isEmpty) {
      for (final p in u.providerData) {
        if (p.photoURL != null && p.photoURL!.isNotEmpty) {
          photo = p.photoURL;
          break;
        }
      }
    }

    photoUrl.value = (photo == null || photo.isEmpty) ? null : photo;

    name.value = (full == null || full.isEmpty)
        ? 'TOEFL learner'
        : full.trim().split(RegExp(r'\s+')).first; // first name only
  }

  // ───────────── Daily goal (live from Firestore) ─────────────
  final goalMinutes = 60.obs;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _goalSub;
  String? _goalUid;

  void _listenGoal(User? u) {
    final uid = u?.uid;
    if (uid == _goalUid) return; // same user, keep the current listener
    _goalUid = uid;
    _goalSub?.cancel();
    _goalSub = null;
    if (uid == null) return;

    _goalSub = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots()
        .listen((doc) {
      final g = doc.data()?['dailyGoalMinutes'];
      if (g is int && g > 0) goalMinutes.value = g;
    }, onError: (e) => debugPrint('Goal listener error: $e'));
  }

  // ───────────── Real activity: streak, minutes today, week dots ─────────────
  final streak = 0.obs;
  final minutesDone = 0.obs;
  final weekDone = List<bool>.filled(7, false).obs; // Mon..Sun

  int get todayIndex => DateTime.now().weekday - 1;

  void _recalcActivity() {
    // seconds studied per calendar day
    final secByDay = <DateTime, int>{};

    void add(Map<String, dynamic> j) {
      final ts = j['ts'];
      if (ts is! num) return;
      final sec = j['sec'] is num ? (j['sec'] as num).toInt() : 0;
      final d = DateTime.fromMillisecondsSinceEpoch(ts.toInt());
      final day = DateTime(d.year, d.month, d.day);
      secByDay[day] = (secByDay[day] ?? 0) + sec;
    }

    for (final a in ReadingStore.I.history) {
      add(a.toJson());
    }
    for (final a in ListeningStore.I.history) {
      add(a.toJson());
    }
    for (final a in SpeakingStore.I.history) {
      add(a.toJson());
    }
    for (final a in WritingStore.I.history) {
      final j = a.toJson();
      // Empty attempts (0 words) don't count as studying
      if ((j['ew'] ?? 0) == 0 && (j['dw'] ?? 0) == 0) continue;
      add(j);
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Minutes studied today (rounded up, so 45 s counts as 1 min)
    minutesDone.value = ((secByDay[today] ?? 0) / 60).ceil();

    // Streak: consecutive days with activity. If nothing yet today,
    // start from yesterday so the streak isn't lost until the day ends.
    var cursor = secByDay.containsKey(today)
        ? today
        : DateTime(today.year, today.month, today.day - 1);
    var count = 0;
    while (secByDay.containsKey(cursor)) {
      count++;
      cursor = DateTime(cursor.year, cursor.month, cursor.day - 1);
    }
    streak.value = count;

    // This week's dots (Mon..Sun)
    final weekStart =
    DateTime(today.year, today.month, today.day - (today.weekday - 1));
    weekDone.assignAll([
      for (int i = 0; i < 7; i++)
        secByDay.containsKey(
            DateTime(weekStart.year, weekStart.month, weekStart.day + i)),
    ]);
  }

  // ───────────── Real scores (from the stores) ─────────────
  final skillScores = <String, int>{}.obs; // only skills that have attempts
  final estimatedScore = 0.obs; // 0-120 scale
  final readiness = 0.obs; // percent of target

  /// Band (1-6) -> percent (0-100)
  double? _bandPct(Map<String, dynamic> j) {
    final b = j['band'];
    if (b is! num) return null;
    return (b / 6 * 100).toDouble();
  }

  double? _readingPct(AttemptResult a) => _bandPct(a.toJson());

  double? _listeningPct(ListeningAttempt a) => _bandPct(a.toJson());

  double? _speakingPct(SpeakingAttempt a) => _bandPct(a.toJson());

  double? _writingPct(WritingAttempt a) {
    final j = a.toJson();
    if ((j['ew'] ?? 0) == 0 && (j['dw'] ?? 0) == 0) return null;
    return _bandPct(j);
  }

  /// Average of the last 3 scored attempts.
  int? _avg(Iterable<double?> values) {
    final l = values.whereType<double>().toList();
    if (l.isEmpty) return null;
    final last = l.length > 3 ? l.sublist(l.length - 3) : l;
    return (last.reduce((a, b) => a + b) / last.length).round().clamp(0, 100);
  }

  void _recalcScores() {
    final m = <String, int>{};

    final r = _avg(ReadingStore.I.history.map(_readingPct));
    final l = _avg(ListeningStore.I.history.map(_listeningPct));
    final s = _avg(SpeakingStore.I.history.map(_speakingPct));
    final w = _avg(WritingStore.I.history.map(_writingPct));

    if (r != null) m['Reading'] = r;
    if (l != null) m['Listening'] = l;
    if (s != null) m['Speaking'] = s;
    if (w != null) m['Writing'] = w;

    skillScores.assignAll(m);

    if (m.isEmpty) {
      estimatedScore.value = 0;
      readiness.value = 0;
      return;
    }

    final avg = m.values.reduce((a, b) => a + b) / m.length;
    estimatedScore.value = (avg * 1.2).round(); // 0-100% -> 0-120
    readiness.value =
        (estimatedScore.value / targetScore * 100).round().clamp(0, 100);
  }

  void _recalc() {
    _recalcScores();
    _recalcActivity();
  }

  Future<void> _loadScores() async {
    await Future.wait([
      ReadingStore.I.ensureLoaded(),
      ListeningStore.I.ensureLoaded(),
      SpeakingStore.I.ensureLoaded(),
      WritingStore.I.ensureLoaded(),
    ]);
    _recalc();

    // Re-calculate whenever any history changes (new test, rating, clear)
    everAll([
      ReadingStore.I.history,
      ListeningStore.I.history,
      SpeakingStore.I.history,
      WritingStore.I.history,
    ], (_) => _recalc());
  }

  String get weakestSkill {
    if (skillScores.isEmpty) return 'Writing'; // default suggestion
    return skillScores.entries
        .reduce((a, b) => a.value <= b.value ? a : b)
        .key;
  }

  // ───────────── Static data ─────────────
  final targetScore = 100;

  final skills = const <Skill>[
    Skill(
      'Reading',
      null,
      0.8,
      AppColors.teal600,
      Routes.reading,
      assetImage: 'assets/images/reading.png',
    ),
    Skill(
      'Listening',
      null,
      0.7,
      AppColors.indigo600,
      Routes.listening,
      assetImage: 'assets/images/listening.png',
    ),
    Skill(
      'Speaking',
      null,
      0.6,
      AppColors.amber,
      Routes.speaking,
      assetImage: 'assets/images/speaking.png',
    ),
    Skill(
      'Writing',
      null,
      0.75,
      Color(0xFFE11D48),
      Routes.writing,
      assetImage: 'assets/images/writing.png',
    ),
  ];

  double get goalProgress =>
      (minutesDone.value / goalMinutes.value).clamp(0.0, 1.0);

  String get greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  void openPracticeTab() => Get.find<MainController>().changeTab(1);

  // ───────────── Lifecycle ─────────────
  @override
  void onInit() {
    super.onInit();
    _updateUser(FirebaseAuth.instance.currentUser);
    _sub = FirebaseAuth.instance.userChanges().listen(_updateUser);
    _loadScores();
  }

  @override
  void onReady() {
    super.onReady();
    NotificationService.to.ensurePermission();
    NotificationService.to.handlePendingNavigation();
  }

  @override
  void onClose() {
    _sub?.cancel();
    _goalSub?.cancel();
    super.onClose();
  }
}


