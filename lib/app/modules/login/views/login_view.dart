import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toefl_pro/app/core/widgets/common_widgets.dart';
import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  static const _blue = Color(0xFF1E88E5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
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
          bottom: false,
          child: Column(children: [
            _header(),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    24,
                    28,
                    24,
                    24 + MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: _form(context),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  // ───────────── Header ─────────────
  Widget _header() => Padding(
    padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
    child: Column(children: [
      Container(
        width: 76,
        height: 76,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey, width: 0.6),
          borderRadius: BorderRadius.circular(22),
        ),
        clipBehavior: Clip.antiAlias,
        child: Image.asset('assets/images/icon.png', fit: BoxFit.cover),
      ),
      const SizedBox(height: 16),
      Text('Welcome back 👋', style: poppins(24, w: FontWeight.w700, color: Colors.white)),
      const SizedBox(height: 6),
      Text('Log in to continue your TOEFL practice',
          style: body(13, color: Colors.white70)),
    ]),
  );

  // ───────────── Form ─────────────
  Widget _form(BuildContext context) => Form(
    key: controller.formKey,
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Email', style: body(12.5, w: FontWeight.w600)),
      const SizedBox(height: 8),
      TextFormField(
        controller: controller.emailC,
        validator: controller.validateEmail,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.next,
        autofillHints: const [AutofillHints.email],
        decoration: _input(context, 'you@example.com', Icons.mail_outline_rounded),
      ),
      const SizedBox(height: 18),
      Text('Password', style: body(12.5, w: FontWeight.w600)),
      const SizedBox(height: 8),
      Obx(() => TextFormField(
        controller: controller.passC,
        validator: controller.validatePassword,
        obscureText: controller.obscure.value,
        textInputAction: TextInputAction.done,
        autofillHints: const [AutofillHints.password],
        onFieldSubmitted: (_) => controller.login(),
        decoration: _input(
          context,
          'Enter your password',
          Icons.lock_outline_rounded,
          suffix: IconButton(
            icon: Icon(
              controller.obscure.value
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              size: 20,
            ),
            onPressed: () => controller.obscure.toggle(),
          ),
        ),
      )),
      Align(
        alignment: Alignment.centerRight,
        child: TextButton(
          onPressed: controller.forgotPassword,
          child: Text('Forgot password?',
              style: body(12, w: FontWeight.w600, color: _blue)),
        ),
      ),
      const SizedBox(height: 8),
      Obx(() => SizedBox(
        width: double.infinity,
        height: 52,
        child: FilledButton(
          onPressed: controller.loading.value ? null : controller.login,
          style: FilledButton.styleFrom(
            backgroundColor: _blue,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: controller.loading.value
              ? const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
          )
              : Text('Log in',
              style: body(14, w: FontWeight.w600, color: Colors.white)),
        ),
      )),
      const SizedBox(height: 24),
      Center(
        child: Text('100% free · No ads · No subscriptions',
            style: body(11.5, color: muted(context))),
      ),
    ]),
  );

  InputDecoration _input(BuildContext context, String hint, IconData icon, {Widget? suffix}) {
    OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: c, width: w),
    );
    return InputDecoration(
      hintText: hint,
      hintStyle: body(13, color: muted(context)),
      prefixIcon: Icon(icon, size: 20),
      suffixIcon: suffix,
      filled: true,
      fillColor: Theme.of(context).cardColor,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      enabledBorder: border(Colors.grey.shade400),
      focusedBorder: border(_blue, 1.6),
      errorBorder: border(const Color(0xFFEF4444)),
      focusedErrorBorder: border(const Color(0xFFEF4444), 1.6),
    );
  }
}