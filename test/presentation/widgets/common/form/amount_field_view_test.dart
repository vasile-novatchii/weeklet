import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weeklet/l10n/app_localizations.dart';
import 'package:weeklet/presentation/widgets/common/form/amount_field_view.dart';

void main() {
  late GlobalKey<FormState> formKey;
  late TextEditingController controller;

  setUp(() {
    formKey = GlobalKey<FormState>();
    controller = TextEditingController();
  });

  tearDown(() => controller.dispose());

  Future<void> pumpAmountField(
    WidgetTester tester, {
    String currencySymbol = 'MDL',
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Scaffold(
          body: Form(
            key: formKey,
            child: AmountFieldView(
              controller: controller,
              currencySymbol: currencySymbol,
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  group('AmountFieldView', () {
    testWidgets('renders a TextFormField', (tester) async {
      await pumpAmountField(tester);
      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('uses decimal keyboard type', (tester) async {
      await pumpAmountField(tester);
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(
        textField.keyboardType,
        const TextInputType.numberWithOptions(decimal: true),
      );
    });

    testWidgets('shows required error when submitted empty', (tester) async {
      await pumpAmountField(tester);
      formKey.currentState!.validate();
      await tester.pump();
      expect(find.text('This field is required'), findsOneWidget);
    });

    testWidgets('shows positive error when amount is zero', (tester) async {
      await pumpAmountField(tester);
      await tester.enterText(find.byType(TextFormField), '0');
      formKey.currentState!.validate();
      await tester.pump();
      expect(find.text('Amount must be greater than 0'), findsOneWidget);
    });

    testWidgets('shows no error when amount is valid', (tester) async {
      await pumpAmountField(tester);
      await tester.enterText(find.byType(TextFormField), '12.50');
      formKey.currentState!.validate();
      await tester.pump();
      expect(find.text('This field is required'), findsNothing);
      expect(find.text('Amount must be greater than 0'), findsNothing);
      expect(find.text('Invalid format (e.g., 10.50)'), findsNothing);
    });
  });
}
