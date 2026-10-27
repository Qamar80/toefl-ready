import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toefl_pro/app/core/theme/app_colors.dart';
import 'package:toefl_pro/app/core/widgets/common_widgets.dart';
import 'package:toefl_pro/app/data/models/models.dart'; // for Skill
import 'package:toefl_pro/app/routes/app_routes.dart';
import '../controllers/practice_controller.dart';

// ---- Change these to resize the images ----
const double kSkillImageHeight = 90;
const double kSkillImageWidth = 90;
const double kSkillCardAspectRatio = .9;
const BoxFit kSkillImageFit = BoxFit.cover;
// -------------------------------------------

class PracticeView extends GetView<PracticeController> {
  const PracticeView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(padding: const EdgeInsets.fromLTRB(20, 12, 20, 24), children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Practice', style: poppins(24, w: FontWeight.w700)),
        ]),
        const SizedBox(height: 4),
        Text('TOEFL iBT skill drills', style: body(13, color: muted(context))),
        const SizedBox(height: 16),
        AppCard(
          color: tint(context, AppColors.teal600),
          borderColor: AppColors.teal500.withOpacity(.4),
          onTap: () => Get.toNamed(Routes.writing),
          child: Row(children: [
            const Icon(Icons.auto_awesome_rounded, color: AppColors.teal600),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Recommended for you', style: poppins(13.5)),
                Text('Writing is your weakest skill — try Task 2.',
                    style: body(12, color: muted(context))),
              ]),
            ),
            const Icon(Icons.chevron_right_rounded),
          ]),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: kSkillCardAspectRatio,
          children: [
            for (final s in controller.skills) _SkillCard(skill: s),
          ],
        ),
      ]),
    );
  }
}

class _SkillCard extends GetView<PracticeController> {
  const _SkillCard({required this.skill});
  final Skill skill;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () => controller.open(skill),
      child: Obx(() {
        final percent = controller.percentOf(skill);
        final progress = controller.progressOf(skill);

        return Stack(children: [
          // Main content
          Positioned.fill(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Center(
                child: SizedBox(
                  height: kSkillImageHeight,
                  width: kSkillImageWidth,
                  child: _SkillImage(skill: skill),
                ),
              ),
              const Spacer(),
              Text(skill.name, style: poppins(14.5)),
              const SizedBox(height: 8),
              ThinProgress(progress, color: skill.color, height: 4),
            ]),
          ),

          // Real percentage badge, top-left corner of the card
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: skill.color,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('$percent%', style: body(11, color: Colors.white)),
            ),
          ),
        ]);
      }),
    );
  }
}

class _SkillImage extends StatelessWidget {
  const _SkillImage({required this.skill});
  final Skill skill;

  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      color: skill.color.withOpacity(.12),
      alignment: Alignment.center,
      child: skill.icon != null ? Icon(skill.icon, color: skill.color, size: 36) : null,
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: skill.assetImage == null
          ? fallback
          : Image.asset(
        skill.assetImage!,
        width: double.infinity,
        height: double.infinity,
        fit: kSkillImageFit,
        errorBuilder: (_, __, ___) => fallback,
      ),
    );
  }
}


/*
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toefl_pro/app/core/theme/app_colors.dart';
import 'package:toefl_pro/app/core/widgets/common_widgets.dart';
import 'package:toefl_pro/app/data/models/models.dart'; // for Skill
import 'package:toefl_pro/app/routes/app_routes.dart';
import '../controllers/practice_controller.dart';

// ---- Change these to resize the images ----
const double kSkillImageHeight = 90;      // image height inside each card
const double kSkillCardAspectRatio = .9;  // lower = taller card (needs more room for a bigger image)
const BoxFit kSkillImageFit = BoxFit.cover; // cover = fill and crop, contain = show whole image
// -------------------------------------------

class PracticeView extends GetView<PracticeController> {
  const PracticeView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(padding: const EdgeInsets.fromLTRB(20, 12, 20, 24), children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Practice', style: poppins(24, w: FontWeight.w700)),
        ]),
        const SizedBox(height: 4),
        Text('TOEFL iBT skill drills', style: body(13, color: muted(context))),
        const SizedBox(height: 16),
        AppCard(
          color: tint(context, AppColors.teal600),
          borderColor: AppColors.teal500.withOpacity(.4),
          onTap: () => Get.toNamed(Routes.writing),
          child: Row(children: [
            const Icon(Icons.auto_awesome_rounded, color: AppColors.teal600),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Recommended for you', style: poppins(13.5)),
                Text('Writing is your weakest skill — try Task 2.',
                    style: body(12, color: muted(context))),
              ]),
            ),
            const Icon(Icons.chevron_right_rounded),
          ]),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: kSkillCardAspectRatio,
          children: [
            for (final s in controller.skills)
              AppCard(
                onTap: () => controller.open(s),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Center(
                    child: SizedBox(
                      height: kSkillImageHeight,
                      width: 90,
                      child: Stack(children: [
                        Positioned.fill(child: _SkillImage(skill: s)),
                        Positioned(
                          top: 6,
                          right: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(.55),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text('${(s.progress * 100).round()}%',
                                style: body(11, color: Colors.white)),
                          ),
                        ),
                      ]),
                    ),
                  ),
                  const Spacer(),
                  Text(s.name, style: poppins(14.5)),
                  const SizedBox(height: 8),
                  ThinProgress(s.progress, color: s.color, height: 4),
                ]),
              ),
          ],
        ),
      ]),
    );
  }
}

class _SkillImage extends StatelessWidget {
  const _SkillImage({required this.skill});
  final Skill skill;

  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      color: skill.color.withOpacity(.12),
      alignment: Alignment.center,
      child: skill.icon != null ? Icon(skill.icon, color: skill.color, size: 36) : null,
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: skill.assetImage == null
          ? fallback
          : Image.asset(
        skill.assetImage!,
        width: double.infinity,
        height: double.infinity,
        fit: kSkillImageFit,
        errorBuilder: (_, __, ___) => fallback,
      ),
    );
  }
}*/
