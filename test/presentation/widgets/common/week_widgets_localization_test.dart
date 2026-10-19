import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weeklet/l10n/app_localizations.dart';
import 'package:weeklet/presentation/widgets/common/week_header_text.dart';
import 'package:weeklet/presentation/widgets/common/week_total_row.dart';

void main() {
  Future<void> pump(WidgetTester tester, String code) => tester.pumpWidget(
    MaterialApp(
      locale: Locale(code),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const Scaffold(
        body: Column(
          children: [
            WeekHeaderText(weekNumber: 3),
            WeekTotalRow(formattedTotal: '10'),
          ],
        ),
      ),
    ),
  );

  testWidgets('en shows English labels', (tester) async {
    await pump(tester, 'en');
    expect(find.text('Week 3'), findsOneWidget);
    expect(find.text('Total week'), findsOneWidget);
  });

  for (final code in ['ro', 'ru']) {
    testWidgets('$code shows localized labels', (tester) async {
      await pump(tester, code);
      final l10n = await AppLocalizations.delegate.load(Locale(code));
      expect(find.text(l10n.weekHeaderLabel(3)), findsOneWidget);
      expect(find.text(l10n.weekTotalLabel), findsOneWidget);
      expect(find.text('Week 3'), findsNothing);
      expect(find.text('Total week'), findsNothing);
    });
  }
}
