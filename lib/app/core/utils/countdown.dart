import 'dart:async';
import 'package:get/get.dart';

/// Reactive countdown timer. Use inside Obx: `Obx(() => Text(timer.label))`.
class Countdown {
  final RxInt seconds;
  Timer? _t;
  Countdown(int start) : seconds = start.obs;

  void start({void Function()? onDone}) {
    _t?.cancel();
    _t = Timer.periodic(const Duration(seconds: 1), (t) {
      if (seconds.value <= 0) {
        t.cancel();
        onDone?.call();
      } else {
        seconds.value--;
      }
    });
  }

  void stop() => _t?.cancel();

  String get label {
    final m = (seconds.value ~/ 60).toString().padLeft(2, '0');
    final s = (seconds.value % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
