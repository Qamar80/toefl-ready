import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toefl_pro/app/core/widgets/common_widgets.dart';
import '../controllers/welcome_controller.dart';

class WelcomeView extends GetView<WelcomeController> {
  const WelcomeView({super.key});

  static const _blue = Color(0xFF1E88E5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF42A5F5), Color(0xFF1E88E5), Color(0xFF0D47A1)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(children: [
            const Spacer(flex: 2),
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey, width: 0.6),
                borderRadius: BorderRadius.circular(24),
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.asset('assets/images/icon.png', fit: BoxFit.cover),
            ),
            const SizedBox(height: 18),
            Text('TOEFL Practice',
                style: poppins(26, w: FontWeight.w700, color: Colors.white)),
            const SizedBox(height: 6),
            Text('Practice Smart. Score Confidently.',
                style: body(13.5, color: Colors.white70)),
            const Spacer(flex: 2),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius:
                const BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                // Continue as Guest
            /*    Obx(() => _option(
                  context,
                  icon: Icons.play_circle_fill_rounded,
                  iconColor: const Color(0xFF16A34A),
                  title: 'Continue as Guest',
                  subtitle: 'Practise immediately and save scores',
                  loading: controller.loadingGuest.value,
                  onTap: controller.continueAsGuest,
                )),
                const SizedBox(height: 12),*/
                // Continue with Google
                Obx(() => _option(
                  context,
                  assetImage: 'assets/images/google.png',

                 // icon: Icons.person_outline_rounded,
                  iconColor: _blue,
                  title: 'Continue with Google',
                  subtitle: 'Sign in and sync score history',
                  loading: controller.loadingGoogle.value,
                  onTap: controller.continueWithGoogle,
                )),
                const SizedBox(height: 18),
                Text('100% free · No ads · No subscriptions',
                    style: body(11.5, color: muted(context))),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _option(
      BuildContext context, {
        IconData? icon,
        String? assetImage,
        required Color iconColor,
        required String title,
        required String subtitle,
        required bool loading,
        required VoidCallback onTap,
      }) =>
      InkWell(
        onTap: loading ? null : onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.grey.shade400),
          ),
          child: Row(
            children: [
              if (loading)
                SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    color: iconColor,
                  ),
                )
              else if (assetImage != null)
                Image.asset(
                  assetImage,
                  width: 28,
                  height: 28,
                  fit: BoxFit.contain,
                )
              else
                Icon(
                  icon ?? Icons.help_outline_rounded,
                  size: 28,
                  color: iconColor,
                ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: poppins(14)),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: body(11.5, color: muted(context)),
                    ),
                  ],
                ),
              ),

              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      );
}