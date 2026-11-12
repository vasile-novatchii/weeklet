// TEST-26: cross-BLoC stats refresh after expense/income mutations, proven
// via what the user actually sees on the Stats tab after real bottom-nav
// navigation (D-03) — not an internal StatsBloc state assertion.
//
// A single testWidgets flow drives the real WeekletApp:
//   1. Add an expense via the real Add Expense form.
//   2. Switch to the Income tab and add an income via the real Add Income
//      form.
//   3. Tap the real Stats tab and assert the displayed balance reflects
//      both mutations.
//
// Why ANNUAL (not monthly) balance is asserted: ExpenseBloc._onAddExpense
// and IncomeBloc._onAddIncome both dispatch StatsBloc's Load-Monthly-Stats
// event for the current year, with no month argument. StatsBloc's handler
// only derives `selectedMonth` from `DateTime.now().month` when
// `isInitialLoad` is true (`state is! MonthlyStatsLoaded`); every
// subsequent call — including both AppInitializer's own initial dispatch
// (which runs before any data exists) and every CRUD-triggered reload in
// this flow — leaves the event's month as `null`, so `selectedMonth` stays
// `null` for the entire test. StatsScreen derives
// `isAnnual: loaded.month == null`, which is therefore ALWAYS true here.
// Asserting the l10n key for the *monthly* balance label would be
// asserting the wrong label given this app's current wiring — a future
// reader must not "fix" this assertion back to that label.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:share_plus_platform_interface/share_plus_platform_interface.dart';
import 'package:weeklet/app.dart';
import 'package:weeklet/core/utils/locale_manager.dart';
import 'package:weeklet/core/utils/number_formatter.dart';
import 'package:weeklet/domain/entities/category.dart';
import 'package:weeklet/domain/repositories/category_repository.dart';
import 'package:weeklet/l10n/app_localizations.dart';
import 'package:weeklet/presentation/widgets/common/common_dropdown_button.dart';

import '../helpers/fake_share_platform.dart';
import '../helpers/test_data.dart';
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
    await GetIt.instance<CategoryRepository>().addCategory(fakeCategory());
  });

  tearDown(() async {
    await teardownTestDi();
  });

  testWidgets('expense and income mutations refresh the Stats tab balance', (
    tester,
  ) async {
    // A taller-than-default test surface is required: the Add Expense /
    // Add Income bottom sheets are sized to 80% of screen height, and the
    // default 800x600 test window is too short to fit every field above
    // the pinned Save button without scrolling (13-02's Deviation 2).
    await tester.binding.setSurfaceSize(const Size(400, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const WeekletApp());
    await tester.pumpAndSettle();

    // --- Add an expense --------------------------------------------------
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, '45.50');
    await tester.pump();

    await tester.enterText(
      find.byType(TextFormField).at(1),
      'Groceries',
    );
    await tester.pump();

    await tester.tap(find.byType(CommonDropdownButton<Category>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Food').last);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byIcon(Icons.calendar_today_outlined));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.calendar_today_outlined));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    // --- Switch to Income tab and add an income ---------------------------
    await tester.tap(find.byIcon(Icons.account_balance_wallet));
    await tester.pumpAndSettle();

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

    // --- Navigate to the Stats tab and assert the refreshed balance -------
    // StatsScreen rebuilds from the SAME StatsBloc instance that both
    // ExpenseBloc._onAddExpense and IncomeBloc._onAddIncome already
    // refreshed via their pre-existing cross-BLoC side effect (Phase 11
    // wiring) — this tab switch is a local setState swap in MainNavigation,
    // not a route push, so nothing re-triggers the load manually here.
    await tester.tap(find.byIcon(Icons.trending_up));
    await tester.pumpAndSettle();

    final l10n = AppLocalizations.of(
      tester.element(find.byType(Scaffold).first),
    );

    // Confirms the ANNUAL — not monthly — balance card is shown, per this
    // file's top-of-file doc comment. findsOneWidget (not findsWidgets):
    // statsAnnualBalance renders exactly once (StatsBalanceCard), and
    // MainNavigation builds only the selected tab, so a second match would
    // be a regression worth catching (IN-02).
    expect(find.text(l10n.statsAnnualBalance), findsOneWidget);

    // 250.00 income - 45.50 expense = 204.50, positive so isIncome: true
    // renders the '+' sign.
    expect(
      find.text(
        NumberFormatter.formatCurrencyWithSign(
          204.50,
          'MDL',
          isIncome: true,
        ),
      ),
      findsOneWidget,
    );
  });
}
