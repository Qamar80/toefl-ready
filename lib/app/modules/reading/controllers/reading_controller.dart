import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toefl_pro/app/core/utils/countdown.dart';


import '../reading_data.dart';
import '../reading_models.dart';
import '../reading_store.dart';

enum ReadingPhase { loading, overview, test, interlude, result, allDone }

/// One screen of a module. CTW = one screen (q == -1); MCQ tasks = one screen per question.
class ScreenRef {
  final ReadingTask task;
  final int q;
  const ScreenRef(this.task, this.q);
  bool get isCtw => q < 0;
  bool get firstOfTask => q <= 0;
}

class ModuleScore {
  final int score;
  final int total;
  final Map<TaskType, int> got;
  final Map<TaskType, int> max;
  const ModuleScore(this.score, this.total, this.got, this.max);
  double get percent => total == 0 ? 0 : score / total;
}

class ReadingController extends GetxController {
  static const moduleMinutes = 15; // ~30 min for the whole section

  final store = ReadingStore.I;
  final phase = ReadingPhase.loading.obs;
  final moduleNo = 1.obs;
  final index = 0.obs;
  final hideTime = false.obs;
  final ctwTick = 0.obs; // bumps whenever a blank changes
  final mcq = <String, int>{}.obs; // '<taskId>:<qIndex>' -> chosen option
  final openDirections = <String>{}.obs;
  final timer = Rxn<Countdown>();

  List<ReadingTask> tasks = [];
  List<ScreenRef> screens = [];
  List<ReadingTask> m1Tasks = [];
  List<ReadingTask> m2Tasks = [];
  ModuleScore? m1;
  ModuleScore? m2;
  bool hardPath = false;
  double band = 0;
  int totalSeconds = 0;
  int currentTestNo = 1;

  final ctwFinal = <String, List<String>>{};
  final _ctl = <String, List<TextEditingController>>{};
  final _watch = Stopwatch();
  final _rnd = Random();

  int get testNo => store.attempts.length + 1;
  int get maxTests => store.maxTests;
  ScreenRef get screen => screens[index.value];
  TextEditingController ctl(String taskId, int i) => _ctl[taskId]![i];

  @override
  void onInit() {
    super.onInit();
    _init();
  }

  Future<void> _init() async {
    await store.ensureLoaded();
    phase.value = store.canStart ? ReadingPhase.overview : ReadingPhase.allDone;
  }

  // ───────────── Test lifecycle ─────────────
  void startTest() {
    final pick = ReadingBank.module(2, store.used, _rnd);
    if (pick == null) {
      phase.value = ReadingPhase.allDone;
      return;
    }
    currentTestNo = testNo;
    mcq.clear();
    ctwFinal.clear();
    totalSeconds = 0;
    m1 = null;
    m2 = null;
    m1Tasks = [for (final t in pick) t.shuffled(_rnd)];
    _openModule(m1Tasks, 1);
  }

  void startModule2() => _openModule(m2Tasks, 2);

  void _openModule(List<ReadingTask> ts, int no) {
    _disposeCtl();
    tasks = ts;
    moduleNo.value = no;
    index.value = 0;
    ctwTick.value = 0;
    openDirections.clear();
    screens = [
      for (final t in ts)
        if (t.type == TaskType.completeWords)
          ScreenRef(t, -1)
        else
          for (var i = 0; i < t.questions.length; i++) ScreenRef(t, i),
    ];
    for (final t in ts) {
      openDirections.add(t.id);
      if (t.type == TaskType.completeWords) {
        _ctl[t.id] = List.generate(t.blankCount, (_) => TextEditingController());
      }
    }
    timer.value?.stop();
    final c = Countdown(moduleMinutes * 60);
    timer.value = c;
    c.start(onDone: () => submitModule(auto: true));
    _watch
      ..reset()
      ..start();
    phase.value = ReadingPhase.test;
  }

  // ───────────── Navigation & answering ─────────────
  void goTo(int i) => index.value = i;
  void prev() {
    if (index.value > 0) index.value--;
  }

  Future<void> next() async {
    if (index.value < screens.length - 1) {
      index.value++;
    } else {
      await requestSubmit();
    }
  }

  void select(int option) => mcq['${screen.task.id}:${screen.q}'] = option;
  int? selectedFor(ReadingTask t, int q) => mcq['${t.id}:$q'];
  void blankChanged() => ctwTick.value++;
  void toggleDirections(String id) => openDirections.contains(id) ? openDirections.remove(id) : openDirections.add(id);

  bool isAnswered(ScreenRef s) {
    ctwTick.value; // register dependency for Obx
    if (s.isCtw) {
      final l = _ctl[s.task.id];
      return l != null && l.every((c) => c.text.isNotEmpty);
    }
    return mcq.containsKey('${s.task.id}:${s.q}');
  }

  int get answeredCount => screens.where(isAnswered).length;

  // ───────────── Submitting ─────────────
  Future<void> requestSubmit() async {
    final left = screens.length - answeredCount;
    final first = moduleNo.value == 1;
    final ok = await _confirm(
      title: first ? 'Finish Module 1?' : 'Submit Reading section?',
      message: '${left > 0 ? 'You have $left unanswered ${left == 1 ? 'item' : 'items'}. ' : ''}'
          '${first ? 'You will not be able to return to Module 1.' : 'You will not be able to change your answers.'}',
      confirm: 'Submit',
      cancel: 'Review',
    );
    if (ok) submitModule();
  }

  void submitModule({bool auto = false}) {
    if (phase.value != ReadingPhase.test) return;
    timer.value?.stop();
    _watch.stop();
    totalSeconds += _watch.elapsed.inSeconds;
    for (final t in tasks) {
      if (t.type == TaskType.completeWords) {
        ctwFinal[t.id] = _ctl[t.id]!.map((c) => c.text.trim()).toList();
      }
    }
    final sc = _score(tasks);

    if (moduleNo.value == 1) {
      m1 = sc;
      hardPath = sc.percent >= .6; // adaptive routing (simplified)
      final pick = ReadingBank.module(hardPath ? 3 : 1, store.used, _rnd, exclude: m1Tasks.map((t) => t.id).toSet());
      m2Tasks = [for (final t in pick ?? <ReadingTask>[]) t.shuffled(_rnd)];
      if (m2Tasks.isEmpty) {
        m2 = const ModuleScore(0, 0, {}, {});
        _finishAttempt();
      } else {
        phase.value = ReadingPhase.interlude;
      }
    } else {
      m2 = sc;
      _finishAttempt();
    }
    if (auto) {
      Get.snackbar('Time is up', 'Your answers were submitted automatically.',
          snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(16));
    }
  }

  ModuleScore _score(List<ReadingTask> ts) {
    var s = 0, t = 0;
    final got = {for (final k in TaskType.values) k: 0};
    final max = {for (final k in TaskType.values) k: 0};
    for (final task in ts) {
      if (task.type == TaskType.completeWords) {
        final blanks = task.parts.where((p) => p.isBlank).toList();
        final ans = ctwFinal[task.id] ?? const <String>[];
        for (var i = 0; i < blanks.length; i++) {
          max[task.type] = max[task.type]! + 1;
          t++;
          if (i < ans.length && ans[i].toLowerCase() == blanks[i].missing!.toLowerCase()) {
            got[task.type] = got[task.type]! + 1;
            s++;
          }
        }
      } else {
        for (var i = 0; i < task.questions.length; i++) {
          max[task.type] = max[task.type]! + 1;
          t++;
          if (mcq['${task.id}:$i'] == task.questions[i].correct) {
            got[task.type] = got[task.type]! + 1;
            s++;
          }
        }
      }
    }
    return ModuleScore(s, t, got, max);
  }

  /// Practice estimate only (not an official ETS score).
  /// Easy path covers bands 1–4, hard path 3–6, like a real adaptive ceiling.
  double _estimateBand(double p1, double p2, bool hard) {
    final raw = p1 * .4 + p2 * .6;
    final b = (hard ? 3 : 1) + raw * 3;
    return ((b.clamp(1, 6)) * 2).round() / 2;
  }

  void _finishAttempt() {
    final a = m1!, b = m2!;
    final p2 = b.total == 0 ? a.percent : b.percent;
    band = _estimateBand(a.percent, p2, hardPath);
    store.complete(
      AttemptResult(
        no: currentTestNo,
        band: band,
        m1Score: a.score, m1Total: a.total,
        m2Score: b.score, m2Total: b.total,
        hard: hardPath,
        seconds: totalSeconds,
        ts: DateTime.now().millisecondsSinceEpoch,
        byType: {
          for (final t in TaskType.values)
            t.name: [
              (a.got[t] ?? 0) + (b.got[t] ?? 0),
              (a.max[t] ?? 0) + (b.max[t] ?? 0),
            ],
        },
      ),
      [...m1Tasks, ...m2Tasks].map((t) => t.id),
    );
    phase.value = ReadingPhase.result;
  }

/*  void _finishAttempt() {
    final a = m1!, b = m2!;
    final p2 = b.total == 0 ? a.percent : b.percent;
    band = _estimateBand(a.percent, p2, hardPath);
    store.complete(
      AttemptResult(
        no: currentTestNo,
        band: band,
        m1Score: a.score,
        m1Total: a.total,
        m2Score: b.score,
        m2Total: b.total,
        hard: hardPath,
        seconds: totalSeconds,
      ),
      [...m1Tasks, ...m2Tasks].map((t) => t.id),
    );
    phase.value = ReadingPhase.result;
  }*/

  void nextTest() => phase.value = store.canStart ? ReadingPhase.overview : ReadingPhase.allDone;

  // ───────────── Exit / reset ─────────────
  Future<void> confirmExit() async {
    if (phase.value != ReadingPhase.test) {
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
      message: 'This clears your reading history so all tests become available again.',
      confirm: 'Reset',
      cancel: 'Cancel',
    );
    if (!ok) return;
    await store.reset();
    phase.value = ReadingPhase.overview;
  }



  Future<bool> _confirm({
    required String title,
    required String message,
    required String confirm,
    required String cancel,
  }) async {
    final theme = Theme.of(Get.context!);
    final colors = theme.colorScheme;

    final isDestructive = confirm == 'Leave' || confirm == 'Reset';

    final IconData dialogIcon = title.contains('Leave')
        ? Icons.exit_to_app_rounded
        : title.contains('Reset') || title.contains('again')
        ? Icons.restart_alt_rounded
        : title.contains('Finish')
        ? Icons.task_alt_rounded
        : Icons.send_rounded;

    final Color accentColor =
    isDestructive ? colors.error : colors.primary;

    final result = await Get.dialog<bool>(
      Dialog(
        backgroundColor: colors.surface,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: BorderSide(
            color: colors.outlineVariant.withValues(alpha: 0.45),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon container
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  dialogIcon,
                  size: 28,
                  color: accentColor,
                ),
              ),

              const SizedBox(height: 22),

              // Dialog title
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: colors.onSurface,
                  height: 1.25,
                ),
              ),

              const SizedBox(height: 12),

              // Description
              Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                  height: 1.65,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 28),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(result: false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colors.onSurface,
                        minimumSize: const Size(0, 50),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        side: BorderSide(
                          color: colors.outlineVariant,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Text(
                        cancel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: FilledButton(
                      onPressed: () => Get.back(result: true),
                      style: FilledButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: isDestructive
                            ? Colors.white
                            : colors.onPrimary,
                        minimumSize: const Size(0, 50),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Text(
                        confirm,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );

    return result ?? false;
  }

 /* Future<bool> _confirm({required String title, required String message, required String confirm, required String cancel}) async {
    final res = await Get.dialog<bool>(AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(onPressed: () => Get.back(result: false), child: Text(cancel)),
        TextButton(onPressed: () => Get.back(result: true), child: Text(confirm)),
      ],
    ));
    return res ?? false;
  }
*/
  void _disposeCtl() {
    for (final l in _ctl.values) {
      for (final c in l) {
        c.dispose();
      }
    }
    _ctl.clear();
  }

  @override
  void onClose() {
    timer.value?.stop();
    _disposeCtl();
    super.onClose();
  }
}