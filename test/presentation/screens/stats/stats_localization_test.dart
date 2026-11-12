import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weeklet/core/theme/theme.dart';
import 'package:weeklet/domain/entities/statistics.dart';
import 'package:weeklet/l10n/app_localizations.dart';
import 'package:weeklet/presentation/blocs/stats/stats_bloc.dart';
import 'package:weeklet/presentation/blocs/stats/stats_event.dart';
import 'package:weeklet/presentation/blocs/stats/stats_state.dart';
import 'package:weeklet/presentation/screens/stats/widgets/annual_grouped_bar_chart.dart';
import 'package:weeklet/presentation/screens/stats/widgets/category_details_list/category_details_list.dart';
import 'package:weeklet/presentation/screens/stats/widgets/modern_donut_chart.dart';

import '../../../helpers/test_data.dart';

class MockStatsBloc extends MockBloc<StatsEvent, StatsState>
    implements StatsBloc {}

void main() {
  late MockStatsBloc bloc;

  setUp(() {
    bloc = MockStatsBloc();
    when(() => bloc.state).thenReturn(const StatsInitial());
  });

  final categories = [
    CategoryStats(
      category: fakeCategory(),
      totalAmount: 100,
      percentage: 1,
    ),
  ];
  final evolution = EvolutionStats(
    snapshots: [
      MonthlySnapshot(
        month: 1,
        year: 2025,
        totalIncome: 200,
        totalExpenses: 100,
        balance: 100,
        categoryStats: categories,
      ),
    ],
  );

  Future<void> pump(WidgetTester tester, String code) => tester.pumpWidget(
    BlocProvider<StatsBloc>.value(
      value: bloc,
      child: MaterialApp(
        locale: Locale(code),
        theme: AppTheme.lightTheme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [
                AnnualGroupedBarChart(
                  evolutionStats: evolution,
                  currencySymbol: 'MDL',
                ),
                ModernDonutChart(
                  categoryStats: categories,
                  totalExpenses: 100,
                  currencySymbol: 'MDL',
                ),
                CategoryDetailsList(
                  categoryStats: categories,
                  currencySymbol: 'MDL',
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );

  for (final code in ['en', 'ro', 'ru']) {
    testWidgets('$code stats labels are localized', (tester) async {
      tester.view.physicalSize = const Size(1200, 3000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await pump(tester, code);
      final l10n = await AppLocalizations.delegate.load(Locale(code));

      expect(find.text(l10n.statsIncomeVsExpensesTitle), findsOneWidget);
      expect(find.text(l10n.incomeBarLabel), findsOneWidget);
      expect(find.text(l10n.expensesBarLabel), findsOneWidget);
      expect(find.text(l10n.statsDonutTotalLabel), findsOneWidget);
      expect(find.text(l10n.statsCategoryDetailsTitle), findsOneWidget);
      expect(find.text(l10n.statsSpendingByCategoryTitle), findsOneWidget);

      if (code != 'en') {
        expect(find.text('Income vs Expenses'), findsNothing);
        expect(find.text('Category Details'), findsNothing);
        expect(find.text('Spending by Category'), findsNothing);
        expect(find.text('Expenses'), findsNothing);
      }
    });
  }
}
