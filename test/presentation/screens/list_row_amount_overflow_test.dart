import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weeklet/domain/entities/category.dart';
import 'package:weeklet/domain/entities/expense.dart';
import 'package:weeklet/domain/entities/income.dart';
import 'package:weeklet/domain/entities/statistics.dart';
import 'package:weeklet/l10n/app_localizations.dart';
import 'package:weeklet/presentation/screens/expenses/widgets/list/expense_item_view.dart';
import 'package:weeklet/presentation/screens/income/widgets/list/income_item_view.dart';
import 'package:weeklet/presentation/screens/stats/widgets/category_details_list/category_details_item.dart';

// Regression guardrail for CR-01 (Phase 15 code review): a non-flex child of
// a Row gets an unbounded main-axis constraint regardless of an Expanded
// sibling, so ellipsis-trim silently no-ops unless the amount itself is
// wrapped in Flexible. These three list-row widgets pump at a real phone
// width with a 7+ digit amount that previously triggered
// "A RenderFlex overflowed" instead of trimming to an ellipsis.
void main() {
  Future<void> pumpNarrow(WidgetTester tester, Widget child) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Scaffold(
          body: SizedBox(width: 375, child: child),
        ),
      ),
    );
    await tester.pump();
  }

  final category = Category(
    id: 'c1',
    name: 'Groceries',
    icon: 'shopping_cart',
    createdAt: DateTime(2026),
  );

  group('List row amount overflow guardrail', () {
    testWidgets(
      'ExpenseItemView does not overflow with a 7-digit amount',
      (tester) async {
        await pumpNarrow(
          tester,
          ExpenseItemView(
            expense: Expense(
              id: 'e1',
              amount: 1234567.89,
              description: 'Weekly groceries',
              categoryId: category.id,
              createdAt: DateTime(2026),
            ),
            category: category,
          ),
        );

        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'IncomeItemView does not overflow with a 7-digit amount',
      (tester) async {
        await pumpNarrow(
          tester,
          IncomeItemView(
            income: Income(
              id: 'i1',
              amount: 1234567.89,
              description: 'Freelance payment',
              date: DateTime(2026),
              createdAt: DateTime(2026),
            ),
          ),
        );

        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'CategoryDetailsItem does not overflow with a very large total',
      (tester) async {
        await pumpNarrow(
          tester,
          CategoryDetailsItem(
            stat: CategoryStats(
              category: category,
              totalAmount: 999999999999999.99,
              percentage: 0.5,
            ),
            currencySymbol: 'MDL',
          ),
        );

        expect(tester.takeException(), isNull);
      },
    );
  });
}
