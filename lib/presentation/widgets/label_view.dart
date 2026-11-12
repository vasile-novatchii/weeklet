import 'package:flutter/material.dart';
import 'package:weeklet/core/extensions/context_extensions.dart';

class LabelView extends StatelessWidget {
  const LabelView({
    super.key,
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: context.labelLarge?.copyWith(
      color: context.colorScheme.onSurfaceVariant,
    ),
  );
}
