import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:toefl_pro/app/data/mock_data.dart';
import 'package:toefl_pro/app/data/models/models.dart';

// ⚠️ Same imports as HomeController. Fix the paths if your folders differ.
import '../../listening/listening_store.dart';
import '../../reading/reading_store.dart';
import '../../speaking/speaking_store.dart';
import '../../writing/writing_store.dart';

class PracticeController extends GetxController {
  List<Skill> get skills => MockData.skills;

  /// Real scores (0-100) per skill name. Only skills with attempts are present.
  final scores = <String, int>{}.obs;

  // Band (1-6) -> percent (0-100)
  double? _pct(Map<String, dynamic> j) {
    final b = j['band'];
    if (b is! num) return null;
    return (b / 6 * 100).toDouble();
  }

  // Average of the last 3 scored attempts
  int? _avg(Iterable<double?> values) {
    final l = values.whereType<double>().toList();
    if (l.isEmpty) return null;
    final last = l.length > 3 ? l.sublist(l.length - 3) : l;
    return (last.reduce((a, b) => a + b) / last.length).round().clamp(0, 100);
  }

  void _recalc() {
    final m = <String, int>{};

    final r = _avg(ReadingStore.I.history.map((a) => _pct(a.toJson())));
    final l = _avg(ListeningStore.I.history.map((a) => _pct(a.toJson())));
    final s = _avg(SpeakingStore.I.history.map((a) => _pct(a.toJson())));
    final w = _avg(WritingStore.I.history.map((a) {
      final j = a.toJson();
      if ((j['ew'] ?? 0) == 0 && (j['dw'] ?? 0) == 0) return null;
      return _pct(j);
    }));

    if (r != null) m['Reading'] = r;
    if (l != null) m['Listening'] = l;
    if (s != null) m['Speaking'] = s;
    if (w != null) m['Writing'] = w;

    scores.assignAll(m);
    debugPrint('Practice scores: $m'); // check this in the console
  }

  Future<void> _load() async {
    await Future.wait([
      ReadingStore.I.ensureLoaded(),
      ListeningStore.I.ensureLoaded(),
      SpeakingStore.I.ensureLoaded(),
      WritingStore.I.ensureLoaded(),
    ]);
    _recalc();

    // Recalculate whenever any history changes
    everAll([
      ReadingStore.I.history,
      ListeningStore.I.history,
      SpeakingStore.I.history,
      WritingStore.I.history,
    ], (_) => _recalc());
  }

  int percentOf(Skill s) => scores[s.name] ?? 0;
  double progressOf(Skill s) => percentOf(s) / 100;

  void open(Skill s) => Get.toNamed(s.route);

  @override
  void onInit() {
    super.onInit();
    _load();
  }
}