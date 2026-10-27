import 'dart:math';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'reading_data.dart';
import 'reading_models.dart';

/// Remembers which tasks were used and the finished tests, so nothing repeats.
/// Also keeps a permanent history of every finished test for the report screen.
class ReadingStore {
  ReadingStore._();
  static final ReadingStore I = ReadingStore._();

  static const _key = 'reading_toefl2026_v1';
  static const _histKey = 'reading_history_v1';

  final used = <String>{}.obs;
  final attempts = <AttemptResult>[].obs; // current cycle (cleared by reset)
  final history = <AttemptResult>[].obs;  // permanent (NOT cleared by reset)

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
          attempts.add(AttemptResult.fromJson(Map<String, dynamic>.from(a as Map)));
        }
      }

      final h = _box!.read(_histKey);
      if (h is List) {
        for (final a in h) {
          history.add(AttemptResult.fromJson(Map<String, dynamic>.from(a as Map)));
        }
      } else if (attempts.isNotEmpty) {
        // Migrate tests saved before the history feature existed.
        history.addAll(attempts);
        await _persist();
      }
    } catch (_) {/* fall back to memory */}
    _loaded = true;
  }

  int get maxTests => ReadingBank.maxTests;
  int get completedCount => attempts.length;

  bool get canStart =>
      attempts.length < maxTests && ReadingBank.module(2, used, Random()) != null;

  Future<void> complete(AttemptResult r, Iterable<String> taskIds) async {
    attempts.add(r);
    history.add(r);
    used.addAll(taskIds);
    await _persist();
  }

  /// "Practice again": makes all tests available again, keeps the history.
  Future<void> reset() async {
    attempts.clear();
    used.clear();
    await _persist();
  }

  /// Deletes the saved report data (used by the report screen).
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