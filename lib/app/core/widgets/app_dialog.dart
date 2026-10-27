import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toefl_pro/app/core/theme/app_colors.dart';

enum AppDialogType { info, success, warning, danger }

class AppDialog {
  AppDialog._();

  /// Confirmation dialog. Returns true if confirmed, false otherwise.
  static Future<bool> confirm({
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    AppDialogType type = AppDialogType.info,
    IconData? icon,
    bool barrierDismissible = true,
  }) async {
    final result = await Get.dialog<bool>(
      _AppDialogView(
        title: title,
        message: message,
        type: type,
        icon: icon,
        confirmText: confirmText,
        cancelText: cancelText,
      ),
      barrierDismissible: barrierDismissible,
    );
    return result ?? false;
  }

  /// Single-button dialog (info, success, error, etc.)
  static Future<void> alert({
    required String title,
    required String message,
    String buttonText = 'OK',
    AppDialogType type = AppDialogType.info,
    IconData? icon,
  }) async {
    await Get.dialog(
      _AppDialogView(
        title: title,
        message: message,
        type: type,
        icon: icon,
        confirmText: buttonText,
        cancelText: null, // hides cancel button
      ),
    );
  }

  /// Shortcut for destructive actions like delete / clear.
  static Future<bool> danger({
    required String title,
    required String message,
    String confirmText = 'Delete',
    String cancelText = 'Cancel',
    IconData icon = Icons.delete_outline_rounded,
  }) {
    return confirm(
      title: title,
      message: message,
      confirmText: confirmText,
      cancelText: cancelText,
      type: AppDialogType.danger,
      icon: icon,
    );
  }
}

class _AppDialogView extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String? cancelText;
  final AppDialogType type;
  final IconData? icon;

  const _AppDialogView({
    required this.title,
    required this.message,
    required this.confirmText,
    required this.type,
    this.cancelText,
    this.icon,
  });

  Color get _color {
    switch (type) {
      case AppDialogType.success:
        return const Color(0xFF22C55E);
      case AppDialogType.warning:
        return const Color(0xFFF59E0B);
      case AppDialogType.danger:
        return const Color(0xFFEF4444);
      case AppDialogType.info:
        return AppColors.blueColor;
    }
  }

  IconData get _icon {
    if (icon != null) return icon!;
    switch (type) {
      case AppDialogType.success:
        return Icons.check_circle_outline_rounded;
      case AppDialogType.warning:
        return Icons.warning_amber_rounded;
      case AppDialogType.danger:
        return Icons.error_outline_rounded;
      case AppDialogType.info:
        return Icons.info_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: theme.dialogBackgroundColor,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: _color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(_icon, color: _color, size: 32),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                if (cancelText != null) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(result: false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(cancelText!),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Get.back(result: true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _color,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(confirmText),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}