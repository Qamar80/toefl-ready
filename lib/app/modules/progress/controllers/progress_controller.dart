import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

// ⚠️ Same imports as HomeController. Fix the paths if your folders differ.
import '../../listening/listening_store.dart';
import '../../reading/reading_store.dart';
import '../../speaking/speaking_store.dart';
import '../../writing/writing_store.dart';

class _Entry {
  _Entry(this.skill, this.ts, this.sec, this.pct);
  final String skill;
  final DateTime ts;
  final int sec;
  final double? pct; // 0-100, null if not scored
}

class ProgressController extends GetxController {
  final ranges = const ['Week', 'Month', 'All time'];
  final range = 0.obs;
  final days = const ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  final skillNames = const ['Reading', 'Listening', 'Speaking', 'Writing'];

  static const _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  // ───────────── Reactive values for the view ─────────────
  final studiedLabel = '0m'.obs;
  final accuracyLabel = '-'.obs;
  final streak = 0.obs;
  final bestStreak = 0.obs;
  final weekly = List<double>.filled(7, 0).obs; // minutes, Mon..Sun
  final skills = <String, double>{}.obs; // 0..1
  final skillDelta = <String, String>{}.obs;
  final monthDone = <bool>[].obs; // day 1..N of this month

  int get todayIndex => DateTime.now().weekday - 1;
  int get todayDay => DateTime.now().day;
  String get monthName => _months[DateTime.now().month - 1];

  // ───────────── Helpers ─────────────
  double? _pct(Map<String, dynamic> j) {
    final b = j['band'];
    if (b is! num) return null;
    return (b / 6 * 100).toDouble();
  }

  List<_Entry> _entries(
      String skill,
      Iterable<Map<String, dynamic>> items, {
        bool skipEmptyWriting = false,
      }) {
    final out = <_Entry>[];
    for (final j in items) {
      final ts = j['ts'];
      if (ts is! num) continue;
      if (skipEmptyWriting && (j['ew'] ?? 0) == 0 && (j['dw'] ?? 0) == 0) {
        continue;
      }
      final sec = j['sec'] is num ? (j['sec'] as num).toInt() : 0;
      out.add(_Entry(
        skill,
        DateTime.fromMillisecondsSinceEpoch(ts.toInt()),
        sec,
        _pct(j),
      ));
    }
    return out;
  }

  int? _avgLast(List<double> v, {int n = 3}) {
    if (v.isEmpty) return null;
    final last = v.length > n ? v.sublist(v.length - n) : v;
    return (last.reduce((a, b) => a + b) / last.length).round().clamp(0, 100);
  }

  String _fmtDuration(int seconds) {
    final m = (seconds / 60).round();
    if (m < 60) return '${m}m';
    return '${m ~/ 60}h ${(m % 60).toString().padLeft(2, '0')}m';
  }

  DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

  // ───────────── Main calculation ─────────────
  void _recalc() {
    final byskill = <String, List<_Entry>>{
      'Reading': _entries('Reading', ReadingStore.I.history.map((a) => a.toJson())),
      'Listening': _entries('Listening', ListeningStore.I.history.map((a) => a.toJson())),
      'Speaking': _entries('Speaking', SpeakingStore.I.history.map((a) => a.toJson())),
      'Writing': _entries('Writing', WritingStore.I.history.map((a) => a.toJson()),
          skipEmptyWriting: true),
    };
    final all = byskill.values.expand((e) => e).toList();

    final now = DateTime.now();
    final today = _day(now);

    // seconds studied per calendar day
    final secByDay = <DateTime, int>{};
    for (final e in all) {
      final d = _day(e.ts);
      secByDay[d] = (secByDay[d] ?? 0) + e.sec;
    }

    // ── Range filter for the three stat cards
    final weekStart = DateTime(today.year, today.month, today.day - (today.weekday - 1));
    final DateTime? start = switch (range.value) {
      0 => weekStart,
      1 => DateTime(today.year, today.month, 1),
      _ => null,
    };
    final inRange = start == null ? all : all.where((e) => !e.ts.isBefore(start)).toList();

    final totalSec = inRange.fold<int>(0, (s, e) => s + e.sec);
    studiedLabel.value = _fmtDuration(totalSec);

    final scored = inRange.map((e) => e.pct).whereType<double>().toList();
    accuracyLabel.value = scored.isEmpty
        ? '-'
        : '${(scored.reduce((a, b) => a + b) / scored.length).round()}%';

    // ── Streak (current) + best streak
    var cursor = secByDay.containsKey(today) ? today : DateTime(today.year, today.month, today.day - 1);
    var count = 0;
    while (secByDay.containsKey(cursor)) {
      count++;
      cursor = DateTime(cursor.year, cursor.month, cursor.day - 1);
    }
    streak.value = count;

    final sortedDays = secByDay.keys.toList()..sort();
    var best = 0, run = 0;
    DateTime? prev;
    for (final d in sortedDays) {
      if (prev != null && DateTime(prev.year, prev.month, prev.day + 1) == d) {
        run++;
      } else {
        run = 1;
      }
      if (run > best) best = run;
      prev = d;
    }
    bestStreak.value = best;

    // ── Weekly minutes (Mon..Sun of this week)
    weekly.assignAll([
      for (int i = 0; i < 7; i++)
        (secByDay[DateTime(weekStart.year, weekStart.month, weekStart.day + i)] ?? 0) / 60,
    ]);

    // ── Skill performance + delta (same method as Home)
    final sk = <String, double>{};
    final dl = <String, String>{};
    for (final name in skillNames) {
      final pcts = byskill[name]!.map((e) => e.pct).whereType<double>().toList();
      final cur = _avgLast(pcts);
      sk[name] = (cur ?? 0) / 100;

      if (cur == null || pcts.length <= 3) {
        dl[name] = '–';
      } else {
        final older = pcts.sublist(0, pcts.length - 3);
        final before = _avgLast(older);
        final diff = before == null ? 0 : cur - before;
        dl[name] = diff > 0 ? '+$diff' : '$diff';
      }
    }
    skills.assignAll(sk);
    skillDelta.assignAll(dl);

    // ── This month calendar
    final daysInMonth = DateTime(today.year, today.month + 1, 0).day;
    monthDone.assignAll([
      for (int d = 1; d <= daysInMonth; d++)
        secByDay.containsKey(DateTime(today.year, today.month, d)),
    ]);

    debugPrint('Progress: studied=${studiedLabel.value} avg=${accuracyLabel.value} '
        'streak=${streak.value} best=${bestStreak.value}');
  }

  Future<void> _load() async {
    await Future.wait([
      ReadingStore.I.ensureLoaded(),
      ListeningStore.I.ensureLoaded(),
      SpeakingStore.I.ensureLoaded(),
      WritingStore.I.ensureLoaded(),
    ]);
    _recalc();

    everAll([
      ReadingStore.I.history,
      ListeningStore.I.history,
      SpeakingStore.I.history,
      WritingStore.I.history,
    ], (_) => _recalc());

    ever(range, (_) => _recalc());
  }

  @override
  void onInit() {
    super.onInit();
    _load();
  }
}