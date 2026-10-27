import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toefl_pro/app/core/theme/app_colors.dart';
import 'package:toefl_pro/app/core/widgets/common_widgets.dart';
import 'package:toefl_pro/app/modules/home/views/home_view.dart';
import 'package:toefl_pro/app/modules/practice/views/practice_view.dart';
import 'package:toefl_pro/app/modules/profile/views/profile_view.dart';
import 'package:toefl_pro/app/modules/progress/views/progress_view.dart';
import '../controllers/main_controller.dart';

class MainView extends GetView<MainController> {
  const MainView({super.key});

  static const _tabs = [
    HomeView(),
    PracticeView(),
    ProgressView(),
    ProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.blueColor;
    final surface = Theme.of(context).colorScheme.surface;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() => Scaffold(
      body: IndexedStack(index: controller.tab.value, children: _tabs),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? .35 : .08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: NavigationBarTheme(
            data: NavigationBarThemeData(
              height: 66,
              elevation: 0,
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              indicatorColor: primary.withOpacity(.12),
              indicatorShape: const StadiumBorder(),
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              labelTextStyle: WidgetStateProperty.resolveWith<TextStyle?>(
                    (states) {
                  final selected = states.contains(WidgetState.selected);
                  return TextStyle(
                    fontSize: 11.5,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? primary : muted(context),
                  );
                },
              ),
              iconTheme: WidgetStateProperty.resolveWith<IconThemeData?>(
                    (states) => IconThemeData(
                  size: 24,
                  color: states.contains(WidgetState.selected)
                      ? primary
                      : muted(context),
                ),
              ),
            ),
            child: NavigationBar(
              selectedIndex: controller.tab.value,
              onDestinationSelected: controller.changeTab,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home_rounded),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.menu_book_outlined),
                  selectedIcon: Icon(Icons.menu_book_rounded),
                  label: 'Practice',
                ),
                NavigationDestination(
                  icon: Icon(Icons.bar_chart_outlined),
                  selectedIcon: Icon(Icons.bar_chart_rounded),
                  label: 'Progress',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person_rounded),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    ));
  }
}