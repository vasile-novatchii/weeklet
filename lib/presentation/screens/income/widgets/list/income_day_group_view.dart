import 'package:flutter/material.dart';
import 'package:weeklet/core/constants/app_constants.dart';
import 'package:weeklet/core/extensions/date_time_extensions.dart';
import 'package:weeklet/domain/entities/income.dart';
import 'package:weeklet/presentation/screens/income/widgets/list/income_item_view.dart';
import 'package:weeklet/presentation/widgets/common/day_header_text.dart';

class IncomeDayGroupView extends StatelessWidget {
  const IncomeDayGroupView({
    super.key,
    required this.date,
    required this.incomes,
    this.currencySymbol = AppConstants.DEFAULT_CURRENCY,
  });

  final DateTime date;
  final List<Income> incomes;
  final String currencySymbol;

  @override
  Widget build(BuildContext context) {
    final weekdayName = date.getWeekdayName();
    final dayMonth =
        '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}';
    final dayHeader = '$weekdayName  $dayMonth';

    return Column(
      crossAxisAlignment: .start,
      children: [
        DayHeaderText(title: dayHeader),
        ...incomes.map(
          (income) => IncomeItemView(
            income: income,
            currencySymbol: currencySymbol,
          ),
        ),
      ],
    );
  }
}
