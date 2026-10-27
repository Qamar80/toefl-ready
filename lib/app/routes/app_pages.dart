import 'package:get/get.dart';
import 'package:toefl_pro/app/bindings/app_bindings.dart';
import 'package:toefl_pro/app/modules/listening/views/listening_view.dart';
import 'package:toefl_pro/app/modules/login/bindings/login_binding.dart';
import 'package:toefl_pro/app/modules/login/views/login_view.dart';
import 'package:toefl_pro/app/modules/notifications/bindings/notifications_binding.dart';
import 'package:toefl_pro/app/modules/notifications/views/notifications_view.dart';
import 'package:toefl_pro/app/modules/reading/views/reading_view.dart';
import 'package:toefl_pro/app/modules/speaking/views/speaking_view.dart';
import 'package:toefl_pro/app/modules/splash/views/splash_view.dart';
import 'package:toefl_pro/app/modules/writing/views/writing_view.dart';
import '../modules/bottom_bar/views/main_view.dart';
import '../modules/welcome/binding/welcome_binding.dart';
import '../modules/welcome/views/welcome_view.dart';
import 'app_routes.dart';

class AppPages {
  static final pages = <GetPage>[
    GetPage(name: Routes.splash, page: () => const SplashView(), binding: SplashBinding()),
   // GetPage(name: Routes.onboarding, page: () => const OnboardingView(), binding: OnboardingBinding()),
    GetPage(name: Routes.main, page: () => const MainView(), binding: MainBinding()),
    GetPage(name: Routes.welcome, page: () => const WelcomeView(), binding: WelcomeBinding()),
    GetPage(name: Routes.login, page: () => const LoginView(), binding: LoginBinding()),
    GetPage(name: Routes.notifications, page: () => const NotificationsView(), binding: NotificationsBinding()),
    GetPage(name: Routes.reading, page: () => const ReadingView(), binding: ReadingBinding()),
    GetPage(name: Routes.listening, page: () => const ListeningView(), binding: ListeningBinding()),
    GetPage(name: Routes.speaking, page: () => const SpeakingView(), binding: SpeakingBinding()),
    GetPage(name: Routes.writing, page: () => const WritingView(), binding: WritingBinding()),
    //GetPage(name: Routes.results, page: () => const ResultsView(), binding: ResultsBinding()),
  ];
}
