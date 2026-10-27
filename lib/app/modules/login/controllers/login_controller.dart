import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toefl_pro/app/routes/app_routes.dart';

class LoginController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final emailC = TextEditingController();
  final passC = TextEditingController();

  final obscure = true.obs;
  final loading = false.obs;

  final _auth = FirebaseAuth.instance;

  String? validateEmail(String? v) {
    final value = v?.trim() ?? '';
    if (value.isEmpty) return 'Please enter your email';
    if (!GetUtils.isEmail(value)) return 'Enter a valid email address';
    return null;
  }

  String? validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Please enter your password';
    if (v.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  Future<void> login() async {
    if (!formKey.currentState!.validate()) return;
    FocusManager.instance.primaryFocus?.unfocus();
    loading.value = true;
    try {
      await _auth.signInWithEmailAndPassword(
        email: emailC.text.trim(),
        password: passC.text,
      );
      // TODO: replace with your main/home route
      Get.offAllNamed(Routes.main);
    } on FirebaseAuthException catch (e) {
      _showError(_message(e.code));
    } catch (_) {
      _showError('Something went wrong. Please try again.');
    } finally {
      loading.value = false;
    }
  }

  Future<void> forgotPassword() async {
    final email = emailC.text.trim();
    if (!GetUtils.isEmail(email)) {
      _showError('Enter your email above first, then tap "Forgot password?"');
      return;
    }
    try {
      await _auth.sendPasswordResetEmail(email: email);
      Get.snackbar(
        'Email sent',
        'Check $email for a password reset link.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } on FirebaseAuthException catch (e) {
      _showError(_message(e.code));
    }
  }

  void _showError(String msg) => Get.snackbar(
    'Login failed',
    msg,
    snackPosition: SnackPosition.BOTTOM,
    margin: const EdgeInsets.all(16),
    backgroundColor: const Color(0xFFEF4444),
    colorText: Colors.white,
  );

  String _message(String code) {
    switch (code) {
      case 'invalid-email':
        return 'That email address is not valid.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'No internet connection.';
      default:
        return 'Login failed ($code).';
    }
  }

  @override
  void onClose() {
    emailC.dispose();
    passC.dispose();
    super.onClose();
  }
}