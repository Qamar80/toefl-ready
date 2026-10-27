import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toefl_pro/app/core/theme/app_colors.dart';
import 'package:toefl_pro/app/core/widgets/common_widgets.dart';
import '../controllers/progress_controller.dart';

class ProgressView extends GetView<ProgressController> {
  const ProgressView({super.key});

  static const _skillColors = {
    'Reading': AppColors.teal600,
    'Listening': AppColors.indigo600,
    'Speaking': AppColors.amber,
    'Writing': Color(0xFFE11D48),
  };

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Obx(() {
        final weekly = controller.weekly.toList();
        final maxMin = weekly.fold<double>(0, (m, v) => v > m ? v : m);
        final monthDone = controller.monthDone.toList();

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          physics: const BouncingScrollPhysics(),
          children: [
            Text('Progress', style: poppins(24, w: FontWeight.w700)),
            const SizedBox(height: 12),
            SegmentedButton<int>(
              showSelectedIcon: false,
              segments: [
                for (int i = 0; i < controller.ranges.length; i++)
                  ButtonSegment(value: i, label: Text(controller.ranges[i])),
              ],
              selected: {controller.range.value},
              onSelectionChanged: (s) => controller.range.value = s.first,
            ),
            const SizedBox(height: 16),

            // ── Stat cards (real data)
            Row(children: [
              _stat(context, Icons.timer_outlined, controller.studiedLabel.value,
                  'Studied', AppColors.indigo600),
              const SizedBox(width: 10),
              _stat(context, Icons.check_circle_outline, controller.accuracyLabel.value,
                  'Avg score', AppColors.teal600),
              const SizedBox(width: 10),
              _stat(context, Icons.local_fire_department_outlined,
                  '${controller.streak.value}', 'Day streak', AppColors.amber),
            ]),
            const SizedBox(height: 20),

            // ── Weekly activity (real minutes)
            const SectionHeader('Weekly study activity'),
            AppCard(
             // borderColor: Colors.grey,
              child: SizedBox(
                height: 140,
                child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  for (int i = 0; i < weekly.length; i++)
                    Expanded(
                      child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                        Text(
                          weekly[i] > 0 ? '${weekly[i].round()}m' : '',
                          style: body(9.5, color: muted(context)),
                        ),
                        const SizedBox(height: 3),
                        Container(
                          height: weekly[i] <= 0
                              ? 4
                              : (weekly[i] / (maxMin == 0 ? 1 : maxMin) * 85).clamp(6.0, 85.0),
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: i == controller.todayIndex
                                ? AppColors.indigo600
                                : AppColors.indigo600.withOpacity(weekly[i] > 0 ? .45 : .15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(controller.days[i], style: body(11, color: muted(context))),
                      ]),
                    ),
                ]),
              ),
            ),
            const SizedBox(height: 20),

            // ── Skill performance (same scores as Home)
            const SectionHeader('Skill performance'),
            AppCard(
             // borderColor: Colors.grey,
              child: Column(children: [
                for (final name in controller.skillNames)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(children: [
                      SizedBox(width: 74, child: Text(name, style: body(12.5))),
                      Expanded(
                        child: ThinProgress(controller.skills[name] ?? 0,
                            color: _skillColors[name]!),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 36,
                        child: Text(
                          '${((controller.skills[name] ?? 0) * 100).round()}%',
                          textAlign: TextAlign.right,
                          style: body(12, w: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(width: 6),
                      SizedBox(
                        width: 28,
                        child: Text(
                          controller.skillDelta[name] ?? '–',
                          textAlign: TextAlign.right,
                          style: body(
                            11,
                            color: (controller.skillDelta[name] ?? '').startsWith('-')
                                ? const Color(0xFFE11D48)
                                : AppColors.teal600,
                          ),
                        ),
                      ),
                    ]),
                  ),
              ]),
            ),
            const SizedBox(height: 20),

            // ── Month streak calendar (real days)
            SectionHeader('${controller.monthName} streak',
                action: 'Best: ${controller.bestStreak.value}'),
            AppCard(
             // borderColor: Colors.grey,
              child: Wrap(spacing: 6, runSpacing: 6, children: [
                for (int i = 0; i < monthDone.length; i++)
                  Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: monthDone[i]
                          ? AppColors.teal500
                          : tint(context, AppColors.grey),
                      borderRadius: BorderRadius.circular(8),
                      border: (i + 1) == controller.todayDay
                          ? Border.all(color: AppColors.teal600, width: 2)
                          : null,
                    ),
                    child: Text(
                      '${i + 1}',
                      style: body(10,
                          color: monthDone[i] ? Colors.white : muted(context)),
                    ),
                  ),
              ]),
            ),
            const SizedBox(height: 16),
          ],
        );
      }),
    );
  }

  Widget _stat(BuildContext c, IconData i, String v, String l, Color color) => Expanded(
    child: AppCard(
    //  borderColor: Colors.grey,
      padding: const EdgeInsets.all(12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        IconBadge(i, color: color, size: 30),
        const SizedBox(height: 8),
        Text(v, style: poppins(16)),
        Text(l, style: body(11, color: muted(c))),
      ]),
    ),
  );
}