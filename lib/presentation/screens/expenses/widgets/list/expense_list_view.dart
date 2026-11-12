import 'package:flutter/material.dart';
import 'package:weeklet/core/constants/app_constants.dart';
import 'package:weeklet/domain/entities/category.dart';
import 'package:weeklet/domain/entities/expense.dart';
import 'package:weeklet/domain/utils/expense_grouping.dart';
import 'package:weeklet/l10n/app_localizations.dart';
import 'package:weeklet/presentation/screens/expenses/widgets/list/expense_week_group_view.dart';
import 'package:weeklet/presentation/widgets/common/empty_state_view.dart';

class ExpenseListView extends StatelessWidget {
  const ExpenseListView({
    super.key,
    required this.expenses,
    required this.categories,
    this.currencySymbol = AppConstants.DEFAULT_CURRENCY,
  });

  final List<Expense> expenses;
  final List<Category> categories;
  final String currencySymbol;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (expenses.isEmpty) {
      return EmptyStateView(
        icon: Icons.receipt_long_outlined,
        title: l10n.expensesEmptyTitle,
        subtitle: l10n.expensesEmptySubtitle,
      );
    }

    final groupedByWeek = ExpenseGrouping.groupByWeek(expenses);

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 50),
      itemCount: groupedByWeek.length,
      itemBuilder: (context, index) {
        final entry = groupedByWeek.entries.elementAt(index);
        return ExpenseWeekGroupView(
          weekNumber: entry.key.week,
          expenses: entry.value,
          categories: categories,
          currencySymbol: currencySymbol,
        );
      },
    );
  }
}
