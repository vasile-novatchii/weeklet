import 'package:flutter/material.dart';
import 'package:weeklet/core/extensions/context_extensions.dart';
import 'package:weeklet/domain/entities/statistics.dart';
import 'package:weeklet/l10n/app_localizations.dart';
import 'package:weeklet/presentation/screens/stats/widgets/category_details_list/category_details_item.dart';

class CategoryDetailsList extends StatelessWidget {
  const CategoryDetailsList({
    super.key,
    required this.categoryStats,
    required this.currencySymbol,
  });

  final List<CategoryStats> categoryStats;
  final String currencySymbol;

  @override
  Widget build(BuildContext context) {
    if (categoryStats.isEmpty) return const SizedBox.shrink();

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context).statsCategoryDetailsTitle,
              style: context.bodySmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            ...categoryStats.map(
              (stat) => CategoryDetailsItem(
                stat: stat,
                currencySymbol: currencySymbol,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
