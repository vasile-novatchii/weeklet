import 'package:flutter/material.dart';
import 'package:weeklet/core/extensions/context_extensions.dart';
import 'package:weeklet/presentation/widgets/common/deletion_dialog/dialog_buttons.dart';
import 'package:weeklet/presentation/widgets/common/deletion_dialog/dialog_icon.dart';
import 'package:weeklet/presentation/widgets/common/deletion_dialog/dialog_subtitle.dart';
import 'package:weeklet/presentation/widgets/common/deletion_dialog/dialog_title.dart';

/// Custom confirmation dialog widget
class CustomConfirmationDialog extends StatelessWidget {
  const CustomConfirmationDialog({
    super.key,
    required this.icon,
    required this.iconBackgroundColor,
    required this.title,
    required this.subtitle1,
    this.subtitle1AccentText,
    required this.subtitle2,
    required this.confirmButtonColor,
    required this.confirmButtonTextColor,
    required this.cancelButtonColor,
    required this.cancelButtonTextColor,
    required this.confirmButtonText,
    required this.cancelButtonText,
    this.iconColor = Colors.red,
    this.onConfirm,
    this.onCancel,
  });

  /// Icon to display at the top
  final IconData icon;

  /// Background color for the icon circle
  final Color iconBackgroundColor;

  /// Color of the icon itself
  final Color iconColor;

  /// Main title text
  final String title;

  /// First subtitle text
  final String subtitle1;

  /// First subtitle accented text
  final String? subtitle1AccentText;

  /// Second subtitle text
  final String subtitle2;

  /// Color for the confirm button
  final Color confirmButtonColor;

  /// Color for the text confirm button
  final Color confirmButtonTextColor;

  /// Text for the confirm button (default: "Delete")
  final String confirmButtonText;

  /// Text for the cancel button (default: "Cancel")
  final String cancelButtonText;

  /// Color for the cancel button
  final Color cancelButtonColor;

  /// Color for the text cancel button
  final Color cancelButtonTextColor;

  /// Callback when confirm button is pressed
  final VoidCallback? onConfirm;

  /// Callback when cancel button is pressed
  final VoidCallback? onCancel;

  /// Helper method to show the dialog
  static Future<bool?> show({
    required BuildContext context,
    required IconData icon,
    required Color iconBackgroundColor,
    required String title,
    required String subtitle1,
    String? subtitle1AccentText,
    required String subtitle2,
    required Color confirmButtonColor,
    required Color confirmButtonTextColor,
    required Color cancelButtonColor,
    required Color cancelButtonTextColor,
    required String confirmButtonText,
    required String cancelButtonText,
    Color iconColor = Colors.white,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) => showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => CustomConfirmationDialog(
      icon: icon,
      iconBackgroundColor: iconBackgroundColor,
      iconColor: iconColor,
      title: title,
      subtitle1: subtitle1,
      subtitle1AccentText: subtitle1AccentText,
      subtitle2: subtitle2,
      confirmButtonColor: confirmButtonColor,
      confirmButtonTextColor: confirmButtonTextColor,
      confirmButtonText: confirmButtonText,
      cancelButtonText: cancelButtonText,
      cancelButtonColor: cancelButtonColor,
      cancelButtonTextColor: cancelButtonTextColor,
      onConfirm: onConfirm,
      onCancel: onCancel,
    ),
  );

  @override
  Widget build(
    BuildContext context,
  ) => AlertDialog(
    backgroundColor: context.colorScheme.surface,
    shape: RoundedRectangleBorder(
      borderRadius: .circular(24),
    ),
    contentPadding: const .all(20),
    content: Column(
      mainAxisSize: .min,
      crossAxisAlignment: .start,
      children: [
        // Icon with circular background
        DialogIcon(
          icon: icon,
          backgroundColor: iconBackgroundColor,
          iconColor: iconColor,
        ),

        const SizedBox(height: 16),

        // Title
        DialogTitle(title: title),

        const SizedBox(height: 8),

        // First subtitle
        DialogSubtitle(
          text: subtitle1,
          accentedText: subtitle1AccentText,
        ),

        const SizedBox(height: 4),

        // Second subtitle
        DialogSubtitle(
          text: subtitle2,
        ),
      ],
    ),
    actions: [
      DialogButtons(
        cancelButtonText: cancelButtonText,
        confirmButtonText: confirmButtonText,
        confirmButtonColor: confirmButtonColor,
        confirmButtonTextColor: confirmButtonTextColor,
        cancelButtonColor: cancelButtonColor,
        cancelButtonTextColor: cancelButtonTextColor,
        onCancel: onCancel,
        onConfirm: onConfirm,
      ),
    ],
  );
}
