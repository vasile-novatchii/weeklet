import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weeklet/core/utils/locale_manager.dart';
import 'package:weeklet/l10n/app_localizations.dart';
import 'package:weeklet/presentation/widgets/common/form/date_field_view.dart';
import 'package:weeklet/presentation/widgets/input_view.dart';

void main() {
  final testDate = DateTime(2025, 1, 15);

  setUpAll(() {
    LocaleManager().initialize(const Locale('en'));
  });

  /// Pumps [DateFieldView] with the given [selectedDate].
  ///
  /// Pass [useNullDate] as true to explicitly test the null-date code path.
  Future<void> pumpDateField(
    WidgetTester tester, {
    DateTime? selectedDate,
    bool useNullDate = false,
    void Function(DateTime)? onDateSelected,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Scaffold(
          body: DateFieldView(
            selectedDate: useNullDate ? null : (selectedDate ?? testDate),
            onDateSelected: onDateSelected ?? (_) {},
          ),
        ),
      ),
    );
    await tester.pump();
  }

  group('DateFieldView', () {
    testWidgets('renders with initial date displayed', (tester) async {
      await pumpDateField(tester, selectedDate: DateTime(2025, 1, 15));
      expect(find.textContaining('2025'), findsOneWidget);
    });

    testWidgets('shows hint text when selectedDate is null', (tester) async {
      await pumpDateField(tester, useNullDate: true);
      // When selectedDate is null, the InputView hintText is l10n.dateFieldHint
      // ('Select date'). Verify via InputView widget's hintText property.
      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.textContaining('2025'), findsNothing);
      final inputView = tester.widget<InputView>(find.byType(InputView));
      expect(inputView.hintText, 'Select date');
    });

    testWidgets('renders the date as field text, not hint', (tester) async {
      await pumpDateField(tester);
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.controller!.text, contains('2025'));
    });

    testWidgets('null date gives empty text and visible hint', (tester) async {
      await pumpDateField(tester, useNullDate: true);
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.controller!.text, isEmpty);
      expect(find.text('Select date'), findsOneWidget);
    });

    testWidgets('updates text when selectedDate changes', (tester) async {
      await pumpDateField(tester);
      await pumpDateField(tester, selectedDate: DateTime(2026, 3, 4));
      await tester.pump();
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.controller!.text, contains('2026'));
    });

    testWidgets('opens a date picker dialog when tapped', (tester) async {
      await pumpDateField(tester);
      await tester.tap(find.byType(TextFormField));
      await tester.pumpAndSettle();
      expect(find.byType(Dialog), findsOneWidget);
    });
  });
}
