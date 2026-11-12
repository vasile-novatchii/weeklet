import 'package:flutter_test/flutter_test.dart';
import 'package:weeklet/domain/entities/expense.dart';
import 'package:weeklet/domain/utils/expense_grouping.dart';

Expense _expense(DateTime createdAt, {String id = 'exp', double amount = 10}) =>
    Expense(
      id: id,
      amount: amount,
      description: 'Test',
      categoryId: 'cat-1',
      createdAt: createdAt,
    );

/// Mondays of ISO 2026 weeks 22 through 26, in ascending calendar order.
final _mondays = <DateTime>[
  DateTime(2026, 5, 25), // week 22
  DateTime(2026, 6, 1), // week 23
  DateTime(2026, 6, 8), // week 24
  DateTime(2026, 6, 15), // week 25
  DateTime(2026, 6, 22), // week 26
];

List<Expense> _weeks22To26() => [
  for (var i = 0; i < _mondays.length; i++)
    _expense(_mondays[i], id: 'exp-$i', amount: 10.0 * (i + 1)),
];

void main() {
  group('ExpenseGrouping.groupByWeek keys use ISO year and week', () {
    test('2025-12-30 and 2026-01-02 land in one group (2026, week 1)', () {
      final expenses = [
        _expense(DateTime(2025, 12, 30), id: 'a'),
        _expense(DateTime(2026, 1, 2), id: 'b'),
      ];

      final result = ExpenseGrouping.groupByWeek(
        expenses,
        now: DateTime(2026, 3, 2),
      );

      expect(result.keys.toList(), equals([(year: 2026, week: 1)]));
      expect(result[(year: 2026, week: 1)]!.length, equals(2));
    });

    test('2027-01-01 keys as (2026, 53) and never produces week 0', () {
      final result = ExpenseGrouping.groupByWeek(
        [_expense(DateTime(2027, 1, 1))],
        now: DateTime(2026, 3, 2),
      );

      expect(result.keys.toList(), equals([(year: 2026, week: 53)]));
      expect(result.keys.every((k) => k.week >= 1), isTrue);
    });

    test('Monday 2026-06-08 at local midnight keys as (2026, 24)', () {
      final result = ExpenseGrouping.groupByWeek(
        [_expense(DateTime(2026, 6, 8))],
        now: DateTime(2026, 3, 2),
      );

      expect(result.keys.toList(), equals([(year: 2026, week: 24)]));
    });
  });

  group(
    'ExpenseGrouping.groupByWeek ordering with current-week pin (D-12)',
    () {
      test('now in week 24 yields 24, 26, 25, 23, 22', () {
        final result = ExpenseGrouping.groupByWeek(
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
        final result = ExpenseGrouping.groupByWeek(
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
        final result = ExpenseGrouping.groupByWeek(
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
        final result = ExpenseGrouping.groupByWeek(_weeks22To26());

        expect(result, isNotEmpty);
        expect(result.keys.every((k) => k.week >= 1), isTrue);
      });

      test('empty input returns an empty map, pin inserts nothing', () {
        final result = ExpenseGrouping.groupByWeek(
          [],
          now: DateTime(2026, 6, 8),
        );

        expect(result, isEmpty);
      });
    },
  );

  group('ExpenseGrouping existing behavior preserved', () {
    test('each group holds every expense mapping to that key', () {
      final expenses = [
        _expense(DateTime(2026, 6, 8), id: 'mon'),
        _expense(DateTime(2026, 6, 10, 9), id: 'wed'),
        _expense(DateTime(2026, 6, 14, 23), id: 'sun'),
        _expense(DateTime(2026, 6, 15), id: 'next-mon'),
      ];

      final result = ExpenseGrouping.groupByWeek(
        expenses,
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
      final expenses = [
        _expense(DateTime(2026, 6, 10, 18), id: 'later'),
        _expense(DateTime(2026, 6, 8, 9), id: 'earlier'),
        _expense(DateTime(2026, 6, 8, 21), id: 'earlier-evening'),
      ];

      final result = ExpenseGrouping.groupByDay(expenses);

      expect(
        result.keys.toList(),
        equals([DateTime(2026, 6, 8), DateTime(2026, 6, 10)]),
      );
      expect(result[DateTime(2026, 6, 8)]!.length, equals(2));
    });

    test('calculateTotal sums all amounts', () {
      expect(ExpenseGrouping.calculateTotal(_weeks22To26()), equals(150.0));
    });
  });
}
