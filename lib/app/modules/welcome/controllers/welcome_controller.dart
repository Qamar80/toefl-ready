import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toefl_pro/app/core/services/auth_service.dart';
import 'package:toefl_pro/app/routes/app_routes.dart';

class WelcomeController extends GetxController {
  final loadingGuest = false.obs;
  final loadingGoogle = false.obs;

  Future<void> continueAsGuest() async {
    if (loadingGuest.value) return;
    loadingGuest.value = true;
    try {
      await AuthService.to.signInAsGuest();
      Get.offAllNamed(Routes.main);
    } on FirebaseAuthException catch (e) {
      debugPrint('Guest error: ${e.code} ${e.message}');
      _error('Could not continue as guest (${e.code}).');
    } finally {
      loadingGuest.value = false;
    }
  }

  Future<void> continueWithGoogle() async {
    if (loadingGoogle.value) return;
    loadingGoogle.value = true;
    try {
      await AuthService.to.signInWithGoogle();
      Get.offAllNamed(Routes.main);
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase error: code=${e.code}, msg=${e.message}');
      // User closed the browser window: no error needed
      if (e.code == 'web-context-canceled' ||
          e.code == 'canceled' ||
          e.code == 'popup-closed-by-user') {
        return;
      }
      _error('Google sign-in failed (${e.code}).');
    } catch (e, st) {
      debugPrint('Unknown error: $e\n$st');
      _error('Something went wrong. Please try again.');
    } finally {
      loadingGoogle.value = false;
    }
  }

  void _error(String msg) => Get.snackbar(
    'Sign in',
    msg,
    snackPosition: SnackPosition.BOTTOM,
    margin: const EdgeInsets.all(16),
    backgroundColor: const Color(0xFFEF4444),
    colorText: Colors.white,
    duration: const Duration(seconds: 4),
  );
}