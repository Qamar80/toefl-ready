  import 'package:flutter/material.dart';
  import 'package:get/get.dart';
  import 'package:toefl_pro/app/core/widgets/common_widgets.dart';
  import '../controllers/splash_controller.dart';

  class SplashView extends GetView<SplashController> {
    const SplashView({super.key});

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        body: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF42A5F5),
                Color(0xFF1E88E5),
                Color(0xFF0D47A1),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Column(children: [
              const Spacer(flex: 3),
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: Colors.white,
                    border: Border.all(
                      color: Colors.grey,
                      width: 0.6
                    ),
                  borderRadius: BorderRadius.circular(26),
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.asset(
                  'assets/images/icon.png',
                  width: 96,
                  height: 96,
                  fit: BoxFit.cover,
                ),
              ),

              const SizedBox(height: 22),
              RichText(
                text: TextSpan(style: poppins(30, w: FontWeight.w700, color: Colors.white), children: const [
                  TextSpan(text: 'TOEFL'),
                  TextSpan(text: ' Practice', style: TextStyle(color: Colors.white)),
                ]),
              ),
              const SizedBox(height: 8),
              Text('Practice Smart. Score Confidently.', style: body(14, color: Colors.white70)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.14), borderRadius: BorderRadius.circular(20)),
                child: Text('TOEFL iBT', style: body(11.5, w: FontWeight.w600, color: Colors.white)),
              ),
              const Spacer(flex: 3),
              Text('100% free · No ads · No subscriptions', style: body(11.5, color: Colors.white60)),
              const SizedBox(height: 24),
            ]),
          ),
        ),
      );
    }
  }
