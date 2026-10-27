/*
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toefl_pro/app/core/theme/app_colors.dart';
import 'package:toefl_pro/app/core/widgets/common_widgets.dart';
import '../controllers/listening_controller.dart';
import '../listening_models.dart';

const _green = Color(0xFF16A34A);
const _red = Color(0xFFDC2626);

String _fmt(int s) => s >= 60 ? '${s ~/ 60}m ${s % 60}s' : '${s}s';
String _bandText(double b) => b == b.roundToDouble() ? b.toStringAsFixed(0) : b.toStringAsFixed(1);
String _letter(int i) => String.fromCharCode(65 + i); // A, B, C, D

class ListeningView extends GetView<ListeningController> {
  const ListeningView({super.key});

  @override
  Widget build(BuildContext context) => Obx(() {
    switch (controller.phase.value) {
      case ListeningPhase.loading:
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      case ListeningPhase.overview:
        return const _OverviewPage();
      case ListeningPhase.question:
        return const _QuestionPage();
      case ListeningPhase.result:
        return const _ResultPage();
      case ListeningPhase.allDone:
        return const _SummaryPage();
    }
  });
}

// ───────────── app bar for the timed test ─────────────
PreferredSizeWidget _testBar(
    BuildContext context,
    ListeningController c,
    String Function() title,
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
        c.index.value; // title/subtitle change with the question
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title(), style: const TextStyle(fontSize: 16)),
            Text(subtitle(), style: body(11, color: muted(context))),
          ],
        );
      }),
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
class _OverviewPage extends GetView<ListeningController> {
  const _OverviewPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Container(
          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.grey.shade300)),
          child: IconButton(icon: const Icon(Icons.close_rounded), onPressed: controller.exitToHome),
        ),
        title: const Text('Listening section', style: TextStyle(fontSize: 25)),
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
            Text('TOEFL iBT Listening', style: poppins(22, color: Colors.white)),
            const SizedBox(height: 2),
            Text('Responses · Conversations · Announcements · Test ${controller.testNo} of ${controller.maxTests}',
                textAlign: TextAlign.center, style: body(12.5, color: Colors.white70)),
            const SizedBox(height: 16),
            Wrap(alignment: WrapAlignment.center, spacing: 8, runSpacing: 8, children: [
              _pill('${controller.questionCount} questions'),
              _pill('~${controller.minutes} min'),
              _pill('Audio plays once'),
            ]),
          ]),
        ),
        const SizedBox(height: 22),
        const SectionHeader('Task types'),
        AppCard(
          borderColor: Colors.grey,
          child: Column(children: [
            _task(context, Icons.headphones_rounded, 'Part 1 · Choose a Response',
                'You hear one short sentence. Then choose the best reply from four options.'),
            const SizedBox(height: 14),
            _task(context, Icons.forum_rounded, 'Part 2 · Conversation',
                'You hear a conversation between two students, then answer 4 questions about it.'),
            const SizedBox(height: 14),
            _task(context, Icons.campaign_rounded, 'Part 2 · Announcement',
                'You hear a campus announcement, then answer 4 questions about it.'),
          ]),
        ),
        const SizedBox(height: 18),
        const SectionHeader('Before you begin'),
        AppCard(
          borderColor: Colors.grey,
          child: Column(children: [
            _rule('Use headphones or turn the volume up in a quiet place.'),
            _rule('Every audio plays only once. You cannot replay it during the test.'),
            _rule('The answer options appear after the audio finishes.'),
            _rule('For a conversation or announcement, all questions use the same audio.'),
            _rule('You cannot go back to a previous question.'),
            _rule('Take short notes on names, numbers, days and times while you listen.'),
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

  Widget _task(BuildContext context, IconData icon, String title, String desc) =>
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: tint(context, AppColors.indigo600),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey),
          ),
          child: Icon(icon, color: AppColors.indigo600),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: poppins(14)),
            const SizedBox(height: 2),
            Text(desc, style: body(11.5, color: muted(context)).copyWith(height: 1.4)),
          ]),
        ),
      ]);

  Widget _pill(String t) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
    child: Text(t, style: body(11.5, w: FontWeight.w600, color: Colors.white)),
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

// ═════════════════════════ QUESTION ═════════════════════════
class _QuestionPage extends GetView<ListeningController> {
  const _QuestionPage();

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final total = c.current.questions.length;
    return PopScope(
      canPop: false,
      onPopInvoked: (_) => c.confirmExit(),
      child: Scaffold(
        appBar: _testBar(
          context,
          c,
              () => 'Listening\n${c.current.questions[c.index.value].sectionTitle}',
              () => 'Question ${c.index.value + 1} of $total',
        ),
        body: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 2, 20, 6),
            child: Obx(() => ThinProgress((c.index.value + 1) / total, height: 4)),
          ),
          Expanded(
            child: Obx(() {
              final i = c.index.value;
              final q = c.current.questions[i];
              final stage = c.audioStage.value;
              final order = c.optionOrder[i];
              final chosen = c.answers[i];
              final showOptions = stage == AudioStage.done || stage == AudioStage.error;

              return ListView(
                key: ValueKey(i),
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                children: [
                  _audioCard(context, q, stage),
                  if (stage == AudioStage.error) ...[
                    const SizedBox(height: 12),
                    AppCard(
                      borderColor: Colors.grey,
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(q.isGroup ? 'TRANSCRIPT' : 'THE SPEAKER SAYS',
                            style: body(10.5, w: FontWeight.w700, color: AppColors.indigo600)),
                        const SizedBox(height: 6),
                        Text(q.isGroup ? q.transcript : '“${q.transcript}”',
                            style: (q.isGroup ? body(13) : poppins(15)).copyWith(height: 1.45)),
                      ]),
                    ),
                  ],
                  if (showOptions) ...[
                    const SizedBox(height: 18),
                    Text(q.isGroup ? q.sentence : 'Choose the best response.',
                        style: poppins(q.isGroup ? 15 : 14).copyWith(height: 1.4)),
                    const SizedBox(height: 10),
                    for (var pos = 0; pos < order.length; pos++)
                      _option(
                        context,
                        _letter(pos),
                        q.options[order[pos]],
                        chosen == order[pos],
                            () => c.choose(order[pos]),
                      ),
                  ],
                ],
              );
            }),
          ),
          _bottomBar(context),
        ]),
      ),
    );
  }

  Widget _audioCard(BuildContext context, ListeningQuestion q, AudioStage stage) {
    final playing = stage == AudioStage.playing || stage == AudioStage.idle;
    final failed = stage == AudioStage.error;
    final color = failed ? _red : (playing ? AppColors.blueColor : _green);
    final icon = failed
        ? Icons.error_outline_rounded
        : (playing ? Icons.volume_up_rounded : Icons.check_rounded);

    final what = q.isGroup ? (q.groupLabel ?? 'audio').toLowerCase() : 'sentence';
    final title = failed
        ? 'Audio could not be played'
        : (playing ? 'Listen carefully…' : 'Audio finished');
    final String sub;
    if (failed) {
      sub = 'Check that the audio file exists and the folder is listed in pubspec.yaml.';
    } else if (playing) {
      sub = 'You will hear this $what only once.';
    } else if (q.isGroup) {
      sub = 'Question ${q.groupPos} of ${q.groupSize} about this $what.';
    } else {
      sub = 'Now choose the best response.';
    }

    return AppCard(
      borderColor: Colors.grey,
      child: Column(children: [
        Row(children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: color.withOpacity(.12), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: poppins(15)),
              const SizedBox(height: 2),
              Text(sub, style: body(12, color: muted(context)).copyWith(height: 1.4)),
            ]),
          ),
        ]),
        if (playing) ...[
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(minHeight: 5, color: AppColors.blueColor),
          ),
        ],
      ]),
    );
  }

  Widget _option(BuildContext ctx, String letter, String text, bool selected, VoidCallback onTap) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Material(
      color: selected ? tint(ctx, AppColors.blueColor) : Theme.of(ctx).cardColor,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: selected ? AppColors.blueColor : Colors.grey, width: selected ? 1.6 : 0.8),
          ),
          child: Row(children: [
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? AppColors.blueColor : Colors.transparent,
                border: Border.all(color: selected ? AppColors.blueColor : Colors.grey),
              ),
              child: Text(letter,
                  style: selected
                      ? body(12.5, w: FontWeight.w700, color: Colors.white)
                      : body(12.5, w: FontWeight.w700)),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(text, style: body(14, w: FontWeight.w600).copyWith(height: 1.35))),
          ]),
        ),
      ),
    ),
  );

  Widget _bottomBar(BuildContext context) => SafeArea(
    top: false,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Obx(() {
        final ready = controller.canAdvance;
        final last = controller.index.value == controller.current.questions.length - 1;
        return Opacity(
          opacity: ready ? 1 : 0.45,
          child: IgnorePointer(
            ignoring: !ready,
            child: PrimaryButton(last ? 'Finish' : 'Next', onPressed: controller.next),
          ),
        );
      }),
    ),
  );
}

// ═════════════════════════ RESULT ═════════════════════════
class _ResultPage extends GetView<ListeningController> {
  const _ResultPage();

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final more = c.store.canStart;
    final total = c.current.questions.length;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.close_rounded), onPressed: c.exitToHome),
        title: Text('Test ${c.currentTestNo} results'),
      ),
      body: ListView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 20), children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1E88E5),
            borderRadius: BorderRadius.circular(26),
            boxShadow: [BoxShadow(color: AppColors.indigo600.withOpacity(.3), blurRadius: 24, offset: const Offset(0, 12))],
          ),
          child: Row(children: [
            ProgressRing(((c.band - 1) / 5).clamp(0.0, 1.0),
                size: 96,
                color: Colors.white,
                trackColor: Colors.white24,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text(_bandText(c.band), style: poppins(24, color: Colors.white)),
                  Text('of 6', style: body(10, color: Colors.white70)),
                ])),
            const SizedBox(width: 18),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Estimated band', style: body(12, color: Colors.white70)),
                Text('${_bandText(c.band)} / 6', style: poppins(22, color: Colors.white)),
                const SizedBox(height: 4),
                Text('${c.got} of $total correct', style: body(11.5, color: Colors.white70)),
              ]),
            ),
          ]),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text('Practice estimate only, not an official ETS score. Total time: ${_fmt(c.totalSeconds)}.',
              style: body(11, color: muted(context))),
        ),
        const SizedBox(height: 22),
        const SectionHeader('Review'),
        for (var i = 0; i < total; i++) _review(context, i),
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

  Widget _review(BuildContext ctx, int i) {
    final q = controller.current.questions[i];
    final chosen = controller.answers[i];
    final ok = controller.isCorrect(i);
    final heading = q.isGroup ? 'Q${i + 1} · ${q.sentence}' : 'Q${i + 1} · “${q.sentence}”';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Part 2: label above the first question of every conversation / announcement
          if (q.isGroup && q.groupStart)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                (q.groupLabel ?? '').toUpperCase(),
                style: body(10.5, w: FontWeight.w700, color: AppColors.indigo600),
              ),
            ),
          Row(children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(shape: BoxShape.circle, color: (ok ? _green : _red).withOpacity(.12)),
              child: Icon(ok ? Icons.check_rounded : Icons.close_rounded, size: 15, color: ok ? _green : _red),
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(heading, style: body(12, color: muted(ctx)))),
            Obx(() {
              final on = controller.reviewPlaying.value == i;
              return IconButton(
                tooltip: on ? 'Stop' : 'Listen again',
                visualDensity: VisualDensity.compact,
                onPressed: () => controller.playReview(i),
                icon: Icon(on ? Icons.stop_circle_outlined : Icons.play_circle_outline_rounded,
                    color: AppColors.blueColor),
              );
            }),
          ]),
          const SizedBox(height: 8),
          _answer(ctx, 'Your answer', chosen < 0 ? 'Not answered' : q.options[chosen], ok ? _green : _red),
          if (!ok) ...[
            const SizedBox(height: 6),
            _answer(ctx, 'Correct answer', q.answerText, _green),
          ],
          // Transcript (once per conversation / announcement)
          if (q.isGroup && q.groupStart && q.script != null)
            Theme(
              data: Theme.of(ctx).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: EdgeInsets.zero,
                childrenPadding: const EdgeInsets.only(bottom: 8),
                title: Text('Show transcript', style: body(12.5, w: FontWeight.w700, color: AppColors.blueColor)),
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(q.script!, style: body(12.5, color: muted(ctx)).copyWith(height: 1.5)),
                  ),
                ],
              ),
            ),
        ]),
      ),
    );
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
class _SummaryPage extends GetView<ListeningController> {
  const _SummaryPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.close_rounded), onPressed: controller.exitToHome),
        title: const Text('Listening summary'),
      ),
      body: Obx(() {
        final list = controller.store.attempts.toList();
        final secs = list.fold<int>(0, (a, r) => a + r.seconds);
        final got = list.fold<int>(0, (a, r) => a + r.got);
        final tot = list.fold<int>(0, (a, r) => a + r.total);
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
              Text('All ${controller.maxTests} Listening tests completed!',
                  style: poppins(20, color: Colors.white), textAlign: TextAlign.center),
              const SizedBox(height: 4),
              Text('You answered $got of $tot questions correctly.',
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

  Widget _row(BuildContext c, ListeningAttempt r) => Padding(
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
            Text('${r.got}/${r.total} correct · ${_fmt(r.seconds)}', style: body(11.5, color: muted(c))),
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
}*/
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:toefl_pro/app/core/theme/app_colors.dart';
import 'package:toefl_pro/app/core/widgets/common_widgets.dart';
import '../controllers/listening_controller.dart';
import '../listening_models.dart';

const _green = Color(0xFF16A34A);
const _red = Color(0xFFDC2626);

/// Pictures shown while the audio plays (replaced by the answer options when
/// the audio finishes). Nothing to configure: the app scans every image in `assets/`
/// and sorts every picture by a word in its path or file name:
///   announcement / announce / notice        -> announcements
///   conversation / convers / dialog / chat  -> conversations
///   talk / short / sentence / response      -> short "simple talking"
/// e.g. announcement1.png, conversation_2.jpg, simple_talking.webp,
/// or any folder such as assets/images/announcement/a.png
class _ArtLib {
  static final ready = 0.obs; // flips to 1 once the scan has finished
  static bool _started = false;
  static List<String> talking = [];
  static List<String> conversation = [];
  static List<String> announcement = [];
  static String? fallback; // used when a type has no picture of its own

  static const _ext = ['.png', '.jpg', '.jpeg', '.webp', '.gif'];

  static Future<void> load() async {
    if (_started) return;
    _started = true;
    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final all = manifest
          .listAssets()
          .where((a) => a.startsWith('assets/') && _ext.any(a.toLowerCase().endsWith))
          .toList()
        ..sort();
      bool has(String a, List<String> words) {
        final l = a.toLowerCase();
        return words.any(l.contains);
      }

      announcement = all.where((a) => has(a, ['announce', 'notice'])).toList();
      conversation = all.where((a) => !announcement.contains(a) && has(a, ['convers', 'dialog', 'chat'])).toList();
      talking = all
          .where((a) => !announcement.contains(a) && !conversation.contains(a) && has(a, ['talk', 'short', 'sentence', 'response']))
          .toList();
      fallback = all.contains('assets/images/listening.png') ? 'assets/images/listening.png' : null;
      debugPrint('LISTENING IMAGES found in assets: $all');
      debugPrint('  talking=$talking');
      debugPrint('  conversation=$conversation');
      debugPrint('  announcement=$announcement');
    } catch (e) {
      debugPrint('LISTENING IMAGES scan failed: $e');
    }
    ready.value = 1;
  }
}

/// Picks the image list by question type, then one image from it.
/// The choice depends only on the audio file, so it never changes on rebuild.
/// Returns null when no matching picture was found.
String? _imageFor(ListeningQuestion q) {
  final list = !q.isGroup
      ? _ArtLib.talking
      : (q.groupLabel == 'Announcement' ? _ArtLib.announcement : _ArtLib.conversation);
  if (list.isEmpty) return _ArtLib.fallback;
  return list[q.audio.hashCode.abs() % list.length];
}

String _fmt(int s) => s >= 60 ? '${s ~/ 60}m ${s % 60}s' : '${s}s';
String _bandText(double b) => b == b.roundToDouble() ? b.toStringAsFixed(0) : b.toStringAsFixed(1);
String _letter(int i) => String.fromCharCode(65 + i); // A, B, C, D

class ListeningView extends GetView<ListeningController> {
  const ListeningView({super.key});

  @override
  Widget build(BuildContext context) => Obx(() {
    switch (controller.phase.value) {
      case ListeningPhase.loading:
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      case ListeningPhase.overview:
        return const _OverviewPage();
      case ListeningPhase.question:
        return const _QuestionPage();
      case ListeningPhase.result:
        return const _ResultPage();
      case ListeningPhase.allDone:
        return const _SummaryPage();
    }
  });
}

// ───────────── app bar for the timed test ─────────────
PreferredSizeWidget _testBar(
    BuildContext context,
    ListeningController c,
    String Function() title,
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
        c.index.value; // title/subtitle change with the question
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title(), style: const TextStyle(fontSize: 16)),
            Text(subtitle(), style: body(11, color: muted(context))),
          ],
        );
      }),
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
class _OverviewPage extends GetView<ListeningController> {
  const _OverviewPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Container(
          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.grey.shade300)),
          child: IconButton(icon: const Icon(Icons.close_rounded), onPressed: controller.exitToHome),
        ),
        title: const Text('Listening section', style: TextStyle(fontSize: 25)),
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
            Text('TOEFL iBT Listening', style: poppins(22, color: Colors.white)),
            const SizedBox(height: 2),
            Text('Responses · Conversations · Announcements · Test ${controller.testNo} of ${controller.maxTests}',
                textAlign: TextAlign.center, style: body(12.5, color: Colors.white70)),
            const SizedBox(height: 16),
            Wrap(alignment: WrapAlignment.center, spacing: 8, runSpacing: 8, children: [
              _pill('${controller.questionCount} questions'),
              _pill('~${controller.minutes} min'),
              _pill('Audio plays once'),
            ]),
          ]),
        ),
        const SizedBox(height: 22),
        const SectionHeader('Task types'),
        AppCard(
          borderColor: Colors.grey,
          child: Column(children: [
            _task(context, Icons.headphones_rounded, 'Part 1 · Choose a Response',
                'You hear one short sentence. Then choose the best reply from four options.'),
            const SizedBox(height: 14),
            _task(context, Icons.forum_rounded, 'Part 2 · Conversation',
                'You hear a conversation between two students, then answer 4 questions about it.'),
            const SizedBox(height: 14),
            _task(context, Icons.campaign_rounded, 'Part 2 · Announcement',
                'You hear a campus announcement, then answer 4 questions about it.'),
          ]),
        ),
        const SizedBox(height: 18),
        const SectionHeader('Before you begin'),
        AppCard(
          borderColor: Colors.grey,
          child: Column(children: [
            _rule('Use headphones or turn the volume up in a quiet place.'),
            _rule('Every audio plays only once. You cannot replay it during the test.'),
            _rule('The answer options appear after the audio finishes.'),
            _rule('For a conversation or announcement, all questions use the same audio.'),
            _rule('You cannot go back to a previous question.'),
            _rule('Take short notes on names, numbers, days and times while you listen.'),
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

  Widget _task(BuildContext context, IconData icon, String title, String desc) =>
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: tint(context, AppColors.indigo600),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey),
          ),
          child: Icon(icon, color: AppColors.indigo600),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: poppins(14)),
            const SizedBox(height: 2),
            Text(desc, style: body(11.5, color: muted(context)).copyWith(height: 1.4)),
          ]),
        ),
      ]);

  Widget _pill(String t) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
    child: Text(t, style: body(11.5, w: FontWeight.w600, color: Colors.white)),
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

// ═════════════════════════ QUESTION ═════════════════════════
class _QuestionPage extends GetView<ListeningController> {
  const _QuestionPage();

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final total = c.current.questions.length;
    return PopScope(
      canPop: false,
      onPopInvoked: (_) => c.confirmExit(),
      child: Scaffold(
        appBar: _testBar(
          context,
          c,
              () => 'Listening\n${c.current.questions[c.index.value].sectionTitle}',
              () => 'Question ${c.index.value + 1} of $total',
        ),
        body: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 2, 20, 6),
            child: Obx(() => ThinProgress((c.index.value + 1) / total, height: 4)),
          ),
          Expanded(
            child: Obx(() {
              _ArtLib.load();
              _ArtLib.ready.value; // rebuild when the scan finishes
              final i = c.index.value;
              final q = c.current.questions[i];
              final stage = c.audioStage.value;
              final order = c.optionOrder[i];
              final chosen = c.answers[i];
              final showOptions = stage == AudioStage.done || stage == AudioStage.error;

              return ListView(
                key: ValueKey(i),
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                children: [
                  _audioCard(context, q, stage),
                  // While listening: show the image. After the audio: options replace it.
                  if (!showOptions) ...[
                    const SizedBox(height: 18),
                    _listeningArt(context, q),
                  ],
                  if (stage == AudioStage.error) ...[
                    const SizedBox(height: 12),
                    AppCard(
                      borderColor: Colors.grey,
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(q.isGroup ? 'TRANSCRIPT' : 'THE SPEAKER SAYS',
                            style: body(10.5, w: FontWeight.w700, color: AppColors.indigo600)),
                        const SizedBox(height: 6),
                        Text(q.isGroup ? q.transcript : '“${q.transcript}”',
                            style: (q.isGroup ? body(13) : poppins(15)).copyWith(height: 1.45)),
                      ]),
                    ),
                  ],
                  if (showOptions) ...[
                    const SizedBox(height: 18),
                    Text(q.isGroup ? q.sentence : 'Choose the best response.',
                        style: poppins(q.isGroup ? 15 : 14).copyWith(height: 1.4)),
                    const SizedBox(height: 10),
                    for (var pos = 0; pos < order.length; pos++)
                      _option(
                        context,
                        _letter(pos),
                        q.options[order[pos]],
                        chosen == order[pos],
                            () => c.choose(order[pos]),
                      ),
                  ],
                ],
              );
            }),
          ),
          _bottomBar(context),
        ]),
      ),
    );
  }

  Widget _listeningArt(BuildContext context, ListeningQuestion q) {
    final path = _imageFor(q);
    Widget placeholder() => Container(
      width: double.infinity,
      height: 260,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.blueColor.withOpacity(.06),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(Icons.headphones_rounded, size: 84, color: AppColors.blueColor.withOpacity(.35)),
    );
    if (path == null) return placeholder();
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Image.asset(
        path,
        width: double.infinity,
        height: 260,
        fit: BoxFit.contain,
        errorBuilder: (_, error, __) {
          debugPrint('IMAGE ERROR -> $path : $error');
          return placeholder();
        },
      ),
    );
  }

  Widget _audioCard(BuildContext context, ListeningQuestion q, AudioStage stage) {
    final playing = stage == AudioStage.playing || stage == AudioStage.idle;
    final failed = stage == AudioStage.error;
    final color = failed ? _red : (playing ? AppColors.blueColor : _green);
    final icon = failed
        ? Icons.error_outline_rounded
        : (playing ? Icons.volume_up_rounded : Icons.check_rounded);

    final what = q.isGroup ? (q.groupLabel ?? 'audio').toLowerCase() : 'sentence';
    final title = failed
        ? 'Audio could not be played'
        : (playing ? 'Listen carefully…' : 'Audio finished');
    final String sub;
    if (failed) {
      sub = 'Check that the audio file exists and the folder is listed in pubspec.yaml.';
    } else if (playing) {
      sub = 'You will hear this $what only once.';
    } else if (q.isGroup) {
      sub = 'Question ${q.groupPos} of ${q.groupSize} about this $what.';
    } else {
      sub = 'Now choose the best response.';
    }

    return AppCard(
      borderColor: Colors.grey,
      child: Column(children: [
        Row(children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: color.withOpacity(.12), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: poppins(15)),
              const SizedBox(height: 2),
              Text(sub, style: body(12, color: muted(context)).copyWith(height: 1.4)),
            ]),
          ),
        ]),
        if (playing) ...[
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(minHeight: 5, color: AppColors.blueColor),
          ),
        ],
      ]),
    );
  }

  Widget _option(BuildContext ctx, String letter, String text, bool selected, VoidCallback onTap) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Material(
      color: selected ? tint(ctx, AppColors.blueColor) : Theme.of(ctx).cardColor,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: selected ? AppColors.blueColor : Colors.grey, width: selected ? 1.6 : 0.8),
          ),
          child: Row(children: [
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? AppColors.blueColor : Colors.transparent,
                border: Border.all(color: selected ? AppColors.blueColor : Colors.grey),
              ),
              child: Text(letter,
                  style: selected
                      ? body(12.5, w: FontWeight.w700, color: Colors.white)
                      : body(12.5, w: FontWeight.w700)),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(text, style: body(14, w: FontWeight.w600).copyWith(height: 1.35))),
          ]),
        ),
      ),
    ),
  );

  Widget _bottomBar(BuildContext context) => SafeArea(
    top: false,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Obx(() {
        final ready = controller.canAdvance;
        final last = controller.index.value == controller.current.questions.length - 1;
        return Opacity(
          opacity: ready ? 1 : 0.45,
          child: IgnorePointer(
            ignoring: !ready,
            child: PrimaryButton(last ? 'Finish' : 'Next', onPressed: controller.next),
          ),
        );
      }),
    ),
  );
}

// ═════════════════════════ RESULT ═════════════════════════
class _ResultPage extends GetView<ListeningController> {
  const _ResultPage();

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final more = c.store.canStart;
    final total = c.current.questions.length;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.close_rounded), onPressed: c.exitToHome),
        title: Text('Test ${c.currentTestNo} results'),
      ),
      body: ListView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 20), children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1E88E5),
            borderRadius: BorderRadius.circular(26),
            boxShadow: [BoxShadow(color: AppColors.indigo600.withOpacity(.3), blurRadius: 24, offset: const Offset(0, 12))],
          ),
          child: Row(children: [
            ProgressRing(((c.band - 1) / 5).clamp(0.0, 1.0),
                size: 96,
                color: Colors.white,
                trackColor: Colors.white24,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text(_bandText(c.band), style: poppins(24, color: Colors.white)),
                  Text('of 6', style: body(10, color: Colors.white70)),
                ])),
            const SizedBox(width: 18),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Estimated band', style: body(12, color: Colors.white70)),
                Text('${_bandText(c.band)} / 6', style: poppins(22, color: Colors.white)),
                const SizedBox(height: 4),
                Text('${c.got} of $total correct', style: body(11.5, color: Colors.white70)),
              ]),
            ),
          ]),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text('Practice estimate only, not an official ETS score. Total time: ${_fmt(c.totalSeconds)}.',
              style: body(11, color: muted(context))),
        ),
        const SizedBox(height: 22),
        const SectionHeader('Review'),
        for (var i = 0; i < total; i++) _review(context, i),
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

  Widget _review(BuildContext ctx, int i) {
    final q = controller.current.questions[i];
    final chosen = controller.answers[i];
    final ok = controller.isCorrect(i);
    final heading = q.isGroup ? 'Q${i + 1} · ${q.sentence}' : 'Q${i + 1} · “${q.sentence}”';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Part 2: label above the first question of every conversation / announcement
          if (q.isGroup && q.groupStart)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                (q.groupLabel ?? '').toUpperCase(),
                style: body(10.5, w: FontWeight.w700, color: AppColors.indigo600),
              ),
            ),
          Row(children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(shape: BoxShape.circle, color: (ok ? _green : _red).withOpacity(.12)),
              child: Icon(ok ? Icons.check_rounded : Icons.close_rounded, size: 15, color: ok ? _green : _red),
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(heading, style: body(12, color: muted(ctx)))),
            Obx(() {
              final on = controller.reviewPlaying.value == i;
              return IconButton(
                tooltip: on ? 'Stop' : 'Listen again',
                visualDensity: VisualDensity.compact,
                onPressed: () => controller.playReview(i),
                icon: Icon(on ? Icons.stop_circle_outlined : Icons.play_circle_outline_rounded,
                    color: AppColors.blueColor),
              );
            }),
          ]),
          const SizedBox(height: 8),
          _answer(ctx, 'Your answer', chosen < 0 ? 'Not answered' : q.options[chosen], ok ? _green : _red),
          if (!ok) ...[
            const SizedBox(height: 6),
            _answer(ctx, 'Correct answer', q.answerText, _green),
          ],
          // Transcript (once per conversation / announcement)
          if (q.isGroup && q.groupStart && q.script != null)
            Theme(
              data: Theme.of(ctx).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: EdgeInsets.zero,
                childrenPadding: const EdgeInsets.only(bottom: 8),
                title: Text('Show transcript', style: body(12.5, w: FontWeight.w700, color: AppColors.blueColor)),
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(q.script!, style: body(12.5, color: muted(ctx)).copyWith(height: 1.5)),
                  ),
                ],
              ),
            ),
        ]),
      ),
    );
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
class _SummaryPage extends GetView<ListeningController> {
  const _SummaryPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.close_rounded), onPressed: controller.exitToHome),
        title: const Text('Listening summary'),
      ),
      body: Obx(() {
        final list = controller.store.attempts.toList();
        final secs = list.fold<int>(0, (a, r) => a + r.seconds);
        final got = list.fold<int>(0, (a, r) => a + r.got);
        final tot = list.fold<int>(0, (a, r) => a + r.total);
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
              Text('All ${controller.maxTests} Listening tests completed!',
                  style: poppins(20, color: Colors.white), textAlign: TextAlign.center),
              const SizedBox(height: 4),
              Text('You answered $got of $tot questions correctly.',
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

  Widget _row(BuildContext c, ListeningAttempt r) => Padding(
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
            Text('${r.got}/${r.total} correct · ${_fmt(r.seconds)}', style: body(11.5, color: muted(c))),
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