import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toefl_pro/app/core/utils/countdown.dart';

import '../writing_checker.dart';
import '../writing_data.dart';
import '../writing_models.dart';
import '../writing_store.dart';

enum WritingPhase { loading, overview, build, email, discussion, result, allDone }

int countWords(String s) {
  final t = s.trim();
  return t.isEmpty ? 0 : t.split(RegExp(r'\s+')).length;
}

class WritingController extends GetxController {
  // Stage lengths (about 23 minutes in total, like the real section).
  static const buildSeconds = 6 * 60;
  static const emailSeconds = 7 * 60;
  static const discussionSeconds = 10 * 60;

  final store = WritingStore.I;
  final phase = WritingPhase.loading.obs;
  final hideTime = false.obs;
  final timer = Rxn<Countdown>();

  // Build a Sentence state
  final buildIndex = 0.obs;
  final placed = <List<int>>[].obs; // per item: tile indices in the order tapped

  // Free-writing state
  final emailCtl = TextEditingController();
  final discCtl = TextEditingController();
  final emailWords = 0.obs;
  final discWords = 0.obs;

  // Result state (automatic checks)
  final selfEmail = (-1.0).obs;
  final selfDisc = (-1.0).obs;
  final band = 1.0.obs;
  final checking = false.obs;
  final emailCheck = Rxn<WritingCheck>();
  final discCheck = Rxn<WritingCheck>();

  late WritingTest current;
  List<List<int>> tileOrder = [];
  List<String> builtAnswers = [];
  List<bool> buildCorrect = [];
  int buildGot = 0;
  int totalSeconds = 0;
  int currentTestNo = 1;
  WritingAttempt? attempt;

  final _watch = Stopwatch();
  final _rnd = Random();

  int get testNo => store.attempts.length + 1;
  int get maxTests => store.maxTests;

  @override
  void onInit() {
    super.onInit();
    emailCtl.addListener(() => emailWords.value = countWords(emailCtl.text));
    discCtl.addListener(() => discWords.value = countWords(discCtl.text));
    _init();
  }

  Future<void> _init() async {
    await store.ensureLoaded();
    phase.value = store.canStart ? WritingPhase.overview : WritingPhase.allDone;
  }

  // ───────────── Test lifecycle ─────────────
  void startTest() {
    final pick = WritingBank.pick(store.used, _rnd);
    if (pick == null) {
      phase.value = WritingPhase.allDone;
      return;
    }
    current = pick;
    currentTestNo = testNo;
    totalSeconds = 0;
    buildGot = 0;
    builtAnswers = [];
    buildCorrect = [];
    attempt = null;
    emailCtl.clear();
    discCtl.clear();
    selfEmail.value = -1.0;
    selfDisc.value = -1.0;
    emailCheck.value = null;
    discCheck.value = null;
    checking.value = false;
    band.value = 1.0;
    tileOrder = [for (final b in current.builds) _shuffledOrder(b.chunks.length)];
    placed.assignAll([for (final _ in current.builds) <int>[]]);
    buildIndex.value = 0;
    _openStage(WritingPhase.build, buildSeconds);
  }

  List<int> _shuffledOrder(int n) {
    final idx = List<int>.generate(n, (i) => i);
    if (n < 2) return idx;
    var tries = 0;
    bool sorted() {
      for (var i = 1; i < idx.length; i++) {
        if (idx[i] < idx[i - 1]) return false;
      }
      return true;
    }

    do {
      idx.shuffle(_rnd);
      tries++;
    } while (sorted() && tries < 10);
    return idx;
  }

  void _openStage(WritingPhase p, int secs) {
    timer.value?.stop();
    final c = Countdown(secs);
    timer.value = c;
    c.start(onDone: () => _onTimeUp(p));
    _watch
      ..reset()
      ..start();
    phase.value = p;
  }

  void _lap() {
    _watch.stop();
    totalSeconds += _watch.elapsed.inSeconds;
  }

  void _onTimeUp(WritingPhase p) {
    if (phase.value != p) return;
    switch (p) {
      case WritingPhase.build:
        _finishBuild(auto: true);
      case WritingPhase.email:
        _finishEmail(auto: true);
      case WritingPhase.discussion:
        _finishDiscussion(auto: true);
      default:
        break;
    }
  }

  void _timeUpSnack(String msg) => Get.snackbar('Time is up', msg,
      snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(16));

  // ───────────── Build a Sentence ─────────────
  BuildItem get item => current.builds[buildIndex.value];

  List<String> sentenceFor(int i) =>
      [for (final t in placed[i]) current.builds[i].chunks[t]];

  bool isAnswered(int i) => placed[i].length == current.builds[i].chunks.length;
  int get answeredCount {
    var n = 0;
    for (var i = 0; i < placed.length; i++) {
      if (isAnswered(i)) n++;
    }
    return n;
  }

  void place(int tile) {
    final i = buildIndex.value;
    if (placed[i].contains(tile)) return;
    placed[i] = [...placed[i], tile];
  }

  void removeAt(int pos) {
    final i = buildIndex.value;
    final l = [...placed[i]]..removeAt(pos);
    placed[i] = l;
  }

  void clearItem() => placed[buildIndex.value] = <int>[];

  void prev() {
    if (buildIndex.value > 0) buildIndex.value--;
  }

  Future<void> next() async {
    if (buildIndex.value < current.builds.length - 1) {
      buildIndex.value++;
    } else {
      await requestSubmitBuild();
    }
  }

  Future<void> requestSubmitBuild() async {
    final left = current.builds.length - answeredCount;
    final ok = await _confirm(
      title: 'Finish Build a Sentence?',
      message: '${left > 0 ? 'You have $left unfinished ${left == 1 ? 'sentence' : 'sentences'}. ' : ''}'
          'You will not be able to return to these sentences.',
      confirm: 'Continue',
      cancel: 'Review',
    );
    if (ok) _finishBuild();
  }

  void _finishBuild({bool auto = false}) {
    if (phase.value != WritingPhase.build) return;
    _lap();
    builtAnswers = [];
    buildCorrect = [];
    buildGot = 0;
    for (var i = 0; i < current.builds.length; i++) {
      final s = sentenceFor(i);
      final ok = isAnswered(i) && current.builds[i].matches(s);
      builtAnswers.add(s.isEmpty ? '' : '${s.join(' ')}${current.builds[i].end}');
      buildCorrect.add(ok);
      if (ok) buildGot++;
    }
    _openStage(WritingPhase.email, emailSeconds);
    if (auto) _timeUpSnack('Your sentences were submitted. Moving on to the email.');
  }

  // ───────────── Email ─────────────
  Future<void> requestSubmitEmail() async {
    final ok = await _confirm(
      title: 'Continue to the discussion?',
      message: '${emailWords.value} words written. You will not be able to return to your email.',
      confirm: 'Continue',
      cancel: 'Keep writing',
    );
    if (ok) _finishEmail();
  }

  void _finishEmail({bool auto = false}) {
    if (phase.value != WritingPhase.email) return;
    _lap();
    _openStage(WritingPhase.discussion, discussionSeconds);
    if (auto) _timeUpSnack('Your email was submitted. Moving on to the discussion.');
  }

  // ───────────── Academic discussion ─────────────
  Future<void> requestSubmitDiscussion() async {
    final ok = await _confirm(
      title: 'Submit Writing section?',
      message: '${discWords.value} words written. You will not be able to change your post.',
      confirm: 'Submit',
      cancel: 'Keep writing',
    );
    if (ok) _finishDiscussion();
  }

  void _finishDiscussion({bool auto = false}) {
    if (phase.value != WritingPhase.discussion) return;
    timer.value?.stop();
    _lap();
    final a = WritingAttempt(
      no: currentTestNo,
      testId: current.id,
      band: WritingScoring.estimate(
          buildGot: buildGot, buildTotal: current.builds.length, email: -1.0, disc: -1.0),
      buildGot: buildGot,
      buildTotal: current.builds.length,
      emailWords: countWords(emailCtl.text),
      discWords: countWords(discCtl.text),
      selfEmail: -1.0,
      selfDisc: -1.0,
      emailText: emailCtl.text.trim(),
      discText: discCtl.text.trim(),
      seconds: totalSeconds,
      ts: DateTime.now().millisecondsSinceEpoch,
    );
    attempt = a;
    band.value = a.band;
    store.complete(a, current.id);
    phase.value = WritingPhase.result;
    _runChecks();
    if (auto) _timeUpSnack('Your post was submitted automatically.');
  }

  // ───────────── Result: automatic checks ─────────────
  Future<void> _runChecks() async {
    final a = attempt;
    if (a == null) return;
    final e = current.email, d = current.discussion;
    checking.value = true;
    final res = await Future.wait([
      WritingChecker.checkEmail(emailCtl.text.trim(), e.points),
      WritingChecker.checkDiscussion(discCtl.text.trim(), d.question, [d.s1Name, d.s2Name]),
    ]);
    if (attempt?.ts != a.ts) return; // user already moved on
    emailCheck.value = res[0];
    discCheck.value = res[1];
    selfEmail.value = res[0].score;
    selfDisc.value = res[1].score;
    band.value = WritingScoring.estimate(
      buildGot: a.buildGot,
      buildTotal: a.buildTotal,
      email: selfEmail.value,
      disc: selfDisc.value,
    );
    final updated = a.copyWith(band: band.value, selfEmail: selfEmail.value, selfDisc: selfDisc.value);
    attempt = updated;
    store.update(updated);
    checking.value = false;
  }

  bool get fullyRated => emailCheck.value != null && discCheck.value != null;

  void nextTest() => phase.value = store.canStart ? WritingPhase.overview : WritingPhase.allDone;

  // ───────────── Exit / reset ─────────────
  bool get inTest =>
      phase.value == WritingPhase.build ||
          phase.value == WritingPhase.email ||
          phase.value == WritingPhase.discussion;

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
    timer.value?.stop();
    Get.back();
  }

  Future<void> confirmReset() async {
    final ok = await _confirm(
      title: 'Practice again?',
      message: 'This clears your current writing tests so all of them become available again. Your saved history is kept.',
      confirm: 'Reset',
      cancel: 'Cancel',
    );
    if (!ok) return;
    await store.reset();
    phase.value = WritingPhase.overview;
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
    final icon = destructive
        ? (confirm == 'Leave' ? Icons.exit_to_app_rounded : Icons.restart_alt_rounded)
        : (confirm == 'Submit' ? Icons.send_rounded : Icons.task_alt_rounded);

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
    timer.value?.stop();
    emailCtl.dispose();
    discCtl.dispose();
    super.onClose();
  }
}