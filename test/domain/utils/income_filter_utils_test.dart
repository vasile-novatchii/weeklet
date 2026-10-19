import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:weeklet/domain/entities/income.dart';
import 'package:weeklet/domain/utils/income_filter_utils.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('en');
    await initializeDateFormatting('ro');
    await initializeDateFormatting('ru');
  });

  group('IncomeFilterUtils month names', () {
    test('full names per locale', () {
      expect(IncomeFilterUtils.getMonthName(1, 'en'), equals('January'));
      expect(IncomeFilterUtils.getMonthName(1, 'ro'), equals('Ianuarie'));
      expect(IncomeFilterUtils.getMonthName(1, 'ru'), equals('Январь'));
    });

    test('abbreviations per locale', () {
      expect(IncomeFilterUtils.getMonthAbbreviation(1, 'en'), equals('Jan'));
      expect(IncomeFilterUtils.getMonthAbbreviation(1, 'ro'), equals('ian.'));
      expect(IncomeFilterUtils.getMonthAbbreviation(1, 'ru'), equals('янв.'));
    });

    test('throws RangeError for invalid month', () {
      expect(() => IncomeFilterUtils.getMonthName(13, 'en'), throwsRangeError);
    });
  });

  group('IncomeFilterUtils.extractAvailableYears', () {
    test('returns [currentYear] for empty list', () {
      expect(
        IncomeFilterUtils.extractAvailableYears([]),
        equals([DateTime.now().year]),
      );
    });

    test('returns years sorted descending (newest first)', () {
      final incomes = [
        Income(
          id: '1',
          amount: 100.0,
          description: 'Salary',
          date: DateTime(2021, 1, 1),
          createdAt: DateTime(2020, 1, 1),
        ),
        Income(
          id: '2',
          amount: 100.0,
          description: 'Salary',
          date: DateTime(2024, 1, 1),
          createdAt: DateTime(2020, 1, 1),
        ),
        Income(
          id: '3',
          amount: 100.0,
          description: 'Salary',
          date: DateTime(2022, 1, 1),
          createdAt: DateTime(2020, 1, 1),
        ),
      ];
      final result = IncomeFilterUtils.extractAvailableYears(incomes);
      expect(result, equals([2024, 2022, 2021]));
    });

    test('deduplicates years', () {
      final incomes = [
        Income(
          id: '1',
          amount: 100.0,
          description: 'Salary',
          date: DateTime(2023, 1, 1),
          createdAt: DateTime(2020, 1, 1),
        ),
        Income(
          id: '2',
          amount: 100.0,
          description: 'Salary',
          date: DateTime(2023, 6, 1),
          createdAt: DateTime(2020, 1, 1),
        ),
      ];
      final result = IncomeFilterUtils.extractAvailableYears(incomes);
      expect(result, equals([2023]));
    });
  });

  group('IncomeFilterUtils.extractAvailableMonthsForYear', () {
    test('returns months for the correct year sorted ascending', () {
      final incomes = [
        Income(
          id: '1',
          amount: 100.0,
          description: 'Salary',
          date: DateTime(2023, 11, 1),
          createdAt: DateTime(2020, 1, 1),
        ),
        Income(
          id: '2',
          amount: 100.0,
          description: 'Salary',
          date: DateTime(2023, 2, 1),
          createdAt: DateTime(2020, 1, 1),
        ),
        Income(
          id: '3',
          amount: 100.0,
          description: 'Salary',
          date: DateTime(2023, 7, 1),
          createdAt: DateTime(2020, 1, 1),
        ),
      ];
      final result = IncomeFilterUtils.extractAvailableMonthsForYear(
        incomes,
        2023,
      );
      expect(result, equals([2, 7, 11]));
    });

    test('returns empty list when no incomes exist for the given year', () {
      final incomes = [
        Income(
          id: '1',
          amount: 100.0,
          description: 'Salary',
          date: DateTime(2022, 1, 1),
          createdAt: DateTime(2020, 1, 1),
        ),
      ];
      final result = IncomeFilterUtils.extractAvailableMonthsForYear(
        incomes,
        2020,
      );
      expect(result, isEmpty);
    });

    test('deduplicates months', () {
      final incomes = [
        Income(
          id: '1',
          amount: 100.0,
          description: 'Salary',
          date: DateTime(2023, 3, 1),
          createdAt: DateTime(2020, 1, 1),
        ),
        Income(
          id: '2',
          amount: 100.0,
          description: 'Salary',
          date: DateTime(2023, 3, 15),
          createdAt: DateTime(2020, 1, 1),
        ),
      ];
      final result = IncomeFilterUtils.extractAvailableMonthsForYear(
        incomes,
        2023,
      );
      expect(result, equals([3]));
    });
  });
}
