// TEST-27: PDF export flow triggered by the real export icon (D-04), with
// byte-level content verification via the pdf_text_extractor helper.
//
// This test taps the real Icons.picture_as_pdf icon in ExpensesScreen's
// AppBar — never dispatches the export BLoC event directly — and asserts
// on the REAL generated PDF's byte content, not merely its existence.
//
// NOTE on extraction coupling: the byte-level assertions below rely on
// test/helpers/pdf_text_extractor.dart, which inflates the PDF's
// FlateDecode-compressed content streams and recovers Tj/TJ text-showing
// operator strings from the raw file bytes. That approach is coupled to
// the `pdf` package's current internal writer output format (compression
// choice, operator emission) and is not a public API — a future `pdf`
// package upgrade that changes those internals could break this test's
// extraction step even though the exported PDF itself remains perfectly
// valid. See test/helpers/pdf_text_extractor.dart for the same caveat.
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:share_plus_platform_interface/share_plus_platform_interface.dart';
import 'package:weeklet/app.dart';
import 'package:weeklet/core/utils/locale_manager.dart';
import 'package:weeklet/domain/entities/category.dart';
import 'package:weeklet/domain/repositories/category_repository.dart';
import 'package:weeklet/presentation/blocs/expense/expense_bloc.dart';
import 'package:weeklet/presentation/blocs/expense/expense_event.dart';
import 'package:weeklet/presentation/blocs/export/export_bloc.dart';
import 'package:weeklet/presentation/blocs/export/export_state.dart';
import 'package:weeklet/presentation/blocs/settings/settings_bloc.dart';
import 'package:weeklet/presentation/blocs/settings/settings_event.dart';
import 'package:weeklet/presentation/widgets/common/common_dropdown_button.dart';

import '../helpers/fake_share_platform.dart';
import '../helpers/pdf_unicode_text_extractor.dart';
import '../helpers/test_data.dart';
import '../helpers/test_hive_env.dart';

/// Adds one expense through the real Add sheet (Food category, today).
Future<void> _addExpense(WidgetTester tester) async {
  // --- Add -----------------------------------------------------------
  await tester.tap(find.byType(FloatingActionButton));
  await tester.pumpAndSettle();

  await tester.enterText(find.byType(TextFormField).first, '120.75');
  await tester.pump();

  await tester.enterText(
    find.byType(TextFormField).at(1),
    'Groceries at market',
  );
  await tester.pump();

  await tester.tap(find.byType(CommonDropdownButton<Category>));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Food').last);
  await tester.pumpAndSettle();

  // Confirming today's date via the picker's default-to-today 'OK' tap
  // guarantees ExpenseBloc.selectedMonth is non-null once the expense is
  // saved, which is required for the export icon to actually dispatch
  // (ExpensesScreen._onExportTapped early-returns otherwise).
  await tester.ensureVisible(find.byIcon(Icons.calendar_today_outlined));
  await tester.pump();
  await tester.tap(find.byIcon(Icons.calendar_today_outlined));
  await tester.pump();
  await tester.pump(const Duration(seconds: 1));
  // Confirm button is the last TextButton in the (localized) date dialog.
  await tester.tap(
    find
        .descendant(
          of: find.byType(DatePickerDialog),
          matching: find.byType(TextButton),
        )
        .last,
  );
  await tester.pumpAndSettle();

  await tester.tap(find.byType(ElevatedButton));
  await tester.pumpAndSettle();
}

void main() {
  // A LIVE binding (not the default AutomatedTestWidgetsFlutterBinding via
  // TestWidgetsFlutterBinding.ensureInitialized()) is required here: real
  // dart:io Hive box writes issued from inside a testWidgets callback never
  // resolve under the automated/fake-clock binding — the awaited Future
  // hangs forever even after pumpAndSettle() (13-02-SUMMARY.md Deviation 1).
  LiveTestWidgetsFlutterBinding();

  late FakeSharePlatform fakeShare;

  setUpAll(() {
    registerHiveAdaptersOnce();
    registerTestPathProvider();
    fakeShare = FakeSharePlatform();
    SharePlatform.instance = fakeShare;
    LocaleManager().initialize(const Locale('en'));
  });

  setUp(() async {
    await initTestDi();
    await GetIt.instance<CategoryRepository>().addCategory(fakeCategory());
    fakeShare.shareCalls.clear();
  });

  tearDown(() async {
    await teardownTestDi();

    // Defensive cleanup pass: teardownTestDi() only removes the temp Hive
    // directory, never the PDF this flow writes into the shared OS temp
    // dir. The per-test assertions below already delete their own file on
    // the happy path; this guards against a prior failed run leaving one
    // behind (T-13-07 — dummy fixture data must not accumulate in
    // Directory.systemTemp across runs).
    try {
      for (final entity in Directory.systemTemp.listSync()) {
        if (entity is! File) continue;
        final name = entity.uri.pathSegments.last;
        final isExportArtifact =
            (name.startsWith('weeklet_expenses_') ||
                name.startsWith('weeklet_income_')) &&
            name.endsWith('.pdf');
        if (isExportArtifact) {
          entity.deleteSync();
        }
      }
    } catch (_) {
      // Best-effort cleanup only — never fail a test over stale temp files.
    }
  });

  testWidgets('exporting expenses generates a real PDF with correct content', (
    tester,
  ) async {
    // A taller-than-default test surface is required: bottom sheets (Add /
    // Edit) are sized to 80% of screen height, and the default 800x600 test
    // window is too short to fit every field above the pinned Save button
    // without scrolling — which would otherwise make the Date field's
    // computed tap offset collide with the Save button's hit-test region.
    await tester.binding.setSurfaceSize(const Size(400, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const WeekletApp());
    await tester.pumpAndSettle();

    await _addExpense(tester);

    // The export icon is only rendered once filteredExpenses is non-empty.
    expect(find.byIcon(Icons.picture_as_pdf), findsOneWidget);

    // --- Export ----------------------------------------------------------
    // Tapping the real icon dispatches ExportExpensesStarted via
    // _onExportTapped, awaits the real ExportExpensesUseCase (real `pdf`
    // package render + real file write to the faked temp dir), then the
    // BlocListener's unawaited SharePlus.instance.share(...) fires against
    // fakeShare and, once that resolves, dispatches a reset back to
    // ExportInitial — a full round trip that completes within a single
    // pumpAndSettle() since the fake share call resolves immediately. The
    // ExportSuccess state itself is therefore captured via a stream
    // subscription started before the tap, not read from `.state`
    // afterward (which would already show the post-reset ExportInitial).
    ExportSuccess? capturedSuccess;
    final exportSubscription = GetIt.instance<ExportBloc>().stream.listen((
      state,
    ) {
      if (state is ExportSuccess) capturedSuccess = state;
    });

    await tester.tap(find.byIcon(Icons.picture_as_pdf));
    await tester.pumpAndSettle();
    await exportSubscription.cancel();

    expect(capturedSuccess, isNotNull);

    final filePath = capturedSuccess!.filePath;
    final file = File(filePath);
    expect(file.existsSync(), isTrue);
    expect(file.lengthSync(), greaterThan(0));

    // Valid PDF header check.
    final headerBytes = file.readAsBytesSync().sublist(0, 5);
    expect(latin1.decode(headerBytes, allowInvalid: true), '%PDF-');

    // Proves the icon -> BLoC -> share wiring completed end-to-end without
    // throwing (per D-04).
    expect(fakeShare.shareCalls.length, 1);
    expect(fakeShare.shareCalls.first.files!.single.path, filePath);

    // --- Content ---------------------------------------------------------
    // Byte-level verification (not just "a file exists"): recover the
    // PDF's actual rendered text and confirm the exported expense's real
    // data made it into the document.
    final text = extractPdfUnicodeText(file);
    expect(text, contains('120.75'));
    expect(text, contains('Groceries at market'));
    expect(text, contains('Food'));

    // Explicit temp-artifact hygiene: dummy financial fixture data must
    // not accumulate in the shared OS temp directory across test runs
    // (T-13-07). teardownTestDi() only cleans up Hive, not this file.
    if (file.existsSync()) {
      file.deleteSync();
    }
  });

  Future<ExportSuccess> exportAllMonths(
    WidgetTester tester, {
    Locale? locale,
  }) async {
    await tester.binding.setSurfaceSize(const Size(600, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const WeekletApp());
    await tester.pumpAndSettle();
    if (locale != null) {
      GetIt.instance<SettingsBloc>().add(LocaleChanged(locale));
      await tester.pumpAndSettle();
    }
    await _addExpense(tester);

    // Select "All Months" (month == null).
    GetIt.instance<ExpenseBloc>().add(const FilterDateChanged());
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.picture_as_pdf), findsOneWidget);

    ExportSuccess? captured;
    final sub = GetIt.instance<ExportBloc>().stream.listen((state) {
      if (state is ExportSuccess) captured = state;
    });
    await tester.tap(find.byIcon(Icons.picture_as_pdf));
    await tester.pumpAndSettle();
    await sub.cancel();
    expect(captured, isNotNull);
    return captured!;
  }

  testWidgets('All Months exports a whole-year PDF without a snackbar', (
    tester,
  ) async {
    final success = await exportAllMonths(tester);

    final year = DateTime.now().year;
    expect(success.filePath.endsWith('/weeklet_expenses_$year.pdf'), isTrue);
    expect(
      find.text('Please select a specific month to export.'),
      findsNothing,
    );
    expect(fakeShare.shareCalls.length, 1);

    final file = File(success.filePath);
    final text = extractPdfUnicodeText(file);
    expect(text, contains('Groceries at market'));
    expect(text, contains('$year'));
    if (file.existsSync()) file.deleteSync();
  });

  testWidgets('Russian locale renders RU column labels in the PDF', (
    tester,
  ) async {
    addTearDown(() => LocaleManager().initialize(const Locale('en')));

    final success = await exportAllMonths(tester, locale: const Locale('ru'));

    final file = File(success.filePath);
    final text = extractPdfUnicodeText(file);
    expect(text, contains('Дата'));
    expect(text, contains('Категория'));
    expect(text, contains('Описание'));
    expect(text, contains('Сумма'));
    expect(text, isNot(contains('Description')));
    if (file.existsSync()) file.deleteSync();
  });
}
