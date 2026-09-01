import 'package:flutter/material.dart';
import 'package:weeklet/core/constants/app_constants.dart';
import 'package:weeklet/core/utils/number_formatter.dart';
import 'package:weeklet/domain/entities/income.dart';
import 'package:weeklet/domain/utils/income_grouping.dart';
import 'package:weeklet/presentation/screens/income/widgets/list/income_day_group_view.dart';
import 'package:weeklet/presentation/widgets/common/week_header_text.dart';
import 'package:weeklet/presentation/widgets/common/week_total_row.dart';

class IncomeWeekGroupView extends StatelessWidget {
  const IncomeWeekGroupView({
    super.key,
    required this.weekNumber,
    required this.incomes,
    this.currencySymbol = AppConstants.DEFAULT_CURRENCY,
  });

  final int weekNumber;
  final List<Income> incomes;
  final String currencySymbol;

  @override
  Widget build(BuildContext context) {
    final groupedByDay = IncomeGrouping.groupByDay(incomes);
    final weekTotal = IncomeGrouping.calculateTotal(incomes);
    final formattedTotal = NumberFormatter.formatCurrencyWithSign(
      weekTotal,
      currencySymbol,
      isIncome: true,
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
              (entry) => IncomeDayGroupView(
                date: entry.key,
                incomes: entry.value,
                currencySymbol: currencySymbol,
              ),
            ),
            const SizedBox(height: 10),
            const Divider(height: 0),
            const SizedBox(height: 10),
            WeekTotalRow(
              formattedTotal: formattedTotal,
              amountColor: Colors.green,
            ),
          ],
        ),
      ),
    );
  }
}
