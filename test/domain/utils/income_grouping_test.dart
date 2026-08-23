import 'package:flutter_test/flutter_test.dart';
import 'package:weeklet/domain/entities/income.dart';
import 'package:weeklet/domain/utils/income_grouping.dart';

/// Income dates are stored at exactly midnight (`DateFieldView` calls
/// `toDateOnly()`), so every Monday-dated income entry hit the DST off-by-one
/// before this fix - not just the ones created around midnight.
Income _income(DateTime date, {String id = 'inc', double amount = 100}) =>
    Income(
      id: id,
      amount: amount,
      description: 'Salary',
      date: date,
      createdAt: date,
    );

/// Mondays of ISO 2026 weeks 22 through 26, in ascending calendar order.
final _mondays = <DateTime>[
  DateTime(2026, 5, 25), // week 22
  DateTime(2026, 6, 1), // week 23
  DateTime(2026, 6, 8), // week 24
  DateTime(2026, 6, 15), // week 25
  DateTime(2026, 6, 22), // week 26
];

List<Income> _weeks22To26() => [
  for (var i = 0; i < _mondays.length; i++)
    _income(_mondays[i], id: 'inc-$i', amount: 100.0 * (i + 1)),
];

void main() {
  group('IncomeGrouping.groupByWeek keys use ISO year and week', () {
    test('2025-12-30 and 2026-01-02 land in one group (2026, week 1)', () {
      final incomes = [
        _income(DateTime(2025, 12, 30), id: 'a'),
        _income(DateTime(2026, 1, 2), id: 'b'),
      ];

      final result = IncomeGrouping.groupByWeek(
        incomes,
        now: DateTime(2026, 3, 2),
      );

      expect(result.keys.toList(), equals([(year: 2026, week: 1)]));
      expect(result[(year: 2026, week: 1)]!.length, equals(2));
    });

    test('2027-01-01 keys as (2026, 53) and never produces week 0', () {
      final result = IncomeGrouping.groupByWeek(
        [_income(DateTime(2027, 1, 1))],
        now: DateTime(2026, 3, 2),
      );

      expect(result.keys.toList(), equals([(year: 2026, week: 53)]));
      expect(result.keys.every((k) => k.week != 0), isTrue);
      expect(result.keys.every((k) => k.week >= 1), isTrue);
    });

    test('Monday 2026-06-08 at midnight keys as (2026, 24)', () {
      final result = IncomeGrouping.groupByWeek(
        [_income(DateTime(2026, 6, 8))],
        now: DateTime(2026, 3, 2),
      );

      expect(result.keys.toList(), equals([(year: 2026, week: 24)]));
    });

    test('every midnight Monday of 2026 keys to its own week', () {
      // Regression guard for the DST off-by-one: consecutive Mondays must
      // produce consecutive, strictly increasing week numbers.
      final mondays = <DateTime>[];
      var cursor = DateTime(2026, 1, 5); // first Monday of ISO 2026 week 2
      while (cursor.year == 2026) {
        mondays.add(cursor);
        cursor = DateTime(cursor.year, cursor.month, cursor.day + 7);
      }

      final result = IncomeGrouping.groupByWeek(
        [
          for (var i = 0; i < mondays.length; i++)
            _income(mondays[i], id: 'mon-$i'),
        ],
        now: DateTime(2026, 3, 2),
      );

      expect(result.length, equals(mondays.length));
    });
  });

  group('IncomeGrouping.groupByWeek ordering with current-week pin (D-12)', () {
    test('now in week 24 yields 24, 26, 25, 23, 22', () {
      final result = IncomeGrouping.groupByWeek(
        _weeks22To26(),
        now: DateTime(2026, 6, 8),
      );

      expect(
        result.keys.toList(),
        equals([
          (year: 2026, week: 24),
          (year: 2026, week: 26),
          (year: 2026, week: 25),
          (year: 2026, week: 23),
          (year: 2026, week: 22),
        ]),
      );
    });

    test('now in week 25 yields 25, 26, 24, 23, 22', () {
      final result = IncomeGrouping.groupByWeek(
        _weeks22To26(),
        now: DateTime(2026, 6, 15),
      );

      expect(
        result.keys.toList(),
        equals([
          (year: 2026, week: 25),
          (year: 2026, week: 26),
          (year: 2026, week: 24),
          (year: 2026, week: 23),
          (year: 2026, week: 22),
        ]),
      );
    });

    test('now in an entry-free week yields plain descending order', () {
      final result = IncomeGrouping.groupByWeek(
        _weeks22To26(),
        now: DateTime(2026, 7, 6),
      );

      expect(
        result.keys.toList(),
        equals([
          (year: 2026, week: 26),
          (year: 2026, week: 25),
          (year: 2026, week: 24),
          (year: 2026, week: 23),
          (year: 2026, week: 22),
        ]),
      );
      expect(result.length, equals(5));
    });

    test('called without now, keys stay valid and non-empty', () {
      final result = IncomeGrouping.groupByWeek(_weeks22To26());

      expect(result, isNotEmpty);
      expect(result.keys.every((k) => k.week >= 1), isTrue);
    });

    test('empty input returns an empty map, pin inserts nothing', () {
      final result = IncomeGrouping.groupByWeek(
        [],
        now: DateTime(2026, 6, 8),
      );

      expect(result, isEmpty);
    });
  });

  group('IncomeGrouping existing behavior preserved', () {
    test('each group holds every income mapping to that key', () {
      final incomes = [
        _income(DateTime(2026, 6, 8), id: 'mon'),
        _income(DateTime(2026, 6, 10), id: 'wed'),
        _income(DateTime(2026, 6, 14), id: 'sun'),
        _income(DateTime(2026, 6, 15), id: 'next-mon'),
      ];

      final result = IncomeGrouping.groupByWeek(
        incomes,
        now: DateTime(2026, 3, 2),
      );

      expect(
        result[(year: 2026, week: 24)]!.map((e) => e.id).toList(),
        equals(['mon', 'wed', 'sun']),
      );
      expect(
        result[(year: 2026, week: 25)]!.map((e) => e.id).toList(),
        equals(['next-mon']),
      );
    });

    test('groupByDay still groups by date only, earliest first', () {
      final incomes = [
        _income(DateTime(2026, 6, 10), id: 'later'),
        _income(DateTime(2026, 6, 8), id: 'earlier'),
      ];

      final result = IncomeGrouping.groupByDay(incomes);

      expect(
        result.keys.toList(),
        equals([DateTime(2026, 6, 8), DateTime(2026, 6, 10)]),
      );
    });

    test('calculateTotal sums all amounts', () {
      expect(IncomeGrouping.calculateTotal(_weeks22To26()), equals(1500.0));
    });
  });
}
