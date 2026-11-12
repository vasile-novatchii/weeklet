import 'package:flutter/material.dart';
import 'package:weeklet/core/extensions/context_extensions.dart';

/// Widget for the dialog title
class DialogTitle extends StatelessWidget {
  const DialogTitle({
    super.key,
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) => Text(
    title,
    style: context.titleMedium,
  );
}
