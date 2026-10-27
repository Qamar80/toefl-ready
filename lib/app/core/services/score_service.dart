import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:toefl_pro/app/core/services/auth_service.dart';

class ScoreService {
  static final _db = FirebaseFirestore.instance;

  static CollectionReference<Map<String, dynamic>>? get _scores {
    final uid = AuthService.to.uid;
    if (uid == null) return null;
    return _db.collection('users').doc(uid).collection('scores');
  }

  /// skill: Reading, Listening, Speaking or Writing
  static Future<bool> saveScore({
    required String skill,
    required int score,
    required int total,
  }) async {
    final col = _scores;
    if (col == null) {
      debugPrint('saveScore: no signed-in user');
      return false;
    }
    try {
      await col.add({
        'skill': skill,
        'score': score,
        'total': total,
        'createdAt': FieldValue.serverTimestamp(),
      });
      debugPrint('Score saved: $skill $score/$total');
      return true;
    } catch (e) {
      debugPrint('Failed to save score: $e');
      return false;
    }
  }

  /// All scores, newest first
  static Stream<QuerySnapshot<Map<String, dynamic>>>? history() =>
      _scores?.orderBy('createdAt', descending: true).snapshots();
}