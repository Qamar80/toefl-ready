import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toefl_pro/app/core/theme/app_colors.dart';
import 'package:toefl_pro/app/core/widgets/common_widgets.dart';
import '../controllers/writing_controller.dart';
import '../writing_checker.dart';
import '../writing_models.dart';

const _green = Color(0xFF16A34A);
const _red = Color(0xFFDC2626);

String _fmt(int s) => s >= 60 ? '${s ~/ 60}m ${s % 60}s' : '${s}s';
String _bandText(double b) => b == b.roundToDouble() ? b.toStringAsFixed(0) : b.toStringAsFixed(1);

Widget _chip(String text, Color color) => Container(
  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
  decoration: BoxDecoration(
     // color: Colors.blue.shade100,
      borderRadius: BorderRadius.circular(20)),
  child: Text(text, style: body(11, w: FontWeight.w600, color: color)),
);

class WritingView extends GetView<WritingController> {
  const WritingView({super.key});

  @override
  Widget build(BuildContext context) => Obx(() {
    switch (controller.phase.value) {
      case WritingPhase.loading:
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      case WritingPhase.overview:
        return const _OverviewPage();
      case WritingPhase.build:
        return const _BuildPage();
      case WritingPhase.email:
        return const _EmailPage();
      case WritingPhase.discussion:
        return const _DiscussionPage();
      case WritingPhase.result:
        return const _ResultPage();
      case WritingPhase.allDone:
        return const _SummaryPage();
    }
  });
}

// ───────────── shared app bar for the three timed stages ─────────────
PreferredSizeWidget _testBar(
    BuildContext context,
    WritingController c,
    String title,
    String Function() subtitle) =>
    AppBar(
      toolbarHeight: 90,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.withValues(alpha: 0.25), width: 1),
          ),
          child: IconButton(
            icon: const Icon(Icons.close_rounded, size: 22),
            onPressed: c.confirmExit,
            tooltip: 'Exit test',
            padding: EdgeInsets.zero,
          ),
        ),
      ),
      title: Obx(() {
        c.phase.value; // makes sure Obx always observes something
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 16)),
            Text(subtitle(), style: body(11, color: muted(context))),
          ],
        );
      }),
 /*     title: Obx(() => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18)),
          Text(subtitle(), style: body(11, color: muted(context))),
        ],
      )
      ),*/
      actions: [
        Obx(() => c.hideTime.value
            ? const SizedBox.shrink()
            : TimerPill(c.timer.value?.label ?? '', color: AppColors.blueColor)),
        Obx(() => IconButton(
          tooltip: c.hideTime.value ? 'Show time' : 'Hide time',
          icon: Icon(c.hideTime.value ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              size: 21, color: AppColors.blueColor),
          onPressed: c.hideTime.toggle,
        )),
        const SizedBox(width: 4),
      ],
    );

// ═════════════════════════ OVERVIEW ═════════════════════════
class _OverviewPage extends GetView<WritingController> {
  const _OverviewPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Container(
          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.grey.shade300)),
          child: IconButton(icon: const Icon(Icons.close_rounded), onPressed: controller.exitToHome),
        ),
        title: const Text('Writing section', style: TextStyle(fontSize: 25)),
        centerTitle: true,
      ),
      body: ListView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 20), children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1E88E5),
            border: Border.all(color: Colors.yellow),
            borderRadius: BorderRadius.circular(26),
            boxShadow: [BoxShadow(color: AppColors.indigo600.withOpacity(.3), blurRadius: 24, offset: const Offset(0, 12))],
          ),
          child: Column(children: [
            Text('TOEFL iBT Writing', style: poppins(22, color: Colors.white)),
            const SizedBox(height: 2),
            Text('Full test simulation · Test ${controller.testNo} of ${controller.maxTests}',
                style: body(12.5, color: Colors.white70)),
            const SizedBox(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              _pill('3 tasks'),
              const SizedBox(width: 8),
              _pill('~23 min'),
              const SizedBox(width: 8),
              _pill('12 items'),
            ]),
          ]),
        ),
        const SizedBox(height: 22),
        const SectionHeader('Task types'),
        _taskRow(context, Icons.extension_rounded, AppColors.indigo600, 'Build a Sentence',
            '10 items · about 6 minutes. Tap the word groups in the right order to make one correct sentence or question.'),
        _taskRow(context, Icons.mail_outline_rounded, AppColors.teal600, 'Write an Email',
            '7 minutes. Read the situation and write an email that covers all three points.'),
        _taskRow(context, Icons.forum_outlined, AppColors.amber, 'Write for an Academic Discussion',
            '10 minutes. Read the professor and two students, then post your own view (about 100 words).'),
        const SizedBox(height: 10),
        const SectionHeader('Before you begin'),
        AppCard(
          borderColor: Colors.grey,
          child: Column(children: [
            _rule('Each task has its own timer. When time runs out, your work is submitted automatically.'),
            _rule('You can go back and forth inside Build a Sentence.'),
            _rule('After you continue from the email or the discussion, you cannot go back.'),
            _rule('Spell-check and auto-correct are off, like on the real test.'),
            _rule('Build a Sentence, the email and the discussion are all scored automatically. You also get a list of grammar and spelling mistakes, a length check, and a model answer to compare with.'),
            _rule('The result is a practice estimate, not an official ETS score.', last: true),
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

  Widget _taskRow(BuildContext c, IconData icon, Color color, String name, String desc) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: AppCard(
      borderColor: Colors.grey,
      child: Row(children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: tint(c, color),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey),
          ),
          child: Icon(icon, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: poppins(14)),
            const SizedBox(height: 2),
            Text(desc, style: body(11.5, color: muted(c)).copyWith(height: 1.4)),
          ]),
        ),
      ]),
    ),
  );

  Widget _rule(String text, {bool last = false}) => Padding(
    padding: EdgeInsets.only(bottom: last ? 0 : 10),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Image.asset('assets/images/checked.png', width: 18, height: 18, fit: BoxFit.contain),
      const SizedBox(width: 10),
      Expanded(child: Text(text, style: body(12.5).copyWith(height: 1.4))),
    ]),
  );
}

// ═════════════════════════ STAGE 1 · BUILD A SENTENCE ═════════════════════════
class _BuildPage extends GetView<WritingController> {
  const _BuildPage();

  @override
  Widget build(BuildContext context) {
    final c = controller;
    return PopScope(
      canPop: false,
      onPopInvoked: (_) => c.confirmExit(),
      child: Scaffold(
        appBar: _testBar(context, c, 'Writing \n Build a Sentence',
                () => 'Item ${c.buildIndex.value + 1} of ${c.current.builds.length}'),
        body: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 2, 20, 6),
            child: Obx(() => ThinProgress(c.answeredCount / c.current.builds.length, height: 4)),
          ),
          Expanded(
            child: Obx(() {
              final i = c.buildIndex.value;
              final it = c.current.builds[i];
              final placed = c.placed[i];
              final pool = [for (final t in c.tileOrder[i]) if (!placed.contains(t)) t];
              return ListView(
                key: ValueKey(i),
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                     //color: Colors.blue.shade100,
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'Arrange the word groups to make a correct reply or question. Tap a group to add it; tap it again in your sentence to remove it.',
                      style: body(12.5).copyWith(height: 1.45),
                    ),
                  ),
                  AppCard(
                    borderColor: Colors.grey,
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('CONTEXT', style: body(10.5, w: FontWeight.w700, color: AppColors.indigo600)),
                      const SizedBox(height: 6),
                      Text(it.context, style: poppins(15).copyWith(height: 1.45)),
                    ]),
                  ),
                  const SizedBox(height: 14),
                  AppCard(
                    borderColor: placed.length == it.chunks.length ? AppColors.blueColor : Colors.grey,
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Text('YOUR SENTENCE', style: body(10.5, w: FontWeight.w700, color: AppColors.indigo600)),
                        const Spacer(),
                        Text('${placed.length} / ${it.chunks.length}', style: body(11.5, color: muted(context))),
                      ]),
                      const SizedBox(height: 10),
                      ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 56),
                        child: placed.isEmpty
                            ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: Text('Tap the word groups below…',
                              style: body(13, color: muted(context))),
                        )
                            : Wrap(spacing: 8, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
                          for (var p = 0; p < placed.length; p++)
                            _tile(context, it.chunks[placed[p]], () => c.removeAt(p), filled: true),
                          if (placed.length == it.chunks.length)
                            Text(it.end, style: poppins(18, color: AppColors.blueColor)),
                        ]),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 14),
                  Row(children: [
                    Text('WORD GROUPS', style: body(10.5, w: FontWeight.w700, color: muted(context))),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: placed.isEmpty ? null : c.clearItem,
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: const Text('Clear'),
                    ),
                  ]),
                  const SizedBox(height: 4),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    for (final t in pool) _tile(context, it.chunks[t], () => c.place(t)),
                  ]),
                ],
              );
            }),
          ),
          _bottomBar(context),
        ]),
      ),
    );
  }

  Widget _tile(BuildContext ctx, String text, VoidCallback onTap, {bool filled = false}) => Material(
    color: filled ? tint(ctx, AppColors.blueColor) : Theme.of(ctx).cardColor,
    borderRadius: BorderRadius.circular(12),
    child: InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: filled ? AppColors.blueColor : Colors.grey, width: filled ? 1.4 : 0.8),
        ),
        child: Text(text, style: body(14, w: FontWeight.w600)),
      ),
    ),
  );

  Widget _bottomBar(BuildContext c) => SafeArea(
    top: false,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 12),
      child: Row(children: [
        SizedBox(width: 52, child: GhostButton('', icon: Icons.chevron_left_rounded, onPressed: controller.prev)),
        const SizedBox(width: 12),
        Expanded(
          child: Obx(() => PrimaryButton(
            controller.buildIndex.value == controller.current.builds.length - 1 ? 'Finish & continue' : 'Next',
            onPressed: controller.next,
          )),
        ),
      ]),
    ),
  );
}

// ═════════════════════════ STAGE 2 · EMAIL ═════════════════════════
class _EmailPage extends GetView<WritingController> {
  const _EmailPage();

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final e = c.current.email;
    return PopScope(
      canPop: false,
      onPopInvoked: (_) => c.confirmExit(),
      child: Scaffold(
        appBar: _testBar(context, c, 'Writing\n Write an Email', () => 'Task 2 of 3 · 7 minutes'),
        body: ListView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 24), children: [
          AppCard(
            borderColor: Colors.grey,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _chip('Email', AppColors.blueColor),
              const SizedBox(height: 10),
              Text(e.scenario, style: body(13.5).copyWith(height: 1.55)),
              const SizedBox(height: 12),
              _meta(context, 'To', e.to),
              _meta(context, 'Subject', e.subject),
              const SizedBox(height: 10),
              Text('In your email, make sure you:', style: poppins(13)),
              const SizedBox(height: 6),
              for (var i = 0; i < e.points.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(
                      width: 22,
                      height: 22,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: tint(context, AppColors.indigo600)),
                      child: Text('${i + 1}', style: body(11.5, w: FontWeight.w700, color: AppColors.indigo600)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(e.points[i], style: body(13).copyWith(height: 1.4))),
                  ]),
                ),
            ]),
          ),
          const SizedBox(height: 14),
          AppCard(
            borderColor: Colors.grey,
            child: TextField(
              controller: c.emailCtl,
              minLines: 10,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              textCapitalization: TextCapitalization.sentences,
              autocorrect: false,
              enableSuggestions: false,
              style: body(13.5).copyWith(height: 1.6),
              decoration: const InputDecoration.collapsed(hintText: 'Type your email here…'),
            ),
          ),
          const SizedBox(height: 10),
          Obx(() => _counter(context, c.emailWords.value, 50, 120)),
        ]),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: PrimaryButton('Continue', onPressed: c.requestSubmitEmail),
          ),
        ),
      ),
    );
  }
}

Widget _meta(BuildContext c, String k, String v) => Padding(
  padding: const EdgeInsets.only(bottom: 4),
  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
    SizedBox(width: 60, child: Text('$k:', style: body(12.5, w: FontWeight.w700, color: muted(c)))),
    Expanded(child: Text(v, style: body(12.5, w: FontWeight.w600))),
  ]),
);

Widget _counter(BuildContext c, int words, int lo, int hi) {
  final ok = words >= lo && words <= hi;
  return Column(children: [
    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text('$words words · suggested $lo–$hi', style: body(11.5, color: muted(c))),
      Text(words == 0 ? '' : (ok ? 'Good length' : (words < lo ? 'A bit short' : 'A bit long')),
          style: body(11.5, w: FontWeight.w600, color: ok ? AppColors.teal600 : AppColors.amber)),
    ]),
    const SizedBox(height: 6),
    ThinProgress((words / hi).clamp(0.0, 1.0), color: ok ? AppColors.teal600 : AppColors.amber, height: 5),
  ]);
}

// ═════════════════════════ STAGE 3 · ACADEMIC DISCUSSION ═════════════════════════
class _DiscussionPage extends GetView<WritingController> {
  const _DiscussionPage();

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final d = c.current.discussion;
    return PopScope(
      canPop: false,
      onPopInvoked: (_) => c.confirmExit(),
      child: Scaffold(
        appBar: _testBar(context, c, 'Writing\n Academic Discussion', () => 'Task 3 of 3 · 10 minutes'),
        body: ListView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 24), children: [
          AppCard(
            borderColor: Colors.grey,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                _chip(d.field, AppColors.blueColor),
                const Spacer(),
                Text(d.professor, style: body(11.5, w: FontWeight.w600, color: muted(context))),
              ]),
              const SizedBox(height: 10),
              Text(d.question, style: body(13.5).copyWith(height: 1.55)),
            ]),
          ),
          const SizedBox(height: 12),
          _student(context, d.s1Name, d.s1Text, AppColors.indigo600),
          const SizedBox(height: 10),
          _student(context, d.s2Name, d.s2Text, AppColors.teal600),
          const SizedBox(height: 14),
          AppCard(
            borderColor: Colors.grey,
            child: TextField(
              controller: c.discCtl,
              minLines: 9,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              textCapitalization: TextCapitalization.sentences,
              autocorrect: false,
              enableSuggestions: false,
              style: body(13.5).copyWith(height: 1.6),
              decoration: const InputDecoration.collapsed(hintText: 'Write your contribution to the discussion…'),
            ),
          ),
          const SizedBox(height: 10),
          Obx(() => _counter(context, c.discWords.value, 80, 150)),
        ]),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: PrimaryButton('Submit writing', onPressed: c.requestSubmitDiscussion),
          ),
        ),
      ),
    );
  }

  Widget _student(BuildContext c, String name, String text, Color color) => AppCard(
    borderColor: Colors.grey,
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(shape: BoxShape.circle, color: tint(c, color)),
        child: Text(name.substring(0, 1), style: poppins(14, color: color)),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, style: poppins(13)),
          const SizedBox(height: 3),
          Text(text, style: body(13).copyWith(height: 1.5)),
        ]),
      ),
    ]),
  );
}

// ═════════════════════════ RESULT ═════════════════════════
class _ResultPage extends GetView<WritingController> {
  const _ResultPage();

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final more = c.store.canStart;
    final total = c.current.builds.length;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.close_rounded), onPressed: c.exitToHome),
        title: Text('Test ${c.currentTestNo} results'),
      ),
      body: ListView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 20), children: [
        Obx(() => Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1E88E5),
            borderRadius: BorderRadius.circular(26),
            boxShadow: [BoxShadow(color: AppColors.indigo600.withOpacity(.3), blurRadius: 24, offset: const Offset(0, 12))],
          ),
          child: Row(children: [
            ProgressRing(((c.band.value - 1) / 5).clamp(0.0, 1.0),
                size: 96,
                color: Colors.white,
                trackColor: Colors.white24,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text(_bandText(c.band.value), style: poppins(24, color: Colors.white)),
                  Text('of 6', style: body(10, color: Colors.white70)),
                ])),
            const SizedBox(width: 18),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Estimated band', style: body(12, color: Colors.white70)),
                Text('${_bandText(c.band.value)} / 6', style: poppins(22, color: Colors.white)),
                const SizedBox(height: 4),
                Text(
                  c.fullyRated
                      ? 'Based on your sentences and the automatic checks'
                      : 'Checking your email and post…',
                  style: body(11.5, color: Colors.white70),
                ),
              ]),
            ),
          ]),
        )),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text('Practice estimate only, not an official ETS score. Total time: ${_fmt(c.totalSeconds)}.',
              style: body(11, color: muted(context))),
        ),
        const SizedBox(height: 14),
        AppCard(
          child: Column(children: [
            _scoreRow(context, 'Build a Sentence', 'Scored automatically', '${c.buildGot}/$total'),
            const Divider(height: 22),
            Obx(() => _scoreRow(context, 'Write an Email', 'Automatic check',
                c.selfEmail.value < 0 ? '…' : '${_bandText(c.selfEmail.value)}/5')),
            const Divider(height: 22),
            Obx(() => _scoreRow(context, 'Academic Discussion', 'Automatic check',
                c.selfDisc.value < 0 ? '…' : '${_bandText(c.selfDisc.value)}/5')),
          ]),
        ),
        const SizedBox(height: 22),
        const SectionHeader('Review · Build a Sentence'),
        for (var i = 0; i < total; i++) _buildReview(context, i),
        const SizedBox(height: 10),
        const SectionHeader('Review · Write an Email'),
        _writtenReview(
          context,
          text: c.emailCtl.text.trim(),
          words: c.emailWords.value,
          check: c.emailCheck,
          model: c.current.email.sample,
        ),
        const SizedBox(height: 10),
        const SectionHeader('Review · Academic Discussion'),
        _writtenReview(
          context,
          text: c.discCtl.text.trim(),
          words: c.discWords.value,
          check: c.discCheck,
          model: c.current.discussion.sample,
        ),
      ]),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            PrimaryButton(
                more ? 'Next test (${c.store.completedCount + 1} of ${c.maxTests})' : 'View final summary',
                onPressed: c.nextTest),
            TextButton(onPressed: c.exitToHome, child: const Text('Back to home')),
          ]),
        ),
      ),
    );
  }

  Widget _scoreRow(BuildContext c, String name, String sub, String value) => Row(children: [
    Expanded(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(name, style: poppins(14)),
        Text(sub, style: body(11.5, color: muted(c))),
      ]),
    ),
    Text(value, style: poppins(15, color: AppColors.indigo600)),
  ]);

  Widget _buildReview(BuildContext c, int i) {
    final it = controller.current.builds[i];
    final ok = controller.buildCorrect[i];
    final given = controller.builtAnswers[i];
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(shape: BoxShape.circle, color: (ok ? _green : _red).withOpacity(.12)),
              child: Icon(ok ? Icons.check_rounded : Icons.close_rounded, size: 15, color: ok ? _green : _red),
            ),
            const SizedBox(width: 8),
            Expanded(child: Text('Item ${i + 1} · ${it.context}', style: body(12, color: muted(c)))),
          ]),
          const SizedBox(height: 8),
          _answer(c, 'Your sentence', given.isEmpty ? 'Not answered' : given, ok ? _green : _red),
          if (!ok) ...[
            const SizedBox(height: 6),
            _answer(c, 'Correct sentence', it.answer, _green),
          ],
        ]),
      ),
    );
  }

  Widget _writtenReview(
      BuildContext c, {
        required String text,
        required int words,
        required Rxn<WritingCheck> check,
        required String model,
      }) {
    return AppCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Obx(() {
          final r = check.value;
          final issues = r?.issues ?? const <WritingIssue>[];
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(
                  child: Text('Your response · $words words',
                      style: body(11, w: FontWeight.w700, color: muted(c)))),
              if (r != null) Text('${_bandText(r.score)} / 5', style: poppins(16, color: AppColors.indigo600)),
            ]),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: tint(c, AppColors.indigo600), borderRadius: BorderRadius.circular(12)),
              child: text.isEmpty
                  ? Text('You did not write anything.', style: body(12.5))
                  : _highlighted(text, issues),
            ),
            const SizedBox(height: 14),
            if (r == null)
              Row(children: [
                const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                const SizedBox(width: 10),
                Text('Checking grammar, length and content…', style: body(12.5, color: muted(c))),
              ])
            else ...[
              Text('Score breakdown', style: poppins(13)),
              const SizedBox(height: 8),
              for (final l in r.lines)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Expanded(child: Text(l.label, style: body(12.5, w: FontWeight.w600))),
                      Text('${_bandText(double.parse(l.got.toStringAsFixed(1)))} / ${_bandText(l.max)}',
                          style: body(12, w: FontWeight.w700, color: l.got >= l.max * .8 ? _green : AppColors.amber)),
                    ]),
                    const SizedBox(height: 4),
                    ThinProgress(l.max == 0 ? 0 : l.got / l.max,
                        color: l.got >= l.max * .8 ? _green : AppColors.amber, height: 4),
                    const SizedBox(height: 3),
                    Text(l.note, style: body(11, color: muted(c))),
                  ]),
                ),
              const SizedBox(height: 4),
              Text('Mistakes found (${r.issues.length})', style: poppins(13)),
              const SizedBox(height: 6),
              if (r.issues.isEmpty)
                Text('No mistakes found. Nice work!', style: body(12.5, color: _green))
              else
                for (final i in r.issues.take(10))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _red.withOpacity(.06),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _red.withOpacity(.25)),
                      ),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('“${i.snippet(text)}”  ·  ${i.type}',
                            style: body(12, w: FontWeight.w700, color: _red)),
                        const SizedBox(height: 2),
                        Text(i.message, style: body(12).copyWith(height: 1.4)),
                        if (i.fixes.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text('Try: ${i.fixes.join('  /  ')}',
                              style: body(12, w: FontWeight.w600, color: _green)),
                        ],
                      ]),
                    ),
                  ),
              if (r.issues.length > 10)
                Text('+ ${r.issues.length - 10} more (all underlined above)', style: body(11, color: muted(c))),
              const SizedBox(height: 4),
              Text(
                r.online
                    ? 'Grammar checked with LanguageTool. Scores are a practice estimate.'
                    : 'Offline mode: only common mistakes are detected. Connect to the internet for a full grammar check.',
                style: body(10.5, color: muted(c)),
              ),
            ],
          ]);
        }),
        const SizedBox(height: 6),
        Theme(
          data: Theme.of(c).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: EdgeInsets.zero,
            childrenPadding: EdgeInsets.zero,
            title: Text('Show a model answer', style: poppins(13, color: AppColors.blueColor)),
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _green.withOpacity(.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _green.withOpacity(.35)),
                ),
                child: Text(model, style: body(12.5).copyWith(height: 1.55)),
              ),
              const SizedBox(height: 6),
              Text('This is one possible answer. Many different responses can score well.',
                  style: body(11, color: muted(c))),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _highlighted(String text, List<WritingIssue> issues) {
    final spans = <InlineSpan>[];
    var pos = 0;
    for (final i in issues) {
      if (i.length <= 0 || i.offset < pos || i.offset + i.length > text.length) continue;
      if (i.offset > pos) spans.add(TextSpan(text: text.substring(pos, i.offset)));
      spans.add(TextSpan(
        text: text.substring(i.offset, i.offset + i.length),
        style: TextStyle(
          color: _red,
          fontWeight: FontWeight.w700,
          decoration: TextDecoration.underline,
          decorationStyle: TextDecorationStyle.wavy,
          decorationColor: _red,
          backgroundColor: _red.withOpacity(.08),
        ),
      ));
      pos = i.offset + i.length;
    }
    if (pos < text.length) spans.add(TextSpan(text: text.substring(pos)));
    return Text.rich(TextSpan(style: body(12.5).copyWith(height: 1.55), children: spans));
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
class _SummaryPage extends GetView<WritingController> {
  const _SummaryPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.close_rounded), onPressed: controller.exitToHome),
        title: const Text('Writing summary'),
      ),
      body: Obx(() {
        final list = controller.store.attempts.toList();
        final secs = list.fold<int>(0, (a, r) => a + r.seconds);
        final got = list.fold<int>(0, (a, r) => a + r.buildGot);
        final tot = list.fold<int>(0, (a, r) => a + r.buildTotal);
        final avgBand = list.isEmpty ? 0.0 : list.fold<double>(0, (a, r) => a + r.band) / list.length;
        final best = list.isEmpty ? 0.0 : list.map((e) => e.band).reduce((a, b) => a > b ? a : b);

        return ListView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 24), children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: const Color(0xFF1E88E5),
              borderRadius: BorderRadius.circular(26),
              boxShadow: [BoxShadow(color: AppColors.indigo600.withOpacity(.3), blurRadius: 24, offset: const Offset(0, 12))],
            ),
            child: Column(children: [
              const Text('🏆', style: TextStyle(fontSize: 46)),
              const SizedBox(height: 8),
              Text('All ${controller.maxTests} Writing tests completed!',
                  style: poppins(20, color: Colors.white), textAlign: TextAlign.center),
              const SizedBox(height: 4),
              Text('You built $got of $tot sentences correctly.',
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

  Widget _row(BuildContext c, WritingAttempt r) => Padding(
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
            Text('${r.buildGot}/${r.buildTotal} sentences · ${r.emailWords}+${r.discWords} words · ${_fmt(r.seconds)}',
                style: body(11.5, color: muted(c))),
          ]),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration:
          BoxDecoration(color: AppColors.indigo600.withOpacity(.12), borderRadius: BorderRadius.circular(20)),
          child: Text('Band ${_bandText(r.band)}', style: body(12, w: FontWeight.w700, color: AppColors.indigo600)),
        ),
      ]),
    ),
  );
}