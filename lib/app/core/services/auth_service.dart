import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class AuthService extends GetxService {
  static AuthService get to => Get.find();

  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  User? get user => _auth.currentUser;
  String? get uid => user?.uid;
  bool get isGuest => user?.isAnonymous ?? true;
  bool get isLoggedIn => user != null;

  Future<AuthService> init() async => this;

  // ───────────── Continue as Guest ─────────────
  Future<void> signInAsGuest() async {
    await _auth.signInAnonymously();
    await _saveUserProfile();
  }

  // ───────────── Continue with Google (browser flow) ─────────────
  Future<void> signInWithGoogle() async {
    final provider = GoogleAuthProvider()
      ..addScope('email')
      ..addScope('profile')
    // Always show the Google account chooser
      ..setCustomParameters({'prompt': 'select_account'});

    final current = _auth.currentUser;

    if (current != null && current.isAnonymous) {
      try {
        // Keeps the same UID, so guest scores are preserved
        await current.linkWithProvider(provider);
        await _saveUserProfile();
        return;
      } on FirebaseAuthException catch (e) {
        // This Google account already exists, so sign in to it instead
        if (e.code == 'credential-already-in-use' && e.credential != null) {
          await _auth.signInWithCredential(e.credential!);
          await _saveUserProfile();
          return;
        }
        rethrow;
      }
    }

    await _auth.signInWithProvider(provider);
    await _saveUserProfile();
  }

  // ───────────── Save user document in Firestore ─────────────
  Future<void> _saveUserProfile() async {
    final u = _auth.currentUser;
    if (u == null) return;

    final p = u.providerData.isNotEmpty ? u.providerData.first : null;

    try {
      await _db.collection('users').doc(u.uid).set({
        'uid': u.uid,
        'isGuest': u.isAnonymous,
        'name': u.displayName ?? p?.displayName,
        'email': u.email ?? p?.email,
        'photoUrl': u.photoURL ?? p?.photoURL,
        'lastLogin': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Failed to save user profile: $e');
    }
  }

  // ───────────── Sign out ─────────────
  Future<void> signOut() async {
    await _auth.signOut();
  }
}