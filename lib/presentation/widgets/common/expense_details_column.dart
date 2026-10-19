import 'package:flutter/material.dart';
import 'package:weeklet/core/extensions/context_extensions.dart';

/// Column displaying expense description and category/time details
class ExpenseDetailsColumn extends StatelessWidget {
  const ExpenseDetailsColumn({
    super.key,
    required this.description,
    required this.categoryName,
    required this.time,
  });

  final String description;
  final String categoryName;
  final String time;

  @override
  Widget build(BuildContext context) {
    final hasDescription = description.trim().isNotEmpty;
    final primary = hasDescription ? description : categoryName;
    return Column(
      crossAxisAlignment: .start,
      children: [
        Tooltip(
          message: primary,
          child: Text(
            primary,
            style: context.titleSmall?.copyWith(
              fontWeight: .w500,
            ),
            maxLines: 1,
            overflow: .ellipsis,
          ),
        ),
        Text(
          hasDescription ? '$categoryName \u2022 $time' : time,
          style: context.labelSmall?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
          maxLines: 1,
          overflow: .ellipsis,
        ),
      ],
    );
  }
}
