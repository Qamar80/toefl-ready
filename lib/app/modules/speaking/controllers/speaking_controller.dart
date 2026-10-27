import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toefl_pro/app/core/utils/countdown.dart';

import '../speaking_checker.dart';
import '../speaking_data.dart';
import '../speaking_models.dart';
import '../speaking_speech.dart';
import '../speaking_store.dart';

enum SpeakingPhase { loading, overview, repeat, interview, result, allDone }

/// ready = waiting for Start, playing = you hear the audio,
/// recording = your turn, saving = finishing the recording.
enum SpeakStep { ready, playing, recording, saving }

int _wc(String s) {
  final t = s.trim();
  return t.isEmpty ? 0 : t.split(RegExp(r'\s+')).length;
}

class SpeakingController extends GetxController {
  static const repeatSeconds = 12; // time to repeat each sentence
  static const answerSeconds = 45; // time for each interview answer

  final store = SpeakingStore.I;
  final speech = SpeechService.I;

  final phase = SpeakingPhase.loading.obs;
  final step = SpeakStep.ready.obs;
  final hideTime = false.obs;
  final timer = Rxn<Countdown>();

  final index = 0.obs; // current sentence / question
  final liveText = ''.obs;
  final liveWords = 0.obs;

  // Result state
  final band = 1.0.obs;
  final repeatAcc = (-1.0).obs;
  final interviewScore = (-1.0).obs;
  final repeatChecks = <RepeatCheck?>[].obs;
  final interviewChecks = <InterviewCheck?>[].obs;

  late SpeakingTest current;
  List<String> repeatHeard = [];
  List<String> interviewHeard = [];
  List<int> interviewSecs = [];
  List<double> interviewConf = [];
  int totalSeconds = 0;
  int currentTestNo = 1;
  SpeakingAttempt? attempt;

  bool _aborted = false;
  Completer<void>? _stop;
  Timer? _silence;
  final _total = Stopwatch();
  final _rnd = Random();

  int get testNo => store.attempts.length + 1;
  int get maxTests => store.maxTests;

  @override
  void onInit() {
    super.onInit();
    _init();
  }

  Future<void> _init() async {
    await store.ensureLoaded();
    phase.value = store.canStart ? SpeakingPhase.overview : SpeakingPhase.allDone;
  }

  // ───────────── Test lifecycle ─────────────
  Future<void> startTest() async {
    final pick = SpeakingBank.pick(store.used, _rnd);
    if (pick == null) {
      phase.value = SpeakingPhase.allDone;
      return;
    }
    final ok = await speech.init();
    if (!ok) {
      Get.snackbar('Microphone needed',
          'Please allow microphone and speech recognition, and make sure speech recognition is available on this device.',
          snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(16));
      return;
    }
    current = pick;
    currentTestNo = testNo;
    _aborted = false;
    totalSeconds = 0;
    attempt = null;
    repeatHeard = List.filled(current.repeats.length, '');
    interviewHeard = List.filled(current.questions.length, '');
    interviewSecs = List.filled(current.questions.length, 0);
    interviewConf = List.filled(current.questions.length, -1.0);
    repeatChecks.assignAll(List<RepeatCheck?>.filled(current.repeats.length, null));
    interviewChecks.assignAll(List<InterviewCheck?>.filled(current.questions.length, null));
    repeatAcc.value = -1.0;
    interviewScore.value = -1.0;
    band.value = 1.0;
    index.value = 0;
    liveText.value = '';
    liveWords.value = 0;
    step.value = SpeakStep.ready;
    timer.value?.stop();
    timer.value = null;
    _total
      ..reset()
      ..start();
    phase.value = SpeakingPhase.repeat;
  }

  // ───────────── one "listen, then speak" round ─────────────
  void _openTimer(int secs) {
    timer.value?.stop();
    final c = Countdown(secs);
    timer.value = c;
    c.start(onDone: _signal);
  }

  void _signal() {
    final s = _stop;
    if (s != null && !s.isCompleted) s.complete();
  }

  /// Plays [say], then records until time is up or the learner taps Done.
  /// If [autoWords] > 0 it also stops by itself once that many words were
  /// heard and the learner went quiet.
  Future<(String, int, double)> _round({required String say, required int secs, int autoWords = 0}) async {
    liveText.value = '';
    liveWords.value = 0;
    step.value = SpeakStep.playing;
    await speech.speak(say);
    if (_aborted) return ('', 0, -1.0);

    _stop = Completer<void>();
    final watch = Stopwatch()..start();
    var lastChange = DateTime.now();
    await speech.startListening((t) {
      if (t != liveText.value) lastChange = DateTime.now();
      liveText.value = t;
      liveWords.value = _wc(t);
    });
    step.value = SpeakStep.recording;
    _openTimer(secs);
    if (autoWords > 0) {
      _silence = Timer.periodic(const Duration(milliseconds: 500), (_) {
        if (liveWords.value >= autoWords &&
            DateTime.now().difference(lastChange).inMilliseconds > 1800) {
          _signal();
        }
      });
    }
    await _stop!.future;
    _silence?.cancel();
    timer.value?.stop();

    step.value = SpeakStep.saving;
    final text = await speech.stopListening();
    watch.stop();
    return (text, watch.elapsed.inSeconds, speech.confidence);
  }

  /// "Done speaking" button.
  void finishAnswer() {
    if (step.value == SpeakStep.recording) _signal();
  }

  // ───────────── Listen and Repeat ─────────────
  Future<void> beginRepeat() async {
    if (step.value != SpeakStep.ready) return;
    final n = current.repeats.length;
    for (var i = 0; i < n; i++) {
      if (_aborted) return;
      index.value = i;
      final target = current.repeats[i];
      final r = await _round(say: target, secs: repeatSeconds, autoWords: _wc(target));
      if (_aborted) return;
      repeatHeard[i] = r.$1;
    }
    index.value = 0;
    step.value = SpeakStep.ready;
    timer.value = null;
    phase.value = SpeakingPhase.interview;
  }

  // ───────────── Interview ─────────────
  Future<void> beginInterview() async {
    if (step.value != SpeakStep.ready) return;
    final n = current.questions.length;
    for (var i = 0; i < n; i++) {
      if (_aborted) return;
      index.value = i;
      final r = await _round(say: current.questions[i].question, secs: answerSeconds);
      if (_aborted) return;
      interviewHeard[i] = r.$1;
      interviewSecs[i] = r.$2;
      interviewConf[i] = r.$3;
    }
    _finishAll();
  }

  void _finishAll() {
    _total.stop();
    totalSeconds = _total.elapsed.inSeconds;
    timer.value?.stop();

    final n = current.repeats.length;
    var sum = 0.0;
    final rc = <RepeatCheck?>[];
    for (var i = 0; i < n; i++) {
      final c = SpeakingChecker.checkRepeat(current.repeats[i], repeatHeard[i]);
      rc.add(c);
      sum += c.accuracy;
    }
    repeatChecks.assignAll(rc);
    repeatAcc.value = sum / n;

    final a = SpeakingAttempt(
      no: currentTestNo,
      testId: current.id,
      band: SpeakingScoring.estimate(repeat: repeatAcc.value, interview: -1.0),
      repeatAcc: repeatAcc.value,
      interviewScore: -1.0,
      repeatHeard: List.of(repeatHeard),
      interviewText: List.of(interviewHeard),
      interviewSecs: List.of(interviewSecs),
      seconds: totalSeconds,
      ts: DateTime.now().millisecondsSinceEpoch,
    );
    attempt = a;
    band.value = a.band;
    store.complete(a, current.id);
    phase.value = SpeakingPhase.result;
    _runChecks();
  }

  // ───────────── Result: automatic interview checks ─────────────
  Future<void> _runChecks() async {
    final a = attempt;
    if (a == null) return;
    final qs = current.questions;
    final res = await Future.wait([
      for (var i = 0; i < qs.length; i++)
        SpeakingChecker.checkInterview(interviewHeard[i], qs[i].question, interviewSecs[i], interviewConf[i]),
    ]);
    if (attempt?.ts != a.ts) return; // user already moved on
    interviewChecks.assignAll(res);
    final avg = res.fold<double>(0, (s, r) => s + r.score) / res.length;
    interviewScore.value = double.parse(avg.toStringAsFixed(1));
    band.value = SpeakingScoring.estimate(repeat: repeatAcc.value, interview: interviewScore.value);
    final updated = a.copyWith(band: band.value, interviewScore: interviewScore.value);
    attempt = updated;
    store.update(updated);
  }

  bool get fullyChecked => interviewScore.value >= 0;

  void nextTest() => phase.value = store.canStart ? SpeakingPhase.overview : SpeakingPhase.allDone;

  // ───────────── Exit / reset ─────────────
  bool get inTest => phase.value == SpeakingPhase.repeat || phase.value == SpeakingPhase.interview;

  void _abort() {
    _aborted = true;
    _silence?.cancel();
    timer.value?.stop();
    speech.cancel();
    _signal();
  }

  Future<void> confirmExit() async {
    if (!inTest) {
      exitToHome();
      return;
    }
    final leave = await _confirm(
      title: 'Leave the test?',
      message: 'Your progress in this test will be lost and it will not be counted.',
      confirm: 'Leave',
      cancel: 'Stay',
    );
    if (leave) exitToHome();
  }

  void exitToHome() {
    _abort();
    Get.back();
  }

  Future<void> confirmReset() async {
    final ok = await _confirm(
      title: 'Practice again?',
      message: 'This clears your current speaking tests so all of them become available again. Your saved history is kept.',
      confirm: 'Reset',
      cancel: 'Cancel',
    );
    if (!ok) return;
    await store.reset();
    phase.value = SpeakingPhase.overview;
  }

  // ───────────── Dialog ─────────────
  Future<bool> _confirm({
    required String title,
    required String message,
    required String confirm,
    required String cancel,
  }) async {
    final theme = Theme.of(Get.context!);
    final colors = theme.colorScheme;
    final destructive = confirm == 'Leave' || confirm == 'Reset';
    final accent = destructive ? colors.error : colors.primary;
    final icon = confirm == 'Leave'
        ? Icons.exit_to_app_rounded
        : confirm == 'Reset'
        ? Icons.restart_alt_rounded
        : Icons.task_alt_rounded;

    final result = await Get.dialog<bool>(
      Dialog(
        backgroundColor: colors.surface,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: BorderSide(color: colors.outlineVariant.withValues(alpha: 0.45)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, size: 28, color: accent),
            ),
            const SizedBox(height: 22),
            Text(title,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800, letterSpacing: -0.5, color: colors.onSurface, height: 1.25)),
            const SizedBox(height: 12),
            Text(message,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: colors.onSurfaceVariant, height: 1.65, fontSize: 14)),
            const SizedBox(height: 28),
            Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Get.back(result: false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.onSurface,
                    minimumSize: const Size(0, 50),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    side: BorderSide(color: colors.outlineVariant),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: Text(cancel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () => Get.back(result: true),
                  style: FilledButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: destructive ? Colors.white : colors.onPrimary,
                    minimumSize: const Size(0, 50),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: Text(confirm,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                ),
              ),
            ]),
          ]),
        ),
      ),
      barrierDismissible: false,
    );
    return result ?? false;
  }

  @override
  void onClose() {
    _abort();
    super.onClose();
  }
}