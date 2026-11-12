import 'package:flutter/material.dart';
import 'package:weeklet/core/constants/app_constants.dart';
import 'package:weeklet/core/extensions/date_time_extensions.dart';
import 'package:weeklet/core/extensions/list_extensions.dart';
import 'package:weeklet/domain/entities/category.dart';
import 'package:weeklet/domain/entities/expense.dart';
import 'package:weeklet/presentation/screens/expenses/widgets/list/expense_item_view.dart';
import 'package:weeklet/presentation/widgets/common/day_header_text.dart';

class ExpenseDayGroupView extends StatelessWidget {
  const ExpenseDayGroupView({
    super.key,
    required this.date,
    required this.expenses,
    required this.categories,
    this.currencySymbol = AppConstants.DEFAULT_CURRENCY,
  });

  final DateTime date;
  final List<Expense> expenses;
  final List<Category> categories;
  final String currencySymbol;

  @override
  Widget build(BuildContext context) {
    final weekdayName = date.getWeekdayName();
    final dayMonth =
        '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}';
    final dayHeader = '$weekdayName - $dayMonth';

    return Column(
      crossAxisAlignment: .start,
      children: [
        DayHeaderText(title: dayHeader),
        ...expenses.map(
          (expense) {
            final category = categories.findById(expense.categoryId);
            return ExpenseItemView(
              expense: expense,
              category: category,
              currencySymbol: currencySymbol,
              // TODO: Add logic to determine if expense is income based on category type
              isIncome: false,
            );
          },
        ),
      ],
    );
  }
}
