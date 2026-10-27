import 'dart:math';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'speaking_data.dart';
import 'speaking_models.dart';

/// Remembers which Speaking tests were used and every finished attempt,
/// so nothing repeats and history is kept.
class SpeakingStore {
  SpeakingStore._();
  static final SpeakingStore I = SpeakingStore._();

  static const _key = 'speaking_toefl2026_v1';
  static const _histKey = 'speaking_history_v1';

  final used = <String>{}.obs;
  final attempts = <SpeakingAttempt>[].obs; // current cycle (cleared by reset)
  final history = <SpeakingAttempt>[].obs; // permanent (NOT cleared by reset)

  bool _loaded = false;
  GetStorage? _box;

  Future<void> ensureLoaded() async {
    if (_loaded) return;
    try {
      await GetStorage.init();
      _box = GetStorage();

      final raw = _box!.read(_key);
      if (raw is Map) {
        used.addAll(((raw['used'] ?? []) as List).cast<String>());
        for (final a in (raw['attempts'] ?? []) as List) {
          attempts.add(SpeakingAttempt.fromJson(Map<String, dynamic>.from(a as Map)));
        }
      }
      final h = _box!.read(_histKey);
      if (h is List) {
        for (final a in h) {
          history.add(SpeakingAttempt.fromJson(Map<String, dynamic>.from(a as Map)));
        }
      }
    } catch (_) {/* fall back to memory */}
    _loaded = true;
  }

  int get maxTests => SpeakingBank.maxTests;
  int get completedCount => attempts.length;

  bool get canStart => attempts.length < maxTests && SpeakingBank.pick(used, Random()) != null;

  Future<void> complete(SpeakingAttempt r, String testId) async {
    attempts.add(r);
    history.add(r);
    used.add(testId);
    await _persist();
  }

  /// Called when the automatic interview check finishes.
  Future<void> update(SpeakingAttempt r) async {
    final i = attempts.indexWhere((e) => e.ts == r.ts);
    if (i >= 0) attempts[i] = r;
    final j = history.indexWhere((e) => e.ts == r.ts);
    if (j >= 0) history[j] = r;
    await _persist();
  }

  /// "Practice again": all tests become available again, history is kept.
  Future<void> reset() async {
    attempts.clear();
    used.clear();
    await _persist();
  }

  Future<void> clearHistory() async {
    history.clear();
    await _persist();
  }

  Future<void> _persist() async {
    try {
      await _box?.write(_key, {
        'used': used.toList(),
        'attempts': attempts.map((a) => a.toJson()).toList(),
      });
      await _box?.write(_histKey, history.map((a) => a.toJson()).toList());
    } catch (_) {}
  }
}