import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:toefl_pro/app/core/theme/app_colors.dart';
import 'package:toefl_pro/app/core/widgets/common_widgets.dart';
import '../controllers/reading_controller.dart';
import '../reading_models.dart';

const _green = Color(0xFF16A34A);
const _red = Color(0xFFDC2626);


String _fmt(int s) => s >= 60 ? '${s ~/ 60}m ${s % 60}s' : '${s}s';
String _letter(int i) => String.fromCharCode(65 + i);
String _bandText(double b) => b == b.roundToDouble() ? b.toStringAsFixed(0) : b.toStringAsFixed(1);

String _typeName(TaskType t) => switch (t) {
  TaskType.completeWords => 'Complete the Words',
  TaskType.dailyLife => 'Read in Daily Life',
  TaskType.academic => 'Read an Academic Passage',
};

  IconData _typeIcon(TaskType t) => switch (t) {
    TaskType.completeWords => Icons.spellcheck_rounded,
    TaskType.dailyLife => Icons.mark_email_read_outlined,
    TaskType.academic => Icons.school_outlined,
  };
String _typeImage(TaskType t) => switch (t) {
  TaskType.completeWords => 'assets/images/incomplete_words.png',
  TaskType.dailyLife => 'assets/images/email_read.png',
  TaskType.academic => 'assets/images/read.png',
};

Color _typeColor(TaskType t) => switch (t) {
  TaskType.completeWords => AppColors.indigo600,
  TaskType.dailyLife => AppColors.teal600,
  TaskType.academic => AppColors.amber,
};

String _directions(TaskType t) => switch (t) {
  TaskType.completeWords =>
  'Some words in the paragraph are missing their last letters. Type the missing letters to complete each word. The first sentence is complete.',
  TaskType.dailyLife => 'Read the text, then answer the questions. Choose the best answer for each question.',
  TaskType.academic => 'Read the passage, then answer the questions. Choose the best answer for each question.',
};

Widget _chip(BuildContext c, String text, Color color) =>
    Container(
  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
  decoration: BoxDecoration(color: Colors.blue.shade100/*tint(c, color)*/, borderRadius: BorderRadius.circular(20)),
  child: Text(text, style: body(11, w: FontWeight.w600, color: color)),
);

class ReadingView extends GetView<ReadingController> {
  const ReadingView({super.key});

  @override
  Widget build(BuildContext context) => Obx(() {
    switch (controller.phase.value) {
      case ReadingPhase.loading:
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      case ReadingPhase.overview:
        return _OverviewPage();
      case ReadingPhase.test:
        return _TestPage();
      case ReadingPhase.interlude:
        return _InterludePage();
      case ReadingPhase.result:
        return _ResultPage();
      case ReadingPhase.allDone:
        return _SummaryPage();
    }
  });
}

// ═════════════════════════ OVERVIEW (before the test) ═════════════════════════
class _OverviewPage extends GetView<ReadingController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading:
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.grey.shade300,
              width: 1,
            ),
          ),
          child: IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: controller.exitToHome,
          ),
        ),/* IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: controller.exitToHome),*/
        title: const Text('Reading section',style: TextStyle(fontSize: 25),),
        centerTitle: true,
      ),
      body: ListView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 20), children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1E88E5),
           // gradient: _gradient,
            border: Border.all(color: Colors.yellow),
            borderRadius: BorderRadius.circular(26),
            boxShadow: [BoxShadow(color: AppColors.indigo600.withOpacity(.3), blurRadius: 24, offset: const Offset(0, 12))],
          ),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
            Center(child: Text('TOEFL iBT Reading', style: poppins(22, color: Colors.white))),
            const SizedBox(height: 2),
            Text('Full test simulation · Test ${controller.testNo} of ${controller.maxTests}',
                style: body(12.5, color: Colors.white70)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
                children: [

              _pill('2 modules'),
              const SizedBox(width: 8),
              _pill('~30 min'),
              const SizedBox(width: 8),
              _pill('~40 items'),
            ]),
          ]),
        ),
        const SizedBox(height: 22),
        const SectionHeader('Task types',),
        for (final t in TaskType.values) _taskRow(context, t),
        const SizedBox(height: 10),
        const SectionHeader(
          'Before you begin',
         // assetImage: 'assets/images/checked.png',
        ),
       // const SectionHeader('Before you begin'),
        AppCard(
          borderColor: Colors.grey,
          child: Column(children: [
            _rule(context, 'Module 2 adapts to how well you do in Module 1.'),
            _rule(context, 'Within a module you can move back and forth between items.'),
            _rule(context, 'Once you continue to Module 2, you cannot return to Module 1.'),
            _rule(context, 'Each module is timed (about 15 minutes). You can hide the clock.'),
            _rule(context, 'Your result is a practice estimate, not an official ETS score.', last: true),
          ]),
        ),
      ]),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: PrimaryButton('Begin Test ${controller.testNo}', onPressed: controller.startTest),
        ),
      ),
    );
  }

  Widget _pill(String t) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
    child: Text(t, style: body(11.5, w: FontWeight.w600, color: Colors.white)),
  );

  Widget _taskRow(BuildContext c, TaskType t) {
    final desc = switch (t) {
      TaskType.completeWords => 'Fill in the missing letters of 10 words in a short academic paragraph.',
      TaskType.dailyLife => 'Read short everyday texts such as emails and notices. 2–3 questions each.',
      TaskType.academic => 'Read a short university-style passage of about 200 words. 5 questions.',
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        borderColor: Colors.grey,
        child: Row(children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: tint(c, _typeColor(t)),
                borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.grey
            )
            ),
            child: Image.asset(
              _typeImage(t),
              width: 24,
              height: 24,
              fit: BoxFit.contain,
            ),
        //    child: Icon(_typeIcon(t), color: _typeColor(t)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_typeName(t), style: poppins(14)),
              const SizedBox(height: 2),
              Text(desc, style: body(11.5, color: muted(c)).copyWith(height: 1.4)),
            ]),
          ),
        ]),
      ),
    );
  }
  Widget _rule(BuildContext c, String text, {bool last = false}) =>
      Padding(
        padding: EdgeInsets.only(bottom: last ? 0 : 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              'assets/images/checked.png',
              width: 18,
              height: 18,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: body(12.5).copyWith(height: 1.4),
              ),
            ),
          ],
        ),
      );

/*  Widget _rule(BuildContext c, String text, {bool last = false}) => Padding(
    padding: EdgeInsets.only(bottom: last ? 0 : 10),

    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Image.asset('assets/images/checked.png',),
     // const Icon(Icons.check_circle_rounded, size: 18, color: AppColors.teal600),
      const SizedBox(width: 10),
      Expanded(child: Text(text, style: body(12.5).copyWith(height: 1.4))),
    ]),
  );*/
}

// ═════════════════════════ TEST SCREEN ═════════════════════════
class _TestPage extends GetView<ReadingController> {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (_) => controller.confirmExit(),
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 90,

          leading: Padding(
            padding: const EdgeInsets.all(8),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.grey.withValues(alpha: 0.25),
                  width: 1,
                ),
              ),
              child: IconButton(
                icon: const Icon(Icons.close_rounded, size: 22),
                onPressed: controller.confirmExit,
                tooltip: 'Exit test',
                padding: EdgeInsets.zero,
              ),
            ),
          ),
         /* leading: IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: controller.confirmExit,
          ),*/

          title: Obx(
                () => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  'Reading Module\n ${controller.moduleNo.value} of 2',
                  style: const TextStyle(fontSize: 20),
                ),
                Text(
                  'Item ${controller.index.value + 1} of ${controller.screens.length}',
                  style: body(11, color: muted(context)),
                ),
              ],
            ),
          ),

          actions: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Obx(
                      () => controller.hideTime.value
                      ? const SizedBox.shrink()
                      : TimerPill(controller.timer.value?.label ?? ''),
                ),
                const SizedBox(height: 5,),
                Obx(
                      () {
                    final isHidden = controller.hideTime.value;

                    return Material(
                      color: isHidden
                          ? Colors.grey.withValues(alpha: 0.10)
                          : AppColors.blueColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => controller.hideTime.toggle(),
                        child: Container(
                          height: 44,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isHidden
                                  ? Colors.grey.withValues(alpha: 0.20)
                                  : AppColors.blueColor.withValues(alpha: 0.18),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                transitionBuilder: (child, animation) =>
                                    ScaleTransition(
                                      scale: animation,
                                      child: child,
                                    ),
                                child: Icon(
                                  isHidden
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  key: ValueKey(isHidden),
                                  size: 19,
                                  color: isHidden
                                      ? Colors.grey.shade600
                                      : AppColors.blueColor,
                                ),
                              ),
                              const SizedBox(width: 7),
                              Text(
                                isHidden ? 'Show Time' : 'Hide Time',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isHidden
                                      ? Colors.grey.shade700
                                      : AppColors.blueColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),

              ],
            ),
            const SizedBox(width: 8),
          ],
        ),

        body: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 2, 20, 6),
            child: Obx(() => ThinProgress(controller.answeredCount / controller.screens.length, height: 4)),
          ),
          Expanded(
            child: Obx(() {
              final s = controller.screen;
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: KeyedSubtree(
                  key: ValueKey(controller.index.value),
                  child: s.isCtw ? _ctw(context, s.task) : _mcq(context, s),
                ),
              );
            }),
          ),
          _bottomBar(context),
        ]),
      ),
    );
  }

  // ── Directions card (expanded the first time a task appears)
  Widget _directionsCard(BuildContext c, ReadingTask t) => Obx(() {
    final open = controller.openDirections.contains(t.id);
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
       // color: Colors.blue.shade100,
              border: Border.all(
                color: Colors.grey
              ),
        /*  color: tint(c, _typeColor(t.type)
          ), */

          borderRadius: BorderRadius.circular(16)),
           child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        InkWell(
          onTap: () => controller.toggleDirections(t.id),
          child: Row(children: [
            Icon(_typeIcon(t.type), size: 18, color: _typeColor(t.type)),
            const SizedBox(width: 8),
            Expanded(child: Text(_typeName(t.type), style: poppins(13.5))),
            Text(open ? 'Hide' : 'Directions', style: body(11.5, w: FontWeight.w600,
                color:AppColors.blueColor) /*_typeColor(t.type))*/),
          ]),
        ),
        if (open) ...[
          const SizedBox(height: 8),
          Text(_directions(t.type), style: body(12.5).copyWith(height: 1.45)),
        ],
      ]),
    );
  });

  // ── Complete the Words
  Widget _ctw(BuildContext c, ReadingTask t) {
    final base = body(15.5).copyWith(height: 2.15);
    final spans = <InlineSpan>[];
    var bi = 0;
    for (final p in t.parts) {
      if (!p.isBlank) {
        spans.add(TextSpan(text: p.text));
        continue;
      }
      final idx = bi++;
      final n = p.missing!.length;
      spans.add(TextSpan(text: p.prefix,
          style: const TextStyle(fontWeight: FontWeight.w600)));
      spans.add(WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: SizedBox(
          width: 13.0 * n + 12,
          child: TextField(
            controller: controller.ctl(t.id, idx),
            maxLength: n,
            autocorrect: false,
            enableSuggestions: false,
            textInputAction: TextInputAction.next,
            textCapitalization: TextCapitalization.none,
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[a-zA-Z]'))],
            style: base.copyWith(height: 1.2, fontWeight: FontWeight.w700, color: AppColors.indigo600, letterSpacing: 1),
            decoration: const InputDecoration(
              isDense: true,
              counterText: '',
              contentPadding: EdgeInsets.symmetric(vertical: 3, horizontal: 2),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(
                  color: AppColors.blueColor, width: 1.4)),
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.blueColor, width: 2.4)),
            ),
            onChanged: (v) {
              controller.blankChanged();
              if (v.length == n) FocusScope.of(c).nextFocus();
            },
          ),
        ),
      ));
    }
    return ListView(padding: const EdgeInsets.fromLTRB(20, 10, 20, 24), children: [
      _directionsCard(c, t),
      AppCard(
        borderColor: Colors.grey,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Obx(() {
            controller.ctwTick.value;
            final filled = [for (var i = 0; i < t.blankCount; i++) controller.ctl(t.id, i).text.isNotEmpty].where((e) => e).length;
            return Row(children: [
              _chip(c, 'Academic paragraph', AppColors.blueColor),
              const Spacer(),
              Text('$filled of ${t.blankCount} completed', style: body(11.5, color: muted(c))),
            ]);
          }),
          const SizedBox(height: 14),
          Text.rich(TextSpan(style: base, children: spans)),
        ]),
      ),
    ]);
  }

  // ── Daily Life / Academic Passage (text + one question at a time)
  Widget _mcq(BuildContext c, ScreenRef s) {
    final t = s.task;
    final q = t.questions[s.q];
    final sel = controller.selectedFor(t, s.q);
    final paras = t.body.split('\n\n');
    return ListView(padding: const EdgeInsets.fromLTRB(20, 10, 20, 24), children: [
      if (s.firstOfTask) _directionsCard(c, t),
      AppCard(
        borderColor: Colors.grey,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            _chip(c, t.kind, _typeColor(t.type)),
            const Spacer(),
            Text(t.type == TaskType.academic ? '${t.wordCount} words' : 'Short text', style: body(11.5, color: muted(c))),
          ]),
          const SizedBox(height: 10),
          Text(t.title, style: poppins(t.type == TaskType.academic ? 17 : 15)),
          const SizedBox(height: 10),
          for (final p in paras)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(p, style: body(14).copyWith(height: 1.65)),
            ),
        ]),
      ),
      const SizedBox(height: 18),
      Row(children: [
        _chip(c, q.type, AppColors.indigo600),
        const Spacer(),
        Text('Question ${s.q + 1} of ${t.questions.length}', style: body(11.5, color: muted(c))),
      ]),
      const SizedBox(height: 10),
      Text(q.text, style: poppins(15).copyWith(height: 1.45)),
      const SizedBox(height: 14),
      for (var k = 0; k < q.options.length; k++) _option(c, k, q.options[k], sel == k),
    ]);
  }

  Widget _option(BuildContext c, int idx, String text, bool selected) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: InkWell(
      onTap: () => controller.select(idx),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? tint(c, AppColors.blueColor) : Theme.of(c).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.blueColor : Colors.grey,
            width: selected ? 1.6 : 0.6,
          ),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(shape: BoxShape.circle,
                color: selected ? AppColors.blueColor : tint(c, AppColors.indigo600)),
            child: Text(_letter(idx),
                style: body(12.5, w: FontWeight.w700, color: selected ? Colors.white : AppColors.blueColor)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(text, style: body(13.5, w: FontWeight.w500).copyWith(height: 1.4)),
            ),
          ),
        ]),
      ),
    ),
  );

  // ── Bottom bar: Back · Review map · Next
  Widget _bottomBar(BuildContext c) => SafeArea(
    top: false,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 12),
      child: Row(children: [
        SizedBox(width: 52, child: GhostButton('', icon: Icons.chevron_left_rounded, onPressed: controller.prev)),
        const SizedBox(width: 2),
        SizedBox(width: 52, child: GhostButton('', icon: Icons.grid_view_rounded, onPressed: () => _map(c))),
        const SizedBox(width: 12),
        Expanded(
          child: Obx(() => PrimaryButton(
            controller.index.value == controller.screens.length - 1 ? 'Submit module' : 'Next',
            onPressed: controller.next,
          )),
        ),
      ]),
    ),
  );

  void _map(BuildContext c) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        decoration: BoxDecoration(
          color: Theme.of(c).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Obx(() => Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Review items', style: poppins(16)),
            const SizedBox(height: 4),
            Text('${controller.answeredCount} of ${controller.screens.length} answered · Module ${controller.moduleNo.value}',
                style: body(12, color: muted(c))),
            const SizedBox(height: 16),
            Wrap(spacing: 10, runSpacing: 10, children: [
              for (var i = 0; i < controller.screens.length; i++) _mapDot(c, i),
            ]),
            const SizedBox(height: 14),
            Row(children: [
              _legend(c, AppColors.indigo600, 'Answered'),
              const SizedBox(width: 16),
              _legend(c, muted(c), 'Not answered'),
            ]),
          ])),
        ),
      ),
    );
  }

  Widget _mapDot(BuildContext c, int i) {
    final s = controller.screens[i];
    final ans = controller.isAnswered(s);
    final cur = controller.index.value == i;
    return GestureDetector(
      onTap: () {
        controller.goTo(i);
        Get.back();
      },
      child: Container(
        width: 42,
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: ans ? AppColors.indigo600 : Colors.transparent,
          border: Border.all(color: cur ? AppColors.amber : (ans ? AppColors.indigo600 : Theme.of(c).dividerColor), width: cur ? 2.6 : 1.4),
        ),
        child: Text('${i + 1}', style: body(13, w: FontWeight.w700, color: ans ? Colors.white : muted(c))),
      ),
    );
  }

  Widget _legend(BuildContext c, Color color, String t) => Row(children: [
    Container(width: 10, height: 10, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
    const SizedBox(width: 6),
    Text(t, style: body(11.5, color: muted(c))),
  ]);
}

// ═════════════════════════ BETWEEN MODULES ═════════════════════════
class _InterludePage extends GetView<ReadingController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(color: tint(context, AppColors.teal600), shape: BoxShape.circle),
              child: const Icon(Icons.check_rounded, size: 46, color: AppColors.teal600),
            ),
            const SizedBox(height: 20),
            Text('Module 1 complete', style: poppins(22)),
            const SizedBox(height: 8),
            Text(
              'Your answers have been submitted. Module 2 is selected based on how you performed.\n\nYou will not be able to return to Module 1.',
              textAlign: TextAlign.center,
              style: body(13.5, color: muted(context)).copyWith(height: 1.5),
            ),
            const SizedBox(height: 28),
            PrimaryButton('Start Module 2', onPressed: controller.startModule2),
          ]),
        ),
      ),
    );
  }
}

// ═════════════════════════ RESULT ═════════════════════════
class _ResultPage extends GetView<ReadingController> {
  @override
  Widget build(BuildContext context) {
    final m1 = controller.m1!, m2 = controller.m2!;
    final score = m1.score + m2.score, total = m1.total + m2.total;
    final pct = total == 0 ? 0.0 : score / total;
    final more = controller.store.canStart;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.close_rounded), onPressed: controller.exitToHome),
        title: Text('Test ${controller.currentTestNo} results'),
      ),
      body: ListView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 20), children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Color(0xFF1E88E5),
           // gradient: _gradient,
            borderRadius: BorderRadius.circular(26),
            boxShadow: [BoxShadow(color: AppColors.indigo600.withOpacity(.3), blurRadius: 24, offset: const Offset(0, 12))],
          ),
          child: Row(children: [
            ProgressRing(pct,
                size: 96,
                color: Colors.white,
                trackColor: Colors.white24,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text(_bandText(controller.band), style: poppins(24, color: Colors.white)),
                  Text('of 6', style: body(10, color: Colors.white70)),
                ])),
            const SizedBox(width: 18),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Estimated band', style: body(12, color: Colors.white70)),
                Text('${_bandText(controller.band)} / 6', style: poppins(22, color: Colors.white)),
                const SizedBox(height: 4),
                Text('$score of $total correct · ${_fmt(controller.totalSeconds)}', style: body(12, color: Colors.white70)),
              ]),
            ),
          ]),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text('Practice estimate only, not an official ETS score.', style: body(11, color: muted(context))),
        ),
        const SizedBox(height: 14),
        AppCard(
          child: Column(children: [
            _moduleRow(context, 'Module 1', 'Standard level', m1),
            const Divider(height: 22),
            _moduleRow(context, 'Module 2', controller.hardPath ? 'Harder level' : 'Easier level', m2),
          ]),
        ),
        const SizedBox(height: 22),
        const SectionHeader('By task type'),
        for (final t in TaskType.values) _typeRow(context, t),
        const SizedBox(height: 14),
        const SectionHeader('Review · Module 1'),
        for (final t in controller.m1Tasks) _reviewTask(context, t),
        const SectionHeader('Review · Module 2'),
        for (final t in controller.m2Tasks) _reviewTask(context, t),
      ]),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            PrimaryButton(more ? 'Next test (${controller.store.completedCount + 1} of ${controller.maxTests})' : 'View final summary',
                onPressed: controller.nextTest),
            TextButton(onPressed: controller.exitToHome, child: const Text('Back to home')),
          ]),
        ),
      ),
    );
  }

  Widget _moduleRow(BuildContext c, String name, String level, ModuleScore m) => Row(children: [
    Expanded(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(name, style: poppins(14)),
        Text(level, style: body(11.5, color: muted(c))),
      ]),
    ),
    Text('${m.score}/${m.total}', style: poppins(15, color: AppColors.indigo600)),
  ]);

  Widget _typeRow(BuildContext c, TaskType t) {
    final got = (controller.m1!.got[t] ?? 0) + (controller.m2!.got[t] ?? 0);
    final max = (controller.m1!.max[t] ?? 0) + (controller.m2!.max[t] ?? 0);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        child: Column(children: [
          Row(children: [
            Icon(_typeIcon(t), size: 20, color: _typeColor(t)),
            const SizedBox(width: 10),
            Expanded(child: Text(_typeName(t), style: poppins(13.5))),
            Text('$got / $max', style: body(12.5, w: FontWeight.w700, color: _typeColor(t))),
          ]),
          const SizedBox(height: 10),
          ThinProgress(max == 0 ? 0 : got / max, height: 5),
        ]),
      ),
    );
  }

  Widget _reviewTask(BuildContext c, ReadingTask t) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(_typeIcon(t.type), size: 18, color: _typeColor(t.type)),
            const SizedBox(width: 8),
            Expanded(child: Text('${_typeName(t.type)} · ${t.title}', style: poppins(13), maxLines: 1, overflow: TextOverflow.ellipsis)),
          ]),
          const SizedBox(height: 12),
          if (t.type == TaskType.completeWords) _reviewCtw(c, t) else ..._reviewMcq(c, t),
        ]),
      ),
    );
  }

  Widget _reviewCtw(BuildContext c, ReadingTask t) {
    final ans = controller.ctwFinal[t.id] ?? const <String>[];
    final blanks = t.parts.where((p) => p.isBlank).toList();
    return Wrap(spacing: 8, runSpacing: 8, children: [
      for (var i = 0; i < blanks.length; i++)
            () {
          final p = blanks[i];
          final given = i < ans.length ? ans[i] : '';
          final ok = given.toLowerCase() == p.missing!.toLowerCase();
          final full = '${p.prefix}${p.missing}';
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: (ok ? _green : _red).withOpacity(.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: (ok ? _green : _red).withOpacity(.4)),
            ),
            child: Text(ok ? full : '${p.prefix}${given.isEmpty ? '—' : given}  →  $full',
                style: body(12.5, w: FontWeight.w600, color: ok ? _green : _red)),
          );
        }(),
    ]);
  }

  List<Widget> _reviewMcq(BuildContext c, ReadingTask t) {
    return [
      for (var i = 0; i < t.questions.length; i++) ...[
            () {
          final q = t.questions[i];
          final picked = controller.selectedFor(t, i);
          final ok = picked == q.correct;
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: (ok ? _green : _red).withOpacity(.12)),
                  child: Icon(ok ? Icons.check_rounded : Icons.close_rounded, size: 15, color: ok ? _green : _red),
                ),
                const SizedBox(width: 8),
                Expanded(child: Text('${q.type} · Question ${i + 1}', style: body(11.5, color: muted(c)))),
              ]),
              const SizedBox(height: 6),
              Text(q.text, style: poppins(13).copyWith(height: 1.4)),
              const SizedBox(height: 8),
              _answer(c, 'Your answer', picked == null ? 'Not answered' : '${_letter(picked)}. ${q.options[picked]}', ok ? _green : _red),
              if (!ok) ...[
                const SizedBox(height: 6),
                _answer(c, 'Correct answer', '${_letter(q.correct)}. ${q.options[q.correct]}', _green),
              ],
              const SizedBox(height: 8),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.lightbulb_outline_rounded, size: 16, color: AppColors.amber),
                const SizedBox(width: 6),
                Expanded(child: Text(q.explanation, style: body(12).copyWith(height: 1.4))),
              ]),
            ]),
          );
        }(),
      ],
    ];
  }

  Widget _answer(BuildContext c, String label, String text, Color color) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: color.withOpacity(.08),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color.withOpacity(.35)),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: body(10.5, color: muted(c))),
      const SizedBox(height: 2),
      Text(text, style: body(12.5, w: FontWeight.w600, color: color)),
    ]),
  );
}

// ═════════════════════════ FINAL SUMMARY ═════════════════════════
class _SummaryPage extends GetView<ReadingController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.close_rounded), onPressed: controller.exitToHome),
        title: const Text('Reading summary'),
      ),
      body: Obx(() {
        final list = controller.store.attempts.toList();
        final score = list.fold<int>(0, (a, r) => a + r.score);
        final total = list.fold<int>(0, (a, r) => a + r.total);
        final secs = list.fold<int>(0, (a, r) => a + r.seconds);
        final avgBand = list.isEmpty ? 0.0 : list.fold<double>(0, (a, r) => a + r.band) / list.length;
        final best = list.isEmpty ? 0.0 : list.map((e) => e.band).reduce((a, b) => a > b ? a : b);

        return ListView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 24), children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: const Color(0xFF1E88E5),
            //  gradient: _gradient,
              borderRadius: BorderRadius.circular(26),
              boxShadow: [BoxShadow(color: AppColors.indigo600.withOpacity(.3), blurRadius: 24, offset: const Offset(0, 12))],
            ),
            child: Column(children: [
              const Text('🏆', style: TextStyle(fontSize: 46)),
              const SizedBox(height: 8),
              Text('All ${controller.maxTests} Reading tests completed!',
                  style: poppins(20, color: Colors.white), textAlign: TextAlign.center),
              const SizedBox(height: 4),
              Text('You answered $score of $total items correctly.',
                  style: body(13, color: Colors.white70), textAlign: TextAlign.center),
            ]),
          ),
          const SizedBox(height: 16),
          Row(children: [
            _stat(context, _bandText((avgBand * 2).round() / 2), 'Avg. band', AppColors.indigo600),
            const SizedBox(width: 10),
            _stat(context, _bandText(best), 'Best band', _green),
            const SizedBox(width: 10),
            _stat(context, _fmt(list.isEmpty ? 0 : secs ~/ list.length), 'Avg. time', AppColors.amber),
          ]),
          const SizedBox(height: 22),
          const SectionHeader('Your tests'),
          for (final r in list) _row(context, r),
          const SizedBox(height: 18),
          PrimaryButton('Practice again', onPressed: controller.confirmReset),
          Center(child: TextButton(onPressed: controller.exitToHome, child: const Text('Back to home'))),
        ]);
      }),
    );
  }

  Widget _stat(BuildContext c, String value, String label, Color color) => Expanded(
    child: AppCard(
      child: Column(children: [
        Text(value, style: poppins(17, color: color)),
        const SizedBox(height: 2),
        Text(label, style: body(11, color: muted(c))),
      ]),
    ),
  );

  Widget _row(BuildContext c, AttemptResult r) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: AppCard(
      child: Row(children: [
        Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: tint(c, AppColors.indigo600), borderRadius: BorderRadius.circular(12)),
          child: Text('${r.no}', style: poppins(14, color: AppColors.indigo600)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Test ${r.no}', style: poppins(13.5)),
            const SizedBox(height: 2),
            Text('${r.score}/${r.total} correct · ${_fmt(r.seconds)} · Module 2 ${r.hard ? 'harder' : 'easier'}',
                style: body(11.5, color: muted(c))),
          ]),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(color: AppColors.indigo600.withOpacity(.12), borderRadius: BorderRadius.circular(20)),
          child: Text('Band ${_bandText(r.band)}', style: body(12, w: FontWeight.w700, color: AppColors.indigo600)),
        ),
      ]),
    ),
  );
}