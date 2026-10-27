
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toefl_pro/app/core/theme/app_colors.dart';
import 'package:toefl_pro/app/core/widgets/common_widgets.dart';
import 'package:toefl_pro/app/routes/app_routes.dart';
import '../../../core/services/notification_service.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  static const _skillColors = {
    'Reading': AppColors.teal600,
    'Listening': AppColors.indigo600,
    'Speaking': AppColors.amber,
    'Writing': Color(0xFFE11D48),
  };

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        physics: const BouncingScrollPhysics(),
        children: [
       //   _header(context),
          const SizedBox(height: 18),
          _goalCard(),
          const SizedBox(height: 24),
          SectionHeader('Continue learning',
              action: 'See all', onAction: controller.openPracticeTab),
          _continueCard(context),
          const SizedBox(height: 24),
          const SectionHeader('Skill shortcuts'),
          _skillShortcuts(context),
          const SizedBox(height: 24),
          const SectionHeader('Recommended for you'),
          _recommendedCard(context),
          const SizedBox(height: 24),
          const SectionHeader('Your TOEFL readiness',
             // action: 'Details',
          /*    onAction: () => Get.toNamed(Routes.search)*/
          ), // TODO: progress route
          _readinessCard(context),
        ],
      ),
    );
  }

/*  // ───────────── Header ─────────────
  Widget _header(BuildContext context) => Row(children: [
    Obx(() {
      final photo = controller.photoUrl.value;
      return Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey, width: 1),
        ),
        child: CircleAvatar(
          radius: 23,
          backgroundColor: tint(context, AppColors.amber),
          backgroundImage: photo != null ? NetworkImage(photo) : null,
          onBackgroundImageError: photo != null ? (_, __) {} : null,
          child: photo != null
              ? null
              : const Icon(
            Icons.person_rounded,
            size: 26,
            color: AppColors.amber,
          ),
        ),
      );
    }),
    const SizedBox(width: 12),
    Expanded(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('${controller.greeting} 👋',
            style: body(12, color: muted(context))),
        Obx(() => Text(controller.name.value, style: poppins(18))),
      ]),
    ),
    const SizedBox(width: 8),
    StreamBuilder<int>(
      stream: NotificationService.to.unreadCount(),
      builder: (_, s) => _roundIcon(
        context,
        Icons.notifications_none_rounded,
            () => Get.toNamed(Routes.notifications),
        dot: (s.data ?? 0) > 0,
      ),
    ),
  ]);*/

  Widget _roundIcon(BuildContext context, IconData icon, VoidCallback onTap,
      {bool dot = false}) =>
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey),
          ),
          child: Stack(alignment: Alignment.center, children: [
            Icon(icon, size: 22),
            if (dot)
              Positioned(
                top: 10,
                right: 11,
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Theme.of(context).cardColor, width: 2),
                  ),
                ),
              ),
          ]),
        ),
      );

  // ───────────── Goal card + weekly streak (REAL data) ─────────────
  Widget _goalCard() => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.yellow),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColors.indigo600, Color(0xFF1E88E5)],
      ),
      borderRadius: BorderRadius.circular(26),
      boxShadow: [
        BoxShadow(
          color: AppColors.indigo600.withOpacity(.30),
          blurRadius: 24,
          offset: const Offset(0, 12),
        ),
      ],
    ),
    child: Obx(() {
      final done = controller.minutesDone.value;
      final goal = controller.goalMinutes.value;
      final streak = controller.streak.value;
      final week = controller.weekDone.toList();

      return Column(children: [
        Row(children: [
          ProgressRing(
            controller.goalProgress,
            size: 84,
            color: Colors.white,
            trackColor: Colors.white24,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text('$done', style: poppins(24, color: Colors.white)),
              Text('of $goal min',
                  style: body(9, color: Colors.white70)),
            ]),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Daily study goal',
                      style: body(12, color: Colors.white70)),
                  const SizedBox(height: 2),
                  Text(
                    done >= goal
                        ? 'Goal reached! 🎉'
                        : '${goal - done} min to go!',
                    style: poppins(19, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(20)),
                    child: Text(
                      streak == 0
                          ? '🔥 Start your streak today'
                          : '🔥 $streak-day streak',
                      style: body(11,
                          w: FontWeight.w600, color: Colors.white),
                    ),
                  ),
                ]),
          ),
        ]),
        const SizedBox(height: 14),
        const Divider(color: Colors.white24, height: 1),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (int i = 0; i < 7; i++)
              _dayDot(const ['M', 'T', 'W', 'T', 'F', 'S', 'S'][i], i,
                  week.length > i && week[i]),
          ],
        ),
      ]);
    }),
  );

  Widget _dayDot(String label, int i, bool done) {
    final isToday = i == controller.todayIndex;
    return SizedBox(
      width: 34,
      child: Column(children: [
        Text(label, style: body(10, color: Colors.white70)),
        const SizedBox(height: 4),
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: done
                ? Colors.white
                : Colors.white.withOpacity(isToday ? 0 : .18),
            border: isToday && !done
                ? Border.all(color: Colors.white, width: 2)
                : null,
          ),
          child: done
              ? const Icon(Icons.check_rounded,
              size: 16, color: AppColors.indigo600)
              : null,
        ),
      ]),
    );
  }

  // ───────────── Continue learning ─────────────
  Widget _continueCard(BuildContext context) => AppCard(
    onTap: () => Get.toNamed(Routes.reading),
   // borderColor: Colors.grey,
    child: Column(children: [
      Row(children: [
        const IconBadge(Icons.menu_book_rounded,
            color: Color(0xFF1E88E5), size: 48),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Reading · Urban Farming', style: poppins(14)),
                const SizedBox(height: 2),
                Text('Passage 2 · Q 6 of 13 · ~8 min left',
                    style: body(11.5, color: muted(context))),
              ]),
        ),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF1E88E5),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                  color: AppColors.indigo600.withOpacity(.35),
                  blurRadius: 12,
                  offset: const Offset(0, 6))
            ],
          ),
          child: const Icon(Icons.play_arrow_rounded, color: Colors.white),
        ),
      ]),
      const SizedBox(height: 12),
      _bar(context, 6 / 13, AppColors.teal600),
    ]),
  );

  Widget _bar(BuildContext context, double value, Color color) => ClipRRect(
    borderRadius: BorderRadius.circular(6),
    child: LinearProgressIndicator(
      value: value,
      minHeight: 6,
      color: color,
      backgroundColor: color.withOpacity(.12),
    ),
  );

  // ───────────── Readiness (REAL data) ─────────────
  Widget _readinessCard(BuildContext context) => AppCard(
   // borderColor: Colors.grey,
    child: Obx(() {
      final est = controller.estimatedScore.value;
      final ready = controller.readiness.value;
      final toGo = (controller.targetScore - est).clamp(0, 120).toInt();
      final weakest = controller.weakestSkill;

      return Column(children: [
        Row(children: [
          ProgressRing(ready / 100,
              color: const Color(0xFF1E88E5),
              size: 64,
              child: Text('$ready%', style: poppins(14))),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Target score ${controller.targetScore}/120',
                      style: poppins(14)),
                  const SizedBox(height: 4),
                  Text(
                    est == 0
                        ? 'Finish a test to see your estimate'
                        : 'Estimated now: $est · $toGo points to go',
                    style: body(12, color: muted(context)),
                  ),
                ]),
          ),
        ]),
        const SizedBox(height: 14),
        for (final skill in _skillColors.keys)
          Padding(
            padding: const EdgeInsets.only(bottom: 9),
            child: Row(children: [
              SizedBox(width: 66, child: Text(skill, style: body(11.5))),
              Expanded(
                child: _bar(
                  context,
                  (controller.skillScores[skill] ?? 0) / 100,
                  _skillColors[skill]!,
                ),
              ),
              SizedBox(
                width: 28,
                child: Text('${controller.skillScores[skill] ?? '-'}',
                    textAlign: TextAlign.right,
                    style: body(11.5,
                        w: FontWeight.w700,
                        color: skill == weakest
                            ? _skillColors[skill]
                            : null)),
              ),
            ]),
          ),
      ]);
    }),
  );

  // ───────────── Recommended ─────────────
  Widget _recommendedCard(BuildContext context) {
    const rose = Color(0xFF1E88E5);
    return AppCard(
     // borderColor: Colors.grey,
      onTap: () {}, // TODO: Get.toNamed(Routes.writing)
      child: Row(children: [
        const IconBadge(Icons.edit_rounded, color: rose, size: 46),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Obx(() => Text('${controller.weakestSkill} · Task 2',
                style: poppins(14))),
            const SizedBox(height: 2),
            Text('Your weakest skill · 10 min',
                style: body(11.5, color: muted(context))),
          ]),
        ),
        FilledButton(
          onPressed: () {},
          style: FilledButton.styleFrom(
            backgroundColor: rose,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
            padding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          child: Text('Start',
              style: body(12, w: FontWeight.w600, color: Colors.white)),
        ),
      ]),
    );
  }

  // ───────────── Skill shortcuts (REAL scores) ─────────────
  Widget _skillShortcuts(BuildContext context) => Row(
    children: [
      for (final s in controller.skills.take(4))
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: AppCard(
             // borderColor: Colors.grey,
              onTap: () => Get.toNamed(s.route),
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (s.assetImage != null && s.assetImage!.isNotEmpty)
                    Image.asset(
                      s.assetImage!,
                      width: 44,
                      height: 44,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          IconBadge(
                            s.icon ?? Icons.school_rounded,
                            color: s.color,
                            size: 44,
                          ),
                    )
                  else
                    IconBadge(
                      s.icon ?? Icons.school_rounded,
                      color: s.color,
                      size: 44,
                    ),
                  const SizedBox(height: 6),
                  Text(
                    s.name,
                    style: body(11.5, w: FontWeight.w600),
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Obx(() => Text(
                    '${controller.skillScores[s.name] ?? '-'}',
                    style: body(10, color: muted(context)),
                  )),
                ],
              ),
            ),
          ),
        ),
    ],
  );
}