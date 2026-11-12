import 'package:flutter/material.dart';
import 'package:weeklet/core/extensions/context_extensions.dart';

/// Text widget displaying category name with ellipsis
class CategoryNameText extends StatelessWidget {
  const CategoryNameText({
    super.key,
    required this.name,
    this.textAlign = .center,
    this.maxLines = 1,
  });

  final String name;
  final TextAlign textAlign;
  final int maxLines;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const .symmetric(horizontal: 5),
    child: Text(
      name,
      style: context.textTheme.labelMedium?.copyWith(
        fontWeight: .w400,
      ),
      textAlign: textAlign,
      overflow: .ellipsis,
      maxLines: maxLines,
    ),
  );
}
