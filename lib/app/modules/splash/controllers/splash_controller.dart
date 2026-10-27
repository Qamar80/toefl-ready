import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:toefl_pro/app/routes/app_routes.dart';

class SplashController extends GetxController {
  @override
  void onReady() {
    super.onReady();
    Future.delayed(const Duration(seconds: 2), _route);
  }

  void _route() {
    final user = FirebaseAuth.instance.currentUser;
    Get.offAllNamed(user != null ? Routes.main : Routes.main);
   // Get.offAllNamed(user != null ? Routes.main : Routes.welcome);
  }
/*
  void _route() {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Already logged in
      Get.offAllNamed(Routes.main);
    } else {
      // Not logged in
      Get.offAllNamed(Routes.login);
      // If you want onboarding first for new users, use Routes.onboarding instead
    }
  }*/
}