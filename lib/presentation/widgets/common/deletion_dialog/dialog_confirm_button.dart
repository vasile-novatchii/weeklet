import 'package:flutter/material.dart';
import 'package:weeklet/core/extensions/context_extensions.dart';
import 'package:weeklet/core/theme/sizes.dart';

/// Confirm button widget
class DialogConfirmButton extends StatelessWidget {
  const DialogConfirmButton({
    super.key,
    required this.text,
    required this.bgColor,
    required this.fgColor,
    this.onPressed,
  });

  final String text;
  final Color bgColor, fgColor;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => ElevatedButton(
    onPressed: () {
      onPressed?.call();
      context.pop(true);
    },
    style: ElevatedButton.styleFrom(
      backgroundColor: bgColor,
      minimumSize: const Size.fromHeight(
        kButtonHeight,
      ),
      elevation: 0,
    ),
    child: Text(
      text,
      style: context.labelMedium?.copyWith(
        color: fgColor,
      ),
    ),
  );
}
