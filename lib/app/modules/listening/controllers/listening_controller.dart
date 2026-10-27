
import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:toefl_pro/app/core/utils/countdown.dart';

import '../../../core/widgets/app_dialog.dart';
import '../listening_data.dart';
import '../listening_models.dart';
import '../listening_store.dart';

enum ListeningPhase { loading, overview, question, result, allDone }

/// idle    = nothing started yet
/// playing = the audio is being played (options hidden)
/// done    = the audio finished (options visible)
/// error   = the audio could not be played (options visible, transcript shown)
enum AudioStage { idle, playing, done, error }

class ListeningController extends GetxController {
  /// Time for the whole test (10 short + 2 long audios = 18 questions).
  /// If you add more conversations/announcements, increase this.
  static const sectionSeconds = 30 * 60;

  /// If the player never reports "finished" (e.g. a missing file), unlock the
  /// options after this many seconds so the learner is not stuck.
  static const _watchdogShort = 20;
  static const _watchdogLong = 150; // conversations / announcements

  final store = ListeningStore.I;
  final phase = ListeningPhase.loading.obs;
  final hideTime = false.obs;
  final timer = Rxn<Countdown>();
  final audioStage = AudioStage.idle.obs;

  final index = 0.obs;
  final answers = <int>[].obs; // chosen option per question, -1 = none
  final reviewPlaying = (-1).obs; // result page: which item is playing

  late ListeningTest current;
  List<List<int>> optionOrder = []; // per question: shuffled option indices
  final Set<String> _playedAudio = {}; // audio files already played once
  int got = 0;
  int totalSeconds = 0;
  int currentTestNo = 1;
  double band = 1.0;
  ListeningAttempt? attempt;

  final _player = AudioPlayer();
  // Fallback voice: used automatically when an audio file is missing.
  final _tts = FlutterTts();
  StreamSubscription<void>? _doneSub;
  final _watch = Stopwatch();
  final _rnd = Random();

  int get testNo => store.attempts.length + 1;
  int get maxTests => store.maxTests;
  int get questionCount => ListeningBank.questionsPerTest;
  int get minutes => sectionSeconds ~/ 60;

  bool get inTest => phase.value == ListeningPhase.question;

  /// True when the learner may press Next: audio finished and an option is chosen.
  bool get canAdvance =>
      answers.isNotEmpty &&
          answers[index.value] >= 0 &&
          audioStage.value != AudioStage.playing;

  @override
  void onInit() {
    super.onInit();
    _doneSub = _player.onPlayerComplete.listen((_) {
      if (phase.value == ListeningPhase.question && audioStage.value == AudioStage.playing) {
        audioStage.value = AudioStage.done;
      } else if (phase.value == ListeningPhase.result) {
        reviewPlaying.value = -1;
      }
    });
    _setupTts();
    _init();
  }

  void _setupTts() {
    try {
      _tts.setLanguage('en-US');
      _tts.setSpeechRate(0.45);
      _tts.setCompletionHandler(() {
        if (phase.value == ListeningPhase.question && audioStage.value == AudioStage.playing) {
          audioStage.value = AudioStage.done;
        } else if (phase.value == ListeningPhase.result) {
          reviewPlaying.value = -1;
        }
      });
    } catch (_) {}
  }

  /// Text spoken by the fallback voice (speaker names like "Olivia:" are removed).
  String _spokenText(ListeningQuestion q) {
    if (!q.isGroup) return q.sentence;
    final script = q.script ?? q.sentence;
    return script.replaceAll(RegExp(r'^[A-Za-z .]+:\s*', multiLine: true), '');
  }

  Future<bool> _speakFallback(ListeningQuestion q) async {
    try {
      await _tts.stop();
      await _tts.speak(_spokenText(q));
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _init() async {
    await store.ensureLoaded();
    phase.value = store.canStart ? ListeningPhase.overview : ListeningPhase.allDone;
  }

  // ───────────── Test lifecycle ─────────────
  void startTest() {
    final pick = ListeningBank.pick(store.used, _rnd);
    if (pick == null) {
      phase.value = ListeningPhase.allDone;
      return;
    }
    current = pick;
    currentTestNo = testNo;
    totalSeconds = 0;
    got = 0;
    band = 1.0;
    attempt = null;
    reviewPlaying.value = -1;
    final n = current.questions.length;
    answers.assignAll(List<int>.filled(n, -1));
    optionOrder = [
      for (final q in current.questions) (List<int>.generate(q.options.length, (i) => i)..shuffle(_rnd)),
    ];
    _playedAudio.clear();
    index.value = 0;
    audioStage.value = AudioStage.idle;

    timer.value?.stop();
    final c = Countdown(sectionSeconds);
    timer.value = c;
    c.start(onDone: _onTimeUp);
    _watch
      ..reset()
      ..start();

    phase.value = ListeningPhase.question;
    _playCurrent();
  }

  void _onTimeUp() {
    if (phase.value != ListeningPhase.question) return;
    _finish(auto: true);
  }

  // ───────────── Audio (each audio file plays ONCE) ─────────────
  Future<void> _playCurrent() async {
    final i = index.value;
    final q = current.questions[i];

    // Already heard (e.g. 2nd–4th question of the same conversation).
    if (_playedAudio.contains(q.audio)) {
      audioStage.value = AudioStage.done;
      return;
    }
    _playedAudio.add(q.audio);
    audioStage.value = AudioStage.playing;
    try {
      await _player.stop();
      await _player.play(AssetSource(q.audio));
    } catch (_) {
      // Audio file missing -> read the text aloud instead.
      final spoken = await _speakFallback(q);
      if (!spoken) {
        if (phase.value == ListeningPhase.question && index.value == i) {
          audioStage.value = AudioStage.error;
        }
        return;
      }
    }
    // Safety net: never leave the learner stuck on a hidden-options screen.
    final wait = q.isGroup ? _watchdogLong : _watchdogShort;
    Future.delayed(Duration(seconds: wait), () {
      if (phase.value == ListeningPhase.question &&
          index.value == i &&
          audioStage.value == AudioStage.playing) {
        audioStage.value = AudioStage.done;
      }
    });
  }

  /// Result page: listen again (allowed in review only).
  Future<void> playReview(int i) async {
    try {
      if (reviewPlaying.value == i) {
        await _player.stop();
        await _tts.stop();
        reviewPlaying.value = -1;
        return;
      }
      await _player.stop();
      await _tts.stop();
      reviewPlaying.value = i;
      try {
        await _player.play(AssetSource(current.questions[i].audio));
      } catch (_) {
        final spoken = await _speakFallback(current.questions[i]);
        if (!spoken) reviewPlaying.value = -1;
      }
    } catch (_) {
      reviewPlaying.value = -1;
    }
  }

  // ───────────── Answering ─────────────
  /// [option] is the ORIGINAL index of the option (not its position on screen).
  void choose(int option) {
    if (audioStage.value == AudioStage.playing) return;
    answers[index.value] = option;
  }

  Future<void> next() async {
    if (!canAdvance) return;
    final i = index.value;
    if (i < current.questions.length - 1) {
      index.value = i + 1;
      await _playCurrent();
    } else {
      await requestSubmit();
    }
  }

  Future<void> requestSubmit() async {
    final ok = await AppDialog.confirm(
      title: 'Submit Listening?',
      message: 'You will not be able to return to these questions.',
      confirmText: 'Submit',
      cancelText: 'Cancel',
      type: AppDialogType.warning,
      barrierDismissible: false,
    );

    if (ok) {
      _finish();
    }
  }

/*
  Future<void> requestSubmit() async {
    final ok = await _confirm(
      title: 'Submit Listening?',
      message: 'You will not be able to return to these questions.',
      confirm: 'Submit',
      cancel: 'Cancel',
    );
    if (ok) _finish();
  }*/

  void _finish({bool auto = false}) {
    if (phase.value != ListeningPhase.question) return;
    timer.value?.stop();
    _watch.stop();
    totalSeconds = _watch.elapsed.inSeconds;
    _player.stop();
    _tts.stop();

    final n = current.questions.length;
    got = 0;
    for (var i = 0; i < n; i++) {
      if (answers[i] == current.questions[i].answer) got++;
    }
    band = ListeningScoring.estimate(got: got, total: n);

    final a = ListeningAttempt(
      no: currentTestNo,
      testId: current.id,
      band: band,
      got: got,
      total: n,
      answers: List<int>.from(answers),
      seconds: totalSeconds,
      ts: DateTime.now().millisecondsSinceEpoch,
    );
    attempt = a;
    store.complete(a, current.id);
    phase.value = ListeningPhase.result;
    if (auto) {
      Get.snackbar('Time is up', 'Your answers were submitted automatically.',
          snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(16));
    }
  }

  bool isCorrect(int i) => answers[i] == current.questions[i].answer;

  void nextTest() => phase.value = store.canStart ? ListeningPhase.overview : ListeningPhase.allDone;

/*  // ───────────── Exit / reset ─────────────
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
  }*/



  Future<void> confirmExit() async {
    if (!inTest) {
      exitToHome();
      return;
    }

    final leave = await AppDialog.confirm(
      title: 'Leave the test?',
      message:
      'Your progress in this test will be lost and it will not be counted.',
      confirmText: 'Leave',
      cancelText: 'Stay',
      type: AppDialogType.danger,
      barrierDismissible: false,
    );

    if (leave) {
      exitToHome();
    }
  }

  void exitToHome() {
    timer.value?.stop();
    _player.stop();
    _tts.stop();
    Get.back();
  }


  Future<void> confirmReset() async {
    final ok = await AppDialog.confirm(
      title: 'Practice again?',
      message:
      'This clears your current listening tests so all of them become available again. Your saved history is kept.',
      confirmText: 'Reset',
      cancelText: 'Cancel',
      type: AppDialogType.danger,
      barrierDismissible: false,
    );

    if (!ok) return;

    await store.reset();
    phase.value = ListeningPhase.overview;
  }


/*  Future<void> confirmReset() async {
    final ok = await _confirm(
      title: 'Practice again?',
      message: 'This clears your current listening tests so all of them become available again. Your saved history is kept.',
      confirm: 'Reset',
      cancel: 'Cancel',
    );
    if (!ok) return;
    await store.reset();
    phase.value = ListeningPhase.overview;
  }*/

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

    final result = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
        content: Text(message, style: theme.textTheme.bodyMedium?.copyWith(height: 1.5)),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: Text(cancel)),
          FilledButton(
            onPressed: () => Get.back(result: true),
            style: FilledButton.styleFrom(
              backgroundColor: accent,
              foregroundColor: destructive ? Colors.white : colors.onPrimary,
            ),
            child: Text(confirm),
          ),
        ],
      ),
      barrierDismissible: false,
    );
    return result ?? false;
  }

  @override
  void onClose() {
    timer.value?.stop();
    _doneSub?.cancel();
    _player.dispose();
    _tts.stop();
    super.onClose();
  }
}