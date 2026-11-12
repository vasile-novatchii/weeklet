import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:weeklet/domain/entities/statistics.dart';
import 'package:weeklet/l10n/app_localizations.dart';
import 'package:weeklet/presentation/screens/stats/widgets/monthly_item/monthly_item.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('ro');
    await initializeDateFormatting('ru');
  });

  Future<void> pumpItem(WidgetTester tester, Locale locale) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(
          body: MonthlyItem(
            snapshot: MonthlySnapshot(
              month: 1,
              year: 2026,
              totalIncome: 100,
              totalExpenses: 50,
              balance: 50,
              categoryStats: [],
            ),
            maxIncome: 100,
            currencySymbol: 'MDL',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows Romanian month abbreviation under Locale ro', (
    tester,
  ) async {
    await pumpItem(tester, const Locale('ro'));
    expect(find.text('ian.'), findsOneWidget);
  });

  testWidgets('shows Russian month abbreviation under Locale ru', (
    tester,
  ) async {
    await pumpItem(tester, const Locale('ru'));
    expect(find.text('янв.'), findsOneWidget);
  });
}
