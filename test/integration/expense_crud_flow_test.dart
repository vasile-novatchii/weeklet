// TEST-24: full expense CRUD flow driven entirely by real widget
// interaction against a real Hive-backed DI graph (test/helpers/
// test_hive_env.dart), never a direct BLoC event dispatch (D-01).
//
// A single testWidgets flow covers, in order, against the real WeekletApp:
//   1. Add    — tap the FAB, fill the real Add Expense form, pick a real
//               category and today's date, save, and see the new expense
//               in the real list.
//   2. View   — assert the added expense's description and formatted
//               amount are visible in the real list.
//   3. Edit   — open the item's overflow menu, tap Edit (a second real
//               bottom sheet, not the dead-code EditExpenseScreen route —
//               13-RESEARCH.md Pitfall 5), change the amount, save via the
//               real Save button, and see only the updated amount.
//   4. Delete — open the overflow menu, tap Delete, confirm the real
//               confirmation dialog, and see the expense removed (real
//               empty state shown).
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
import 'package:weeklet/presentation/widgets/common/empty_state_view.dart';

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
  // full WidgetTester API this flow needs.
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

  testWidgets('add -> view -> edit -> delete an expense', (tester) async {
    // A taller-than-default test surface is required: bottom sheets (Add /
    // Edit) are sized to 80% of screen height, and the default 800x600 test
    // window is too short to fit every field above the pinned Save button
    // without scrolling — which would otherwise make the Date field's
    // computed tap offset collide with the Save button's hit-test region.
    await tester.binding.setSurfaceSize(const Size(400, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const WeekletApp());
    await tester.pumpAndSettle();

    // --- Add ---------------------------------------------------------
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, '45.50');
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

    await tester.ensureVisible(find.byIcon(Icons.calendar_today_outlined));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.calendar_today_outlined));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    expect(find.text('Groceries at market'), findsOneWidget);
    // findsWidgets (>=1), not findsOneWidget: with exactly one expense in
    // the week, ExpenseWeekGroupView's week-total row renders the identical
    // formatted string as the item itself (both amount and week total equal
    // 45.50 MDL) — two on-screen matches is correct production behavior,
    // not a bug.
    expect(
      find.text(NumberFormatter.formatCurrencyWithSign(45.50, 'MDL')),
      findsWidgets,
    );

    // --- Edit ----------------------------------------------------------
    final l10n = AppLocalizations.of(
      tester.element(find.byType(Scaffold).first),
    );

    await tester.tap(find.byIcon(Icons.more_vert).first);
    await tester.pump();

    await tester.tap(find.text(l10n.editMenuLabel));
    await tester.pumpAndSettle();

    // Amount field is pre-filled from the tapped Expense: 45.5 (double's
    // toString drops the trailing zero from the entered '45.50').
    expect(
      tester
          .widget<TextFormField>(find.byType(TextFormField).first)
          .controller!
          .text,
      '45.5',
    );

    await tester.enterText(find.byType(TextFormField).first, '60.25');
    await tester.pump();

    // EditExpenseFormFooter renders Cancel then Save — Save is last.
    await tester.tap(find.byType(ElevatedButton).last);
    await tester.pumpAndSettle();

    expect(
      find.text(NumberFormatter.formatCurrencyWithSign(60.25, 'MDL')),
      findsWidgets,
    );
    expect(
      find.text(NumberFormatter.formatCurrencyWithSign(45.50, 'MDL')),
      findsNothing,
    );

    // --- Delete ----------------------------------------------------------
    await tester.tap(find.byIcon(Icons.more_vert).first);
    await tester.pump();

    await tester.tap(find.text(l10n.deleteMenuLabel));
    await tester.pumpAndSettle();

    await tester.tap(find.text(l10n.deleteButtonLabel));
    await tester.pumpAndSettle();

    expect(find.text('Groceries at market'), findsNothing);
    expect(find.byType(EmptyStateView), findsOneWidget);
  });
}
