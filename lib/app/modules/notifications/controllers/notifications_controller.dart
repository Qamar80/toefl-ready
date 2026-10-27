import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toefl_pro/app/core/services/notification_service.dart';

import '../../../core/widgets/app_dialog.dart';

class NotificationsController extends GetxController {
  final _db = FirebaseFirestore.instance;

  /// 0 = All, 1 = Unread
  final filter = 0.obs;

  /// Ids hidden right after a swipe, before Firestore confirms the delete
  final hidden = Rx<Set<String>>({});

  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    NotificationService.to.syncInbox();
    // Pick up reminders that fire while this screen is open
    _timer = Timer.periodic(
      const Duration(seconds: 30),
          (_) => NotificationService.to.syncInbox(),
    );
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  CollectionReference<Map<String, dynamic>>? get _col {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    return _db.collection('users').doc(uid).collection('notifications');
  }

  Stream<QuerySnapshot<Map<String, dynamic>>>? get stream =>
      _col?.orderBy('createdAt', descending: true).snapshots();

  Future<void> markRead(String id) async {
    try {
      await _col?.doc(id).update({'read': true});
    } catch (_) {}
  }

  Future<void> markAllRead() async {
    final col = _col;
    if (col == null) return;
    final unread = await col.where('read', isEqualTo: false).get();
    if (unread.docs.isEmpty) return;
    final batch = _db.batch();
    for (final d in unread.docs) {
      batch.update(d.reference, {'read': true});
    }
    await batch.commit();
  }

  Future<void> deleteWithUndo(String id, Map<String, dynamic> data) async {
    hidden.value = {...hidden.value, id};
    try {
      await _col?.doc(id).delete();
    } catch (_) {}

    Get.closeAllSnackbars();
    Get.showSnackbar(GetSnackBar(
      message: 'Notification deleted',
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(16),
      borderRadius: 14,
      snackPosition: SnackPosition.BOTTOM,
      mainButton: TextButton(
        onPressed: () async {
          await _col?.doc(id).set(data);
          hidden.value = {...hidden.value}..remove(id);
          Get.closeCurrentSnackbar();
        },
        child: const Text('UNDO',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                letterSpacing: .5)),
      ),
    ));
  }
  Future<void> confirmClearAll() async {
    final ok = await AppDialog.danger(
      title: 'Clear all notifications?',
      message: 'This removes every notification from the list.',
      confirmText: 'Clear all',
      icon: Icons.notifications_off_outlined,
    );
    if (ok) await _clearAll();
  }
/*  Future<void> confirmClearAll() async {
    final ok = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Clear all notifications?'),
        content: const Text('This removes every notification from the list.'),
        actions: [
          TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Clear all',
                style: TextStyle(color: Color(0xFFEF4444))),
          ),
        ],
      ),
    );
    if (ok == true) await _clearAll();
  }*/

  Future<void> _clearAll() async {
    final col = _col;
    if (col == null) return;
    final all = await col.get();
    final batch = _db.batch();
    for (final d in all.docs) {
      batch.delete(d.reference);
    }
    await batch.commit();
  }

  // Kept for debugging, no longer shown in the UI
  Future<void> sendTest() => NotificationService.to.showTest();
}