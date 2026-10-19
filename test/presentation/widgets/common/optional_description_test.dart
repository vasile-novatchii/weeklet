import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weeklet/l10n/app_localizations.dart';
import 'package:weeklet/presentation/widgets/common/expense_details_column.dart';
import 'package:weeklet/presentation/widgets/common/form/description_field_view.dart';

Future<void> _pump(WidgetTester tester, Widget child) => tester.pumpWidget(
  MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
    home: Scaffold(body: child),
  ),
);

void main() {
  testWidgets('ExpenseDetailsColumn falls back to category name', (
    tester,
  ) async {
    await _pump(
      tester,
      const ExpenseDetailsColumn(
        description: '',
        categoryName: 'Food',
        time: '10:30',
      ),
    );
    expect(find.text('Food'), findsOneWidget);
    expect(find.text('10:30'), findsOneWidget);
    expect(find.text(''), findsNothing);
  });

  testWidgets('ExpenseDetailsColumn shows description when present', (
    tester,
  ) async {
    await _pump(
      tester,
      const ExpenseDetailsColumn(
        description: 'Lunch',
        categoryName: 'Food',
        time: '10:30',
      ),
    );
    expect(find.text('Lunch'), findsOneWidget);
    expect(find.text('Food • 10:30'), findsOneWidget);
  });

  testWidgets('DescriptionFieldView validates empty input without error', (
    tester,
  ) async {
    final formKey = GlobalKey<FormState>();
    await _pump(
      tester,
      Form(
        key: formKey,
        child: DescriptionFieldView(controller: TextEditingController()),
      ),
    );
    expect(formKey.currentState!.validate(), isTrue);
  });
}
