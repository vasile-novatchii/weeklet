import 'package:flutter_test/flutter_test.dart';
import 'package:weeklet/domain/entities/expense.dart';
import 'package:weeklet/domain/entities/income.dart';
import 'package:weeklet/domain/utils/filter_visibility_utils.dart';

void main() {
  final expense = Expense(
    id: 'e1',
    amount: 10,
    description: 'd',
    categoryId: 'c',
    createdAt: DateTime(2026, 1, 1),
  );
  final income = Income(
    id: 'i1',
    amount: 10,
    description: 'd',
    date: DateTime(2026, 1, 1),
    createdAt: DateTime(2026, 1, 1),
  );

  group('showExpenseFilter', () {
    test('false when empty', () {
      expect(FilterVisibilityUtils.showExpenseFilter([]), isFalse);
    });
    test('true when any expense exists', () {
      expect(FilterVisibilityUtils.showExpenseFilter([expense]), isTrue);
    });
  });

  group('showIncomeFilter', () {
    test('false when empty', () {
      expect(FilterVisibilityUtils.showIncomeFilter([]), isFalse);
    });
    test('true when any income exists', () {
      expect(FilterVisibilityUtils.showIncomeFilter([income]), isTrue);
    });
  });

  group('showStatsFilter', () {
    test('false for empty map', () {
      expect(FilterVisibilityUtils.showStatsFilter({}), isFalse);
    });
    test('false when all years have empty month lists', () {
      expect(
        FilterVisibilityUtils.showStatsFilter({2026: [], 2025: []}),
        isFalse,
      );
    });
    test('true when another year has data', () {
      expect(
        FilterVisibilityUtils.showStatsFilter({2026: [], 2025: [3]}),
        isTrue,
      );
    });
  });
}
