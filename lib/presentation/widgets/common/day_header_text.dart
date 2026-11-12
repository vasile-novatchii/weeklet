import 'package:flutter/material.dart';
import 'package:weeklet/core/extensions/context_extensions.dart';

/// Header text for displaying day information
class DayHeaderText extends StatelessWidget {
  const DayHeaderText({
    super.key,
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const .only(top: 16, bottom: 8),
    child: Text(
      title,
      style: context.labelLarge,
    ),
  );
}
