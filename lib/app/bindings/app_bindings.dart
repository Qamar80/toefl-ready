import 'package:get/get.dart';
import 'package:toefl_pro/app/modules/home/controllers/home_controller.dart';
import 'package:toefl_pro/app/modules/listening/controllers/listening_controller.dart';

import 'package:toefl_pro/app/modules/practice/controllers/practice_controller.dart';
import 'package:toefl_pro/app/modules/profile/controllers/profile_controller.dart';
import 'package:toefl_pro/app/modules/progress/controllers/progress_controller.dart';
import 'package:toefl_pro/app/modules/reading/controllers/reading_controller.dart';
import 'package:toefl_pro/app/modules/speaking/controllers/speaking_controller.dart';
import 'package:toefl_pro/app/modules/splash/controllers/splash_controller.dart';
import 'package:toefl_pro/app/modules/writing/controllers/writing_controller.dart';

import '../modules/bottom_bar/controllers/main_controller.dart';

class SplashBinding extends Bindings {
  @override
  // Get.put (not lazyPut): the splash view never reads `controller`, so a lazy
  // controller would never be created and the timer would never start.
  void dependencies() => Get.put(SplashController());
}


/// Bottom-nav shell + the five tab controllers.
class MainBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MainController());
    Get.lazyPut(() => HomeController());
    Get.lazyPut(() => PracticeController());
   // Get.lazyPut(() => MockController());
    Get.lazyPut(() => ProgressController());
    Get.lazyPut(() => ProfileController());
  }
}

class ReadingBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(() => ReadingController());
}

class ListeningBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(() => ListeningController());
}

class SpeakingBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(() => SpeakingController());
}

class WritingBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(() => WritingController());
}














