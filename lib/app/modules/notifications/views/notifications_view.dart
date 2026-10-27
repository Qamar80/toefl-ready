import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toefl_pro/app/core/theme/app_colors.dart';
import 'package:toefl_pro/app/core/widgets/common_widgets.dart';
import '../controllers/notifications_controller.dart';

typedef _Doc = QueryDocumentSnapshot<Map<String, dynamic>>;

class NotificationsView extends GetView<NotificationsController> {
  const NotificationsView({super.key});

  static const _blue = Color(0xFF1E88E5);
  static const _red = Color(0xFFEF4444);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: controller.stream,
          builder: (context, snap) {
            final loading = !snap.hasData && !snap.hasError;
            final all = snap.data?.docs ?? <_Doc>[];

            return Obx(() {
              final hidden = controller.hidden.value;
              final filter = controller.filter.value;

              final docs = all.where((d) => !hidden.contains(d.id)).toList();
              final unreadDocs =
              docs.where((d) => d.data()['read'] != true).toList();
              final shown = filter == 1 ? unreadDocs : docs;

              return Column(children: [
                _header(context,
                    unread: unreadDocs.length, hasAny: docs.isNotEmpty),
                _filters(context,
                    total: docs.length, unread: unreadDocs.length),
                Expanded(child: _body(context, snap, loading, shown, filter)),
              ]);
            });
          },
        ),
      ),
    );
  }

  // ───────────── Header ─────────────
  Widget _header(BuildContext context,
      {required int unread, required bool hasAny}) =>
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 6),
        child: Row(children: [
          _roundBtn(context, Icons.arrow_back_ios_new_rounded, Get.back,
              tooltip: 'Back', iconSize: 18),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Notifications',
                      style: poppins(20, w: FontWeight.w700)),
                  Text(
                    unread > 0 ? '$unread unread' : "You're all caught up",
                    style: body(12, color: muted(context)),
                  ),
                ]),
          ),
          if (unread > 0) ...[
            _roundBtn(context, Icons.done_all_rounded, controller.markAllRead,
                tooltip: 'Mark all as read'),
            const SizedBox(width: 8),
          ],
          if (hasAny)
            _roundBtn(
                context, Icons.delete_sweep_outlined, controller.confirmClearAll,
                tooltip: 'Clear all'),
        ]),
      );

  Widget _roundBtn(BuildContext context, IconData icon, VoidCallback onTap,
      {required String tooltip, double iconSize = 22}) =>
      Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey),
            ),
            child: Icon(icon, size: iconSize),
          ),
        ),
      );

  // ───────────── Filter pills ─────────────
  Widget _filters(BuildContext context,
      {required int total, required int unread}) =>
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
        child: Row(children: [
          _pill(context, 'All', total, 0),
          const SizedBox(width: 8),
          _pill(context, 'Unread', unread, 1),
        ]),
      );

  Widget _pill(BuildContext context, String label, int count, int index) {
    final selected = controller.filter.value == index;
    return InkWell(
      onTap: () => controller.filter.value = index,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? _blue : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? _blue : Colors.grey.shade400),
        ),
        child: Text(
          '$label · $count',
          style: body(12,
              w: FontWeight.w600, color: selected ? Colors.white : null),
        ),
      ),
    );
  }

  // ───────────── Body ─────────────
  Widget _body(BuildContext context,
      AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snap, bool loading,
      List<_Doc> shown, int filter) {
    if (snap.hasError) {
      return _empty(context, Icons.cloud_off_rounded,
          "Couldn't load notifications", 'Check your connection and try again.');
    }
    if (loading) return const Center(child: CircularProgressIndicator());
    if (shown.isEmpty) {
      return filter == 1
          ? _empty(context, Icons.mark_email_read_outlined,
          'No unread notifications', "You're all caught up.")
          : _empty(context, Icons.notifications_none_rounded,
          'No notifications yet',
          'Study reminders and updates will appear here.');
    }

    final items = _grouped(shown);
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      physics: const BouncingScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (ctx, i) {
        final it = items[i];
        if (it is String) {
          return Padding(
            padding: EdgeInsets.only(top: i == 0 ? 4 : 14, bottom: 8),
            child: Text(
              it.toUpperCase(),
              style: body(11, w: FontWeight.w700, color: muted(context))
                  .copyWith(letterSpacing: .8),
            ),
          );
        }
        return _card(ctx, it as _Doc);
      },
    );
  }

  /// Section labels (String) mixed with documents
  List<Object> _grouped(List<_Doc> docs) {
    final out = <Object>[];
    String? last;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (final d in docs) {
      final t = (d.data()['createdAt'] as Timestamp?)?.toDate() ?? now;
      final diff = today.difference(DateTime(t.year, t.month, t.day)).inDays;
      final label = diff <= 0
          ? 'Today'
          : diff == 1
          ? 'Yesterday'
          : diff < 7
          ? 'This week'
          : 'Earlier';
      if (label != last) {
        out.add(label);
        last = label;
      }
      out.add(d);
    }
    return out;
  }

  // ───────────── Notification card ─────────────
  Widget _card(BuildContext context, _Doc doc) {
    final d = doc.data();
    final unread = d['read'] != true;
    final (icon, color) = _style(d['type'] as String? ?? 'general');
    final time = (d['createdAt'] as Timestamp?)?.toDate();
    final title = (d['title'] as String?) ?? '';
    final text = (d['body'] as String?) ?? '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Dismissible(
        key: ValueKey(doc.id),
        direction: DismissDirection.endToStart,
        onDismissed: (_) => controller.deleteWithUndo(doc.id, d),
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 22),
          decoration: BoxDecoration(
            color: _red,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.delete_outline_rounded, color: Colors.white),
            const SizedBox(height: 2),
            Text('Delete',
                style: body(10.5, w: FontWeight.w600, color: Colors.white)),
          ]),
        ),
        child: Material(
          color: unread
              ? _blue.withOpacity(.07)
              : Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(
                color: unread ? _blue.withOpacity(.55) : Colors.grey.shade400),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: unread ? () => controller.markRead(doc.id) : null,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: color.withOpacity(.14),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(icon, color: color, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              Expanded(
                                child: Text(
                                  title,
                                  style: unread
                                      ? poppins(13.5)
                                      : body(13.5, w: FontWeight.w600),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(_time(time),
                                  style: body(10.5, color: muted(context))),
                              if (unread) ...[
                                const SizedBox(width: 6),
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                      color: _blue, shape: BoxShape.circle),
                                ),
                              ],
                            ]),
                            if (text.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                text,
                                style: body(12, color: muted(context)),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ]),
                    ),
                  ]),
            ),
          ),
        ),
      ),
    );
  }

  (IconData, Color) _style(String type) => switch (type) {
    'reminder' => (Icons.alarm_rounded, AppColors.amber),
    'test' => (Icons.check_circle_rounded, AppColors.teal600),
    _ => (Icons.campaign_rounded, _blue),
  };

  String _time(DateTime? t) {
    if (t == null) return 'Now';
    final now = DateTime.now();
    final sameDay =
        t.year == now.year && t.month == now.month && t.day == now.day;
    if (sameDay) {
      final diff = now.difference(t);
      if (diff.inMinutes < 1) return 'Now';
      final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
      final m = t.minute.toString().padLeft(2, '0');
      return '$h:$m ${t.hour < 12 ? 'AM' : 'PM'}';
    }
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[t.month - 1]} ${t.day}';
  }

  // ───────────── Empty / error state ─────────────
  Widget _empty(
      BuildContext context, IconData icon, String title, String sub) =>
      Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 0, 32, 60),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: _blue.withOpacity(.10),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: _blue),
            ),
            const SizedBox(height: 18),
            Text(title, style: poppins(16)),
            const SizedBox(height: 6),
            Text(sub,
                textAlign: TextAlign.center,
                style: body(12.5, color: muted(context))),
          ]),
        ),
      );
}