// TEST-25: full income CRUD flow driven entirely by real widget interaction
// against a real Hive-backed DI graph (test/helpers/test_hive_env.dart),
// never a direct BLoC event dispatch (D-01).
//
// A single testWidgets flow covers, in order, against the real WeekletApp:
//   1. Navigate — switch from the default Expenses tab to the Income tab
//                 via the real bottom navigation bar.
//   2. Add      — tap the FAB, fill the real Add Income form (amount +
//                 description; date is optional and defaults to today),
//                 save, and see the new income in the real list.
//   3. View     — assert the added income's description and formatted
//                 amount are visible in the real list.
//   4. Delete   — open the item's overflow menu, tap Delete, confirm the
//                 real confirmation dialog, and see the income removed.
//
// Per D-01's scope and REQUIREMENTS.md's exact TEST-25 wording
// ("add -> view -> delete"), this flow intentionally does NOT exercise
// IncomeItemView's edit path — that production feature exists but is out
// of this requirement's scope, not omitted by accident.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:share_plus_platform_interface/share_plus_platform_interface.dart';
import 'package:weeklet/app.dart';
import 'package:weeklet/core/utils/locale_manager.dart';
import 'package:weeklet/core/utils/number_formatter.dart';
import 'package:weeklet/l10n/app_localizations.dart';

import '../helpers/fake_share_platform.dart';
import '../helpers/test_hive_env.dart';

void main() {
  // A LIVE binding (not the default AutomatedTestWidgetsFlutterBinding via
  // TestWidgetsFlutterBinding.ensureInitialized()) is required here: real
  // dart:io Hive box writes issued from inside a testWidgets callback never
  // resolve under the automated/fake-clock binding — the awaited Future
  // hangs forever even after pumpAndSettle(). LiveTestWidgetsFlutterBinding
  // lets real async file I/O complete normally while still supporting the
  // full WidgetTester API this flow needs. (Discovered and documented in
  // Plan 13-02's SUMMARY.md.)
  LiveTestWidgetsFlutterBinding();

  setUpAll(() {
    registerHiveAdaptersOnce();
    registerTestPathProvider();
    SharePlatform.instance = FakeSharePlatform();
    LocaleManager().initialize(const Locale('en'));
  });

  setUp(() async {
    await initTestDi();
  });

  tearDown(() async {
    await teardownTestDi();
  });

  testWidgets('add -> view -> delete an income entry', (tester) async {
    // A taller-than-default test surface is required: the Add Income bottom
    // sheet is sized to 80% of screen height, and the default 800x600 test
    // window is too short to fit every field above the pinned Save button
    // without scrolling (13-02's Deviation 2).
    await tester.binding.setSurfaceSize(const Size(400, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const WeekletApp());
    await tester.pumpAndSettle();

    // --- Navigate to Income tab ----------------------------------------
    await tester.tap(find.byIcon(Icons.account_balance_wallet));
    await tester.pumpAndSettle();

    // --- Add -------------------------------------------------------------
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, '250.00');
    await tester.pump();

    await tester.enterText(
      find.byType(TextFormField).at(1),
      'Freelance payment',
    );
    await tester.pump();

    // Date field is left untouched — it is optional and _onSave() defaults
    // to DateTime.now(), which already satisfies the current-year
    // requirement (13-RESEARCH.md Pitfall 3).

    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    // --- View --------------------------------------------------------------
    expect(find.text('Freelance payment'), findsOneWidget);
    // findsWidgets (>=1), not findsOneWidget: with exactly one income entry,
    // IncomeTotalCard's header total, IncomeWeekGroupView's week-total row,
    // and IncomeItemView's own amount all render the identical formatted
    // string (250.00 MDL) — three on-screen matches is correct production
    // behavior, not a bug (same pattern as Plan 13-02's expense flow).
    expect(
      find.text(
        NumberFormatter.formatCurrencyWithSign(
          250.00,
          'MDL',
          isIncome: true,
        ),
      ),
      findsWidgets,
    );

    // --- Delete ------------------------------------------------------------
    final l10n = AppLocalizations.of(
      tester.element(find.byType(Scaffold).first),
    );

    await tester.tap(find.byIcon(Icons.more_vert).first);
    await tester.pump();

    await tester.tap(find.text(l10n.deleteMenuLabel));
    await tester.pumpAndSettle();

    await tester.tap(find.text(l10n.deleteButtonLabel));
    await tester.pumpAndSettle();

    expect(find.text('Freelance payment'), findsNothing);
  });
}
