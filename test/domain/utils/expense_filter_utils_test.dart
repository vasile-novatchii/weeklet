import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:weeklet/core/utils/locale_manager.dart';
import 'package:weeklet/domain/entities/expense.dart';
import 'package:weeklet/domain/utils/expense_filter_utils.dart';

void main() {
  setUpAll(() async {
    // intl DateFormat requires locale data to be initialized before use.
    // In production, flutter_localizations handles this; in tests we do it
    // explicitly for each locale we test.
    await initializeDateFormatting('en');
    await initializeDateFormatting('ro');
    await initializeDateFormatting('ru');
    await initializeDateFormatting('en_US');
    await initializeDateFormatting('ro_RO');
    await initializeDateFormatting('ru_RU');
  });

  group('ExpenseFilterUtils month names', () {
    test('full names per locale', () {
      expect(ExpenseFilterUtils.getMonthName(1, 'en'), equals('January'));
      expect(ExpenseFilterUtils.getMonthName(1, 'ro'), equals('Ianuarie'));
      expect(ExpenseFilterUtils.getMonthName(1, 'ru'), equals('Январь'));
    });

    test('abbreviations per locale', () {
      expect(ExpenseFilterUtils.getMonthAbbreviation(1, 'en'), equals('Jan'));
      expect(ExpenseFilterUtils.getMonthAbbreviation(1, 'ro'), equals('ian.'));
      expect(ExpenseFilterUtils.getMonthAbbreviation(1, 'ru'), equals('янв.'));
    });

    test('depends on passed locale, not LocaleManager', () {
      LocaleManager().initialize(const Locale('en', 'US'));
      expect(ExpenseFilterUtils.getMonthName(1, 'ru'), equals('Январь'));
      expect(ExpenseFilterUtils.getMonthAbbreviation(1, 'ru'), equals('янв.'));
    });

    test('throws RangeError for months 0 and 13', () {
      expect(() => ExpenseFilterUtils.getMonthName(0, 'en'), throwsRangeError);
      expect(() => ExpenseFilterUtils.getMonthName(13, 'en'), throwsRangeError);
      expect(
        () => ExpenseFilterUtils.getMonthAbbreviation(0, 'en'),
        throwsRangeError,
      );
      expect(
        () => ExpenseFilterUtils.getMonthAbbreviation(13, 'en'),
        throwsRangeError,
      );
    });
  });

  group('ExpenseFilterUtils.extractAvailableYears', () {
    test('returns [currentYear] for empty list', () {
      final result = ExpenseFilterUtils.extractAvailableYears([]);
      expect(result, equals([DateTime.now().year]));
    });

    test('returns years sorted descending (newest first)', () {
      final expenses = [
        Expense(
          id: '1',
          amount: 100.0,
          description: 'Test',
          categoryId: 'cat-1',
          createdAt: DateTime(2021, 1, 1),
        ),
        Expense(
          id: '2',
          amount: 100.0,
          description: 'Test',
          categoryId: 'cat-1',
          createdAt: DateTime(2023, 1, 1),
        ),
        Expense(
          id: '3',
          amount: 100.0,
          description: 'Test',
          categoryId: 'cat-1',
          createdAt: DateTime(2022, 1, 1),
        ),
      ];
      final result = ExpenseFilterUtils.extractAvailableYears(expenses);
      expect(result, equals([2023, 2022, 2021]));
    });

    test(
      'deduplicates years (multiple expenses in same year count once)',
      () {
        final expenses = [
          Expense(
            id: '1',
            amount: 100.0,
            description: 'Test',
            categoryId: 'cat-1',
            createdAt: DateTime(2024, 1, 1),
          ),
          Expense(
            id: '2',
            amount: 100.0,
            description: 'Test',
            categoryId: 'cat-1',
            createdAt: DateTime(2024, 6, 1),
          ),
        ];
        final result = ExpenseFilterUtils.extractAvailableYears(expenses);
        expect(result, equals([2024]));
      },
    );
  });

  group('ExpenseFilterUtils.extractAvailableMonthsForYear', () {
    test('returns months for the correct year sorted ascending', () {
      final expenses = [
        Expense(
          id: '1',
          amount: 100.0,
          description: 'Test',
          categoryId: 'cat-1',
          createdAt: DateTime(2023, 5, 1),
        ),
        Expense(
          id: '2',
          amount: 100.0,
          description: 'Test',
          categoryId: 'cat-1',
          createdAt: DateTime(2023, 3, 1),
        ),
        Expense(
          id: '3',
          amount: 100.0,
          description: 'Test',
          categoryId: 'cat-1',
          createdAt: DateTime(2023, 8, 1),
        ),
      ];
      final result = ExpenseFilterUtils.extractAvailableMonthsForYear(
        expenses,
        2023,
      );
      expect(result, equals([3, 5, 8]));
    });

    test('returns empty list when no expenses exist for the given year', () {
      final expenses = [
        Expense(
          id: '1',
          amount: 100.0,
          description: 'Test',
          categoryId: 'cat-1',
          createdAt: DateTime(2022, 1, 1),
        ),
      ];
      final result = ExpenseFilterUtils.extractAvailableMonthsForYear(
        expenses,
        2021,
      );
      expect(result, isEmpty);
    });

    test(
      'deduplicates months (multiple expenses in same month count once)',
      () {
        final expenses = [
          Expense(
            id: '1',
            amount: 100.0,
            description: 'Test',
            categoryId: 'cat-1',
            createdAt: DateTime(2023, 1, 1),
          ),
          Expense(
            id: '2',
            amount: 100.0,
            description: 'Test',
            categoryId: 'cat-1',
            createdAt: DateTime(2023, 1, 15),
          ),
        ];
        final result = ExpenseFilterUtils.extractAvailableMonthsForYear(
          expenses,
          2023,
        );
        expect(result, equals([1]));
      },
    );
  });
}
