import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toefl_pro/app/core/theme/app_colors.dart';
import 'package:toefl_pro/app/core/widgets/common_widgets.dart';
import '../controllers/speaking_controller.dart';
import '../speaking_checker.dart';
import '../speaking_models.dart';

const _green = Color(0xFF16A34A);
const _red = Color(0xFFDC2626);

String _fmt(int s) => s >= 60 ? '${s ~/ 60}m ${s % 60}s' : '${s}s';
String _bandText(double b) => b == b.roundToDouble() ? b.toStringAsFixed(0) : b.toStringAsFixed(1);

Widget _chip(String text, Color color) => Container(
  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
  decoration: BoxDecoration(
    //  color: Colors.blue.shade100,
      borderRadius: BorderRadius.circular(20)),
  child: Text(text, style: body(
      11,
      w: FontWeight.w600,

      color: color)),
);

class SpeakingView extends GetView<SpeakingController> {
  const SpeakingView({super.key});

  @override
  Widget build(BuildContext context) => Obx(() {
    switch (controller.phase.value) {
      case SpeakingPhase.loading:
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      case SpeakingPhase.overview:
        return const _OverviewPage();
      case SpeakingPhase.repeat:
        return const _RepeatPage();
      case SpeakingPhase.interview:
        return const _InterviewPage();
      case SpeakingPhase.result:
        return const _ResultPage();
      case SpeakingPhase.allDone:
        return const _SummaryPage();
    }
  });
}

// ───────────── shared app bar for the two timed stages ─────────────
PreferredSizeWidget _testBar(
    BuildContext context,
    SpeakingController c,
    String title,
    String Function() subtitle) =>
    AppBar(
      toolbarHeight: 90,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
                color: Colors.grey.withValues(alpha: 0.25),
                width: 1),
          ),
          child: IconButton(
            icon: const Icon(Icons.close_rounded,
                size: 22),
            onPressed: c.confirmExit,
            tooltip: 'Exit test',
            padding: EdgeInsets.zero,
          ),
        ),
      ),
      title: Obx(() {
        c.phase.value; // Obx must always read an observable
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18)),
            Text(subtitle(), style: body(11, color: muted(context))),
          ],
        );
      }),
      actions: [
        Obx(() => (c.hideTime.value || c.timer.value == null)
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

/// Big status card: headphones → speaker → microphone.
Widget _voiceCard(BuildContext context, SpeakingController c, {required String readyTitle, required String readySub}) =>
    Obx(() {
      final s = c.step.value;
      IconData icon;
      Color color;
      String title, sub;
      if (s == SpeakStep.playing) {
        icon = Icons.volume_up_rounded;
        color = AppColors.indigo600;
        title = 'Listen carefully…';
        sub = 'The audio plays only once.';
      } else if (s == SpeakStep.recording) {
        icon = Icons.mic_rounded;
        color = _red;
        title = 'Speak now';
        sub = c.liveText.value.isEmpty ? 'Listening…' : c.liveText.value;
      } else if (s == SpeakStep.saving) {
        icon = Icons.hourglass_top_rounded;
        color = AppColors.amber;
        title = 'Saving your answer…';
        sub = 'One moment.';
      } else {
        icon = Icons.headphones_rounded;
        color = AppColors.blueColor;
        title = readyTitle;
        sub = readySub;
      }
      return AppCard(
        borderColor: s == SpeakStep.recording ? _red : Colors.grey,
        child: SizedBox(
          width: double.infinity,
          child: Column(children: [
            const SizedBox(height: 6),
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(shape: BoxShape.circle, color: color.withOpacity(.12)),
              child: Icon(icon, size: 40, color: color),
            ),
            const SizedBox(height: 14),
            Text(title, style: poppins(16), textAlign: TextAlign.center),
            const SizedBox(height: 6),
            Text(sub,
                textAlign: TextAlign.center,
                style: body(12.5, color: muted(context)).copyWith(height: 1.5)),
            const SizedBox(height: 6),
          ]),
        ),
      );
    });

/// Bottom button that changes with the step.
Widget _actionBar(SpeakingController c, {required String startLabel, required VoidCallback onStart, required String doneLabel}) =>
    SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
        child: Obx(() {
          switch (c.step.value) {
            case SpeakStep.ready:
              return PrimaryButton(startLabel, onPressed: onStart);
            case SpeakStep.playing:
              return PrimaryButton('Listening…', onPressed: () {});
            case SpeakStep.recording:
              return PrimaryButton(doneLabel, onPressed: c.finishAnswer);
            case SpeakStep.saving:
              return PrimaryButton('Saving…', onPressed: () {});
          }
        }),
      ),
    );

// ═════════════════════════ OVERVIEW ═════════════════════════
class _OverviewPage extends GetView<SpeakingController> {
  const _OverviewPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Container(
          decoration: BoxDecoration(shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade300)),
          child: IconButton(icon: const Icon(Icons.close_rounded),
              onPressed: controller.exitToHome),
        ),
        title: const Text('Speaking section',
            style: TextStyle(fontSize: 25)),
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
            Text('TOEFL iBT Speaking', style: poppins(22, color: Colors.white)),
            const SizedBox(height: 2),
            Text('Full test simulation · Test ${controller.testNo} of ${controller.maxTests}',
                style: body(12.5, color: Colors.white70)),
            const SizedBox(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              _pill('2 tasks'),
              const SizedBox(width: 8),
              _pill('~8 min'),
              const SizedBox(width: 8),
              _pill('11 items'),
            ]),
          ]),
        ),
        const SizedBox(height: 22),
        const SectionHeader('Task types'),
        _taskRow(context, Icons.hearing_rounded, AppColors.indigo600, 'Listen and Repeat',
            '7 sentences, getting longer. Each one plays once. Repeat it exactly as you heard it.'),
        _taskRow(context, Icons.record_voice_over_rounded, AppColors.teal600, 'Take an Interview',
            '4 questions on one topic. You have 45 seconds to answer each one.'),
        const SizedBox(height: 10),
        const SectionHeader('Before you begin'),
        AppCard(
          borderColor: Colors.grey,
          child: Column(children: [
            _rule('Find a quiet place and allow microphone access when asked.'),
            _rule('Turn the volume up. Each sentence and question plays only once.'),
            _rule('Speak clearly at a natural speed. Recording starts automatically after the audio.'),
            _rule('You can tap "Done speaking" early. Time is also limited, like the real test.'),
            _rule('Both tasks are scored automatically: word accuracy, length, pace, grammar and clarity. You also see a model answer.'),
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

// ═════════════════════════ STAGE 1 · LISTEN AND REPEAT ═════════════════════════
class _RepeatPage extends GetView<SpeakingController> {
  const _RepeatPage();

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final n = c.current.repeats.length;
    return PopScope(
      canPop: false,
      onPopInvoked: (_) => c.confirmExit(),
      child: Scaffold(
        appBar: _testBar(context, c, 'Speaking\n Listen and Repeat', () => 'Sentence ${c.index.value + 1} of $n'),
        body: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 2, 20, 6),
            child: Obx(() => ThinProgress(
                (c.index.value + (c.step.value == SpeakStep.ready ? 0 : .5)) / n,
                height: 4)),
          ),
          Expanded(
            child: ListView(padding: const EdgeInsets.fromLTRB(20, 10, 20, 24), children: [
              Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                 // color: Colors.blue.shade100,
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Listen to each sentence once. When it ends, repeat it exactly as you heard it.',
                  style: body(12.5).copyWith(height: 1.45),
                ),
              ),
              AppCard(
                borderColor: Colors.grey,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('SCENE', style: body(10.5, w: FontWeight.w700, color: AppColors.indigo600)),
                  const SizedBox(height: 6),
                  Text(c.current.scene, style: poppins(15).copyWith(height: 1.45)),
                ]),
              ),
              const SizedBox(height: 14),
              _voiceCard(context, c,
                  readyTitle: 'Ready?',
                  readySub: 'Tap Start. The first sentence plays right away, then the next ones follow automatically.'),
            ]),
          ),
        ]),
        bottomNavigationBar:
        _actionBar(c, startLabel: 'Start', onStart: c.beginRepeat, doneLabel: 'Done speaking'),
      ),
    );
  }
}

// ═════════════════════════ STAGE 2 · INTERVIEW ═════════════════════════
class _InterviewPage extends GetView<SpeakingController> {
  const _InterviewPage();

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final n = c.current.questions.length;
    return PopScope(
      canPop: false,
      onPopInvoked: (_) => c.confirmExit(),
      child: Scaffold(
        appBar: _testBar(context, c, 'Speaking · Take an Interview',
                () => c.step.value == SpeakStep.ready ? 'Task 2 of 2 · 45 seconds per answer' : 'Question ${c.index.value + 1} of $n'),
        body: Obx(() {
          final i = c.index.value;
          final ready = c.step.value == SpeakStep.ready;
          return ListView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 24), children: [
            AppCard(
              borderColor: Colors.grey,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  _chip(c.current.topic, AppColors.blueColor),
                  const Spacer(),
                  Text(c.current.interviewer, style: body(11.5, w: FontWeight.w600, color: muted(context))),
                ]),
                const SizedBox(height: 10),
                if (ready)
                  Text(
                    '${c.current.interviewer} will interview you about "${c.current.topic}". You will hear $n questions. '
                        'After each question, speak for up to 45 seconds. Give your opinion, a reason, and an example.',
                    style: body(13.5).copyWith(height: 1.55),
                  )
                else ...[
                  Text('QUESTION ${i + 1}',
                      style: body(10.5, w: FontWeight.w700, color: AppColors.indigo600)),
                  const SizedBox(height: 6),
                  Text(c.current.questions[i].question, style: body(13.5).copyWith(height: 1.55)),
                ],
              ]),
            ),
            const SizedBox(height: 14),
            _voiceCard(context, c,
                readyTitle: 'Ready for the interview?',
                readySub: 'Tap Start. The interviewer asks the first question right away.'),
            const SizedBox(height: 10),
            if (c.step.value == SpeakStep.recording) _counter(context, c.liveWords.value, 55, 140),
          ]);
        }),
        bottomNavigationBar:
        _actionBar(c, startLabel: 'Start interview', onStart: c.beginInterview, doneLabel: 'Done answering'),
      ),
    );
  }
}

Widget _counter(BuildContext c, int words, int lo, int hi) {
  final ok = words >= lo && words <= hi;
  return Column(children: [
    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text('$words words · suggested $lo–$hi', style: body(11.5, color: muted(c))),
      Text(words == 0 ? '' : (ok ? 'Good length' : (words < lo ? 'Keep going' : 'A bit long')),
          style: body(11.5, w: FontWeight.w600, color: ok ? AppColors.teal600 : AppColors.amber)),
    ]),
    const SizedBox(height: 6),
    ThinProgress((words / hi).clamp(0.0, 1.0), color: ok ? AppColors.teal600 : AppColors.amber, height: 5),
  ]);
}

// ═════════════════════════ RESULT ═════════════════════════
class _ResultPage extends GetView<SpeakingController> {
  const _ResultPage();

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final more = c.store.canStart;
    final nRepeat = c.current.repeats.length;
    final nQ = c.current.questions.length;

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
                  c.fullyChecked
                      ? 'Based on your repeating and the automatic interview checks'
                      : 'Checking your interview answers…',
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
            Obx(() => _scoreRow(context, 'Listen and Repeat', 'Word accuracy',
                c.repeatAcc.value < 0 ? '…' : '${(c.repeatAcc.value * 100).round()}%')),
            const Divider(height: 22),
            Obx(() => _scoreRow(context, 'Take an Interview', 'Automatic check',
                c.interviewScore.value < 0 ? '…' : '${_bandText(c.interviewScore.value)}/5')),
          ]),
        ),
        const SizedBox(height: 22),
        const SectionHeader('Review · Listen and Repeat'),
        for (var i = 0; i < nRepeat; i++) _repeatReview(context, i),
        const SizedBox(height: 10),
        const SectionHeader('Review · Take an Interview'),
        for (var i = 0; i < nQ; i++) _interviewReview(context, i),
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

  // ───────────── Listen and Repeat review ─────────────
  Widget _repeatReview(BuildContext c, int i) {
    final chk = controller.repeatChecks[i];
    final pct = chk == null ? 0 : (chk.accuracy * 100).round();
    final good = pct >= 80;
    final heard = chk?.heard ?? '';
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(shape: BoxShape.circle, color: (good ? _green : _red).withOpacity(.12)),
              child: Icon(good ? Icons.check_rounded : Icons.close_rounded, size: 15, color: good ? _green : _red),
            ),
            const SizedBox(width: 8),
            Expanded(child: Text('Sentence ${i + 1}', style: body(12, color: muted(c)))),
            Text('$pct%', style: poppins(14, color: good ? _green : _red)),
          ]),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: tint(c, AppColors.indigo600),
              borderRadius: BorderRadius.circular(12),
            ),
            child: chk == null
                ? Text(controller.current.repeats[i], style: body(12.5))
                : Text.rich(TextSpan(style: body(12.5).copyWith(height: 1.6), children: [
              for (final w in chk.target)
                TextSpan(
                  text: '${w.word} ',
                  style: TextStyle(
                    color: w.ok ? _green : _red,
                    fontWeight: FontWeight.w700,
                    decoration: w.ok ? TextDecoration.none : TextDecoration.underline,
                    decorationColor: _red,
                  ),
                ),
            ])),
          ),
          const SizedBox(height: 6),
          Text('Green = you said it · Red = missed', style: body(10.5, color: muted(c))),
          const SizedBox(height: 8),
          Text('What we heard', style: body(10.5, w: FontWeight.w700, color: muted(c))),
          const SizedBox(height: 2),
          Text(heard.isEmpty ? 'Nothing was recorded.' : '“$heard”', style: body(12.5).copyWith(height: 1.5)),
          if (chk != null && chk.extra.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text('Extra words: ${chk.extra.join(', ')}', style: body(11.5, color: AppColors.amber)),
          ],
        ]),
      ),
    );
  }

  // ───────────── Interview review ─────────────
  Widget _interviewReview(BuildContext c, int i) {
    final q = controller.current.questions[i];
    final raw = controller.interviewHeard[i];
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Question ${i + 1}', style: body(11, w: FontWeight.w700, color: muted(c))),
          const SizedBox(height: 4),
          Text(q.question, style: poppins(13).copyWith(height: 1.4)),
          const SizedBox(height: 10),
          Obx(() {
            final r = controller.interviewChecks[i];
            final issues = r?.issues ?? const <SpeechIssue>[];
            final text = r?.text ?? raw.trim();
            return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(
                    child: Text('Your answer · ${text.isEmpty ? 0 : text.split(RegExp(r'\s+')).length} words',
                        style: body(11, w: FontWeight.w700, color: muted(c)))),
                if (r != null) Text('${_bandText(r.score)} / 5', style: poppins(16, color: AppColors.indigo600)),
              ]),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: tint(c, AppColors.indigo600), borderRadius: BorderRadius.circular(12)),
                child: text.isEmpty
                    ? Text('Nothing was recorded. Check your microphone.', style: body(12.5))
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
                        Text('${l.got.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '')} / ${l.max.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '')}',
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
                  for (final m in r.issues.take(8))
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
                          Text('“${m.snippet(r.text)}”  ·  ${m.type}',
                              style: body(12, w: FontWeight.w700, color: _red)),
                          const SizedBox(height: 2),
                          Text(m.message, style: body(12).copyWith(height: 1.4)),
                          if (m.fixes.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text('Try: ${m.fixes.join('  /  ')}',
                                style: body(12, w: FontWeight.w600, color: _green)),
                          ],
                        ]),
                      ),
                    ),
                if (r.issues.length > 8)
                  Text('+ ${r.issues.length - 8} more (all underlined above)', style: body(11, color: muted(c))),
                const SizedBox(height: 4),
                Text(
                  r.online
                      ? 'Grammar checked with LanguageTool on your speech transcript. Some "mistakes" may be recognition errors. Scores are a practice estimate.'
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
                  child: Text(q.sample, style: body(12.5).copyWith(height: 1.55)),
                ),
                const SizedBox(height: 6),
                Text('This is one possible answer. Many different responses can score well.',
                    style: body(11, color: muted(c))),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  Widget _highlighted(String text, List<SpeechIssue> issues) {
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
}

// ═════════════════════════ FINAL SUMMARY ═════════════════════════
class _SummaryPage extends GetView<SpeakingController> {
  const _SummaryPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.close_rounded), onPressed: controller.exitToHome),
        title: const Text('Speaking summary'),
      ),
      body: Obx(() {
        final list = controller.store.attempts.toList();
        final secs = list.fold<int>(0, (a, r) => a + r.seconds);
        final avgRepeat = list.isEmpty ? 0.0 : list.fold<double>(0, (a, r) => a + r.repeatAcc) / list.length;
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
              Text('All ${controller.maxTests} Speaking tests completed!',
                  style: poppins(20, color: Colors.white), textAlign: TextAlign.center),
              const SizedBox(height: 4),
              Text('Your average repeat accuracy was ${(avgRepeat * 100).round()}%.',
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

  Widget _row(BuildContext c, SpeakingAttempt r) => Padding(
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
            Text(
                '${(r.repeatAcc * 100).round()}% repeat · ${r.interviewScore < 0 ? '—' : _bandText(r.interviewScore)}/5 interview · ${_fmt(r.seconds)}',
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