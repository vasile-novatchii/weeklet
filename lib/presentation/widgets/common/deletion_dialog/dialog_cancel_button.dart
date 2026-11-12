import 'package:flutter/material.dart';
import 'package:weeklet/core/extensions/context_extensions.dart';
import 'package:weeklet/core/theme/sizes.dart';

/// Cancel button widget
class DialogCancelButton extends StatelessWidget {
  const DialogCancelButton({
    super.key,
    required this.text,
    required this.cancelButtonColor,
    required this.cancelButtonTextColor,
    this.onPressed,
  });

  final String text;
  final Color cancelButtonColor, cancelButtonTextColor;
  final VoidCallback? onPressed;

  @override
  Widget build(
    BuildContext context,
  ) => ElevatedButton(
    onPressed: () {
      onPressed?.call();
      context.pop(false);
    },
    style: ElevatedButton.styleFrom(
      backgroundColor: cancelButtonColor,
      foregroundColor: cancelButtonTextColor,
      minimumSize: const Size.fromHeight(
        kButtonHeight,
      ),
      elevation: 0,
      shadowColor: Colors.transparent,
    ),
    child: Text(
      text,
      style: context.labelMedium?.copyWith(fontWeight: FontWeight.w400),
    ),
  );
}
