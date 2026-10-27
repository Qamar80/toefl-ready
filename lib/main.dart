import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toefl_pro/app/core/theme/app_theme.dart';
import 'package:toefl_pro/app/routes/app_pages.dart';
import 'package:toefl_pro/app/routes/app_routes.dart';

import 'app/core/services/auth_service.dart';
import 'app/core/services/notification_service.dart';

void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    final app = await Firebase.initializeApp();
    debugPrint('Firebase connected: ${app.name}, project: ${app.options.projectId}');
  } catch (e) {
    debugPrint('Firebase connection failed: $e');
  }
  await Get.putAsync(() => AuthService().init(), permanent: true);
  await Get.putAsync(() => NotificationService().init(), permanent: true);

  runApp(const ToeflProApp());
}

class ToeflProApp extends StatelessWidget {
  const ToeflProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'TOEFL Pro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.light,
      initialRoute: Routes.splash,
      getPages: AppPages.pages,
      defaultTransition: Transition.cupertino,
    );
  }
}
