import 'package:flutter/material.dart';
import 'package:weeklet/presentation/widgets/common/deletion_dialog/dialog_cancel_button.dart';
import 'package:weeklet/presentation/widgets/common/deletion_dialog/dialog_confirm_button.dart';

/// Widget for the action buttons row
class DialogButtons extends StatelessWidget {
  const DialogButtons({
    super.key,
    required this.cancelButtonText,
    required this.confirmButtonText,
    required this.confirmButtonColor,
    required this.confirmButtonTextColor,
    required this.cancelButtonColor,
    required this.cancelButtonTextColor,
    this.onCancel,
    this.onConfirm,
  });

  final String cancelButtonText;
  final String confirmButtonText;
  final Color confirmButtonColor;
  final Color confirmButtonTextColor;
  final Color cancelButtonColor;
  final Color cancelButtonTextColor;
  final VoidCallback? onCancel;
  final VoidCallback? onConfirm;

  @override
  Widget build(
    BuildContext context,
  ) => Row(
    spacing: 16,
    children: [
      // Cancel button
      Expanded(
        child: DialogCancelButton(
          text: cancelButtonText,
          onPressed: onCancel,
          cancelButtonColor: cancelButtonColor,
          cancelButtonTextColor: cancelButtonTextColor,
        ),
      ),

      // Confirm button
      Expanded(
        child: DialogConfirmButton(
          text: confirmButtonText,
          bgColor: confirmButtonColor,
          fgColor: confirmButtonTextColor,
          onPressed: onConfirm,
        ),
      ),
    ],
  );
}
