import 'package:flutter/material.dart';
import 'package:weeklet/core/constants/app_constants.dart';
import 'package:weeklet/core/utils/number_formatter.dart';
import 'package:weeklet/domain/entities/category.dart';
import 'package:weeklet/domain/entities/expense.dart';
import 'package:weeklet/domain/utils/expense_grouping.dart';
import 'package:weeklet/presentation/screens/expenses/widgets/list/expense_day_group_view.dart';
import 'package:weeklet/presentation/widgets/common/week_header_text.dart';
import 'package:weeklet/presentation/widgets/common/week_total_row.dart';

class ExpenseWeekGroupView extends StatelessWidget {
  const ExpenseWeekGroupView({
    super.key,
    required this.weekNumber,
    required this.expenses,
    required this.categories,
    this.currencySymbol = AppConstants.DEFAULT_CURRENCY,
  });

  final int weekNumber;
  final List<Expense> expenses;
  final List<Category> categories;
  final String currencySymbol;

  @override
  Widget build(BuildContext context) {
    final groupedByDay = ExpenseGrouping.groupByDay(expenses);
    final weekTotal = ExpenseGrouping.calculateTotal(expenses);
    final formattedTotal = NumberFormatter.formatCurrency(
      weekTotal,
      currencySymbol,
    );

    return Card(
      margin: const .only(bottom: 16),
      child: Padding(
        padding: const .all(16),
        child: Column(
          crossAxisAlignment: .start,
          children: [
            WeekHeaderText(weekNumber: weekNumber),
            const SizedBox(height: 10),
            const Divider(height: 0),
            ...groupedByDay.entries.map(
              (entry) => ExpenseDayGroupView(
                date: entry.key,
                expenses: entry.value,
                categories: categories,
                currencySymbol: currencySymbol,
              ),
            ),
            const SizedBox(height: 10),
            const Divider(height: 0),
            const SizedBox(height: 10),
            WeekTotalRow(formattedTotal: formattedTotal),
          ],
        ),
      ),
    );
  }
}
