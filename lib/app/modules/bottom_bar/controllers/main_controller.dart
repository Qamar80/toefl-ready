import 'package:get/get.dart';

class MainController extends GetxController {
  final tab = 0.obs;
  void changeTab(int i) => tab.value = i;
}
