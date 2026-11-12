import 'package:flutter/material.dart';
import 'package:weeklet/core/extensions/context_extensions.dart';

/// Widget for dialog subtitle text
class DialogSubtitle extends StatelessWidget {
  const DialogSubtitle({
    super.key,
    required this.text,
    this.accentedText,
  });

  final String text;
  final String? accentedText;

  @override
  Widget build(BuildContext context) => Text.rich(
    TextSpan(
      children: [
        TextSpan(text: text),
        if (accentedText != null)
          TextSpan(
            text: accentedText,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: context.colorScheme.onSurface.withValues(
                alpha: .8,
              ),
            ),
          ),
      ],
    ),
    style: context.bodyMedium?.copyWith(
      color: context.colorScheme.onSurfaceVariant,
    ),
  );
}
