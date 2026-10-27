import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:toefl_pro/app/core/theme/app_colors.dart';
import 'package:toefl_pro/app/core/widgets/common_widgets.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../routes/app_routes.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  static const _blue = Color(0xFF1E88E5);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            Text('Profile', style: poppins(24, w: FontWeight.w700)),
            const SizedBox(height: 14),

            // ───────────── User card ─────────────
            Obx(() {
              final photo = controller.photoUrl;
              return AppCard(
                borderColor: Colors.grey,
                child: Row(children: [
                 Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.grey,
                        width: 1,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 26,
                      backgroundColor: tint(context, AppColors.amber),
                      backgroundImage: photo != null ? NetworkImage(photo) : null,
                      child: photo != null
                          ? null
                          : controller.isGuest
                          ? const Icon(
                        Icons.person_rounded,
                        color: AppColors.amber,
                        size: 28,
                      )
                          : Text(
                        controller.initials,
                        style: poppins(16, color: AppColors.amber),
                      ),
                    ),
                  ),
             /*     CircleAvatar(
                    radius: 26,

                    backgroundColor: tint(context, AppColors.amber),
                    backgroundImage: photo != null ? NetworkImage(photo) : null,
                    child: photo != null
                        ? null
                        : controller.isGuest
                        ? const Icon(Icons.person_rounded,
                        color: AppColors.amber, size: 28)
                        : Text(controller.initials,
                        style: poppins(16, color: AppColors.amber)),
                  ),*/
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(controller.name,
                              style: poppins(16),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                          Text(
                            controller.isGuest
                                ? 'Guest account'
                                : (controller.email ?? ''),
                            style: body(12, color: muted(context)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      /*    const SizedBox(height: 2),
                          Text('TOEFL iBT · Target score 100',
                              style: body(11.5, color: muted(context))),*/
                        ]),
                  ),
                ]),
              );
            }),

            // ───────────── Guest banner ─────────────
            Obx(() {
              if (!controller.isGuest) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(top: 16),
                child: AppCard(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Keep your scores safe', style: poppins(14)),
                        const SizedBox(height: 4),
                        Text(
                          'Sign in with Google to sync your score history. '
                              'Your current guest scores are kept.',
                          style: body(12, color: muted(context)),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 46,
                          child: FilledButton.icon(
                            onPressed: controller.signingIn.value
                                ? null
                                : controller.signInWithGoogle,
                            style: FilledButton.styleFrom(
                              backgroundColor: _blue,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                            ),
                            icon: controller.signingIn.value
                                ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                                : const Icon(Icons.person_outline_rounded,
                                size: 20),
                            label: Text('Continue with Google',
                                style: body(13,
                                    w: FontWeight.w600, color: Colors.white)),
                          ),
                        ),
                      ]),
                ),
              );
            }),

            const SizedBox(height: 6),



            // ───────────── Theme ─────────────
            AppCard(

              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Theme', style: poppins(14)),
                    const SizedBox(height: 10),
                    Obx(() => SizedBox(
                      width: double.infinity,
                      child: SegmentedButton<ThemeMode>(
                        showSelectedIcon: false,
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.resolveWith<Color?>(
                                (states) {
                              if (states.contains(WidgetState.selected)) {
                                return Colors.lightBlue; // Selected color
                              }
                              return Colors.transparent; // Unselected color
                            },
                          ),
                          foregroundColor: WidgetStateProperty.resolveWith<Color?>(
                                (states) {
                              if (states.contains(WidgetState.selected)) {
                                return Colors.white; // Selected text/icon
                              }
                              return Colors.grey; // Unselected text/icon
                            },
                          ),
                        ),
                        segments: const [
                          ButtonSegment(
                            value: ThemeMode.light,
                            icon: Icon(Icons.light_mode_outlined),
                            label: Text('Light'),
                          ),
                          ButtonSegment(
                            value: ThemeMode.dark,
                            icon: Icon(Icons.dark_mode_outlined),
                            label: Text('Dark'),
                          ),
                          ButtonSegment(
                            value: ThemeMode.system,
                            icon: Icon(Icons.phone_android),
                            label: Text('System'),
                          ),
                        ],
                        selected: {controller.themeMode.value},
                        onSelectionChanged: (s) => controller.setTheme(s.first),
                      ),
                    ))
                  /*  Obx(() => SizedBox(
                      width: double.infinity,
                      child: SegmentedButton<ThemeMode>(
                        showSelectedIcon: false,
                        segments: const [
                          ButtonSegment(

                              value: ThemeMode.light,
                              icon: Icon(Icons.light_mode_outlined),
                              label: Text('Light')),
                          ButtonSegment(
                              value: ThemeMode.dark,
                              icon: Icon(Icons.dark_mode_outlined),
                              label: Text('Dark')),
                          ButtonSegment(
                              value: ThemeMode.system,
                              icon: Icon(Icons.phone_android),
                              label: Text('System')),
                        ],
                        selected: {controller.themeMode.value},
                        onSelectionChanged: (s) =>
                            controller.setTheme(s.first),
                      ),
                    )),*/
                  ]),
            ),
            const SizedBox(height: 16),

            // ───────────── Settings list ─────────────
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              child: Column(children: [
                Obx(() => Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey.shade300,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SwitchListTile.adaptive(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    secondary: const IconBadge(
                      Icons.notifications_none_rounded,
                      color: AppColors.blueColor,
                      size: 36,
                    ),
                    title: Text('Study reminder', style: poppins(13.5)),
                    subtitle: Text(
                      controller.reminder.value
                          ? 'Every day · ${controller.reminderTime.value.format(context)}'
                          : 'Off',
                      style: body(11.5, color: muted(context)),
                    ),
                    value: controller.reminder.value,
                    activeTrackColor: AppColors.teal600,
                    onChanged: controller.toggleReminder,
                  ),
                )),
           /*     Obx(() => SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  secondary: const IconBadge(Icons.notifications_none_rounded,
                      color: AppColors.blueColor, size: 36),
                  title: Text('Study reminder', style: poppins(13.5)),
                  subtitle: Text(
                    controller.reminder.value
                        ? 'Every day · ${controller.reminderTime.value.format(context)}'
                        : 'Off',
                    style: body(11.5, color: muted(context)),
                  ),
                  value: controller.reminder.value,
                  activeColor: AppColors.teal600,
                  onChanged: controller.toggleReminder,
                )),*/
                Obx(() => _tile(
                  context,
                  Icons.schedule_rounded,

                  'Reminder time',
                  controller.reminderTime.value.format(context),
                      () => controller.pickReminderTime(context),
                )),
                const SizedBox(height: 5,),
                _tile(context, Icons.notifications_active_outlined, 'Notifications',
                    'Reminders & updates', () => Get.toNamed(Routes.notifications)),
    /*            Obx(() => SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  secondary: const IconBadge(
                      Icons.notifications_none_rounded,
                      color: AppColors.indigo600,
                      size: 36),
                  title: Text('Study reminder', style: poppins(13.5)),
                  subtitle: Text('Every day · 7:30 PM',
                      style: body(11.5, color: muted(context))),
                  value: controller.reminder.value,
                  activeColor: AppColors.teal600,
                  onChanged: (v) => controller.reminder.value = v,
                )),*/


                const SizedBox(height: 5,),


                _tile(
                  context,
                  Icons.shield_outlined,
                  'Privacy & data',
                  'Scores sync to your account',
                      () async {
                    final Uri url = Uri.parse(
                      'https://qatechstudio.blogspot.com/2026/10/toefl-ready.html',
                    );

                    if (await canLaunchUrl(url)) {
                      await launchUrl(
                        url,
                        mode: LaunchMode.externalApplication,
                      );
                    } else {
                      debugPrint('Could not open Privacy Policy');
                    }
                  },
                ),
              /*  _tile(context, Icons.shield_outlined, 'Privacy & data',
                    'Scores sync to your account', () {


                    }),*/

              ]),
            ),
            const SizedBox(height: 16),

            // ───────────── Sign out ─────────────
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed:(){
                  Fluttertoast.showToast(
                    msg: "You are Not Login",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 2,
                    backgroundColor: Colors.black,
                    textColor: Colors.white,
                    fontSize: 16.0,
                  );
                  //controller.confirmSignOut,
                },
                icon: const Icon(Icons.logout_rounded, size: 20),
                label: Text('Sign out', style: body(13, w: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFEF4444),
                  side: const BorderSide(color: Color(0xFFEF4444)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
                child: Text('♥ Every feature is free · No ads, ever',
                    style: body(12, color: AppColors.teal600))),
          ]),
    );
  }
  Widget _tile(
      BuildContext c,
      IconData i,
      String t,
      String s,
      VoidCallback onTap,
      ) =>
      Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey.shade300,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          onTap: onTap,
          leading: IconBadge(i, color: AppColors.blueColor, size: 36),
          title: Text(t, style: poppins(13.5)),
          subtitle: Text(s, style: body(11.5, color: muted(c))),
          trailing: const Icon(Icons.chevron_right_rounded),
        ),
      );
/*  Widget _tile(BuildContext c, IconData i, String t, String s,
      VoidCallback onTap) =>
      ListTile(

        contentPadding: EdgeInsets.zero,
        onTap: onTap,
        leading: IconBadge(i, color: AppColors.blueColor, size: 36),
        title: Text(t, style: poppins(13.5)),

        subtitle: Text(s, style: body(11.5, color: muted(c))),
        trailing: const Icon(Icons.chevron_right_rounded),
      );*/
}