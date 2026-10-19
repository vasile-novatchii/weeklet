import 'package:flutter_test/flutter_test.dart';
import 'package:weeklet/domain/entities/statistics.dart';
import 'package:weeklet/domain/utils/stats_export_utils.dart';

MonthlyStats _stats(double income, double expenses) => MonthlyStats(
  totalIncome: income,
  totalExpenses: expenses,
  balance: income - expenses,
  incomeGrowthPercentage: 0,
  expenseGrowthPercentage: 0,
  categoryStats: const [],
);

EvolutionStats _evolution(
  int year,
  Map<int, ({double income, double expenses})> data,
) => EvolutionStats(
  snapshots: [
    for (var m = 1; m <= 12; m++)
      MonthlySnapshot(
        month: m,
        year: year,
        totalIncome: data[m]?.income ?? 0,
        totalExpenses: data[m]?.expenses ?? 0,
        balance: (data[m]?.income ?? 0) - (data[m]?.expenses ?? 0),
        categoryStats: const [],
      ),
  ],
);

double _sumIncome(Iterable<MonthlySnapshot> s) =>
    s.fold(0, (a, e) => a + e.totalIncome);

double _sumExpenses(Iterable<MonthlySnapshot> s) =>
    s.fold(0, (a, e) => a + e.totalExpenses);

void _expectInvariant(EvolutionStats input, List<MonthlySnapshot> rows) {
  expect(_sumIncome(rows), _sumIncome(input.snapshots));
  expect(_sumExpenses(rows), _sumExpenses(input.snapshots));
}

void main() {
  final now = DateTime(2026, 3, 15);

  group('hasExportableData', () {
    test('false when no income and no expenses', () {
      expect(StatsExportUtils.hasExportableData(_stats(0, 0)), isFalse);
    });
    test('true for income-only', () {
      expect(StatsExportUtils.hasExportableData(_stats(100, 0)), isTrue);
    });
    test('true for expense-only', () {
      expect(StatsExportUtils.hasExportableData(_stats(0, 50)), isTrue);
    });
    test('true for both', () {
      expect(StatsExportUtils.hasExportableData(_stats(1000, 500)), isTrue);
    });
  });

  group('monthRowsForSelection', () {
    final evo = _evolution(2025, {1: (income: 10, expenses: 5)});

    test('single month selection carries no month rows', () {
      expect(
        StatsExportUtils.monthRowsForSelection(
          evolution: evo,
          year: 2025,
          month: 3,
          now: now,
        ),
        isEmpty,
      );
    });

    test('annual selection without evolution carries no month rows', () {
      expect(
        StatsExportUtils.monthRowsForSelection(
          evolution: null,
          year: 2025,
          month: null,
          now: now,
        ),
        isEmpty,
      );
    });

    test('annual selection delegates to monthsForExport', () {
      expect(
        StatsExportUtils.monthRowsForSelection(
          evolution: evo,
          year: 2025,
          month: null,
          now: now,
        ),
        hasLength(12),
      );
    });
  });

  group('monthsForExport', () {
    test('past year returns Jan-Dec including zero rows', () {
      final evo = _evolution(2025, {2: (income: 100, expenses: 40)});
      final rows = StatsExportUtils.monthsForExport(evo, 2025, now: now);
      expect(rows.map((r) => r.month), [for (var i = 1; i <= 12; i++) i]);
      _expectInvariant(evo, rows);
    });

    test('current year runs to current month, March is a zero row', () {
      final evo = _evolution(2026, {
        1: (income: 100, expenses: 10),
        2: (income: 200, expenses: 20),
      });
      final rows = StatsExportUtils.monthsForExport(evo, 2026, now: now);
      expect(rows.map((r) => r.month), [1, 2, 3]);
      _expectInvariant(evo, rows);
    });

    test('current year with future-dated data extends to last data month', () {
      final evo = _evolution(2026, {
        1: (income: 100, expenses: 10),
        6: (income: 300, expenses: 30),
      });
      final rows = StatsExportUtils.monthsForExport(evo, 2026, now: now);
      expect(rows.map((r) => r.month), [1, 2, 3, 4, 5, 6]);
      _expectInvariant(evo, rows);
    });

    test('future year runs to last month with data', () {
      final evo = _evolution(2027, {2: (income: 100, expenses: 10)});
      final rows = StatsExportUtils.monthsForExport(evo, 2027, now: now);
      expect(rows.map((r) => r.month), [1, 2]);
      _expectInvariant(evo, rows);
    });

    test('future year without data is empty', () {
      final evo = _evolution(2027, {});
      final rows = StatsExportUtils.monthsForExport(evo, 2027, now: now);
      expect(rows, isEmpty);
      _expectInvariant(evo, rows);
    });

    test('unsorted input is returned sorted ascending', () {
      final evo = _evolution(2025, {2: (income: 100, expenses: 10)});
      final shuffled = EvolutionStats(
        snapshots: evo.snapshots.reversed.toList(),
      );
      final rows = StatsExportUtils.monthsForExport(shuffled, 2025, now: now);
      expect(rows.map((r) => r.month), [for (var i = 1; i <= 12; i++) i]);
      _expectInvariant(shuffled, rows);
    });
  });

  group('fileName', () {
    test('month file name uses english slug', () {
      expect(
        StatsExportUtils.fileName(2026, 3),
        'weeklet_stats_march_2026.pdf',
      );
      expect(
        StatsExportUtils.fileName(2025, 12),
        'weeklet_stats_december_2025.pdf',
      );
    });
    test('all months file name has year only', () {
      expect(StatsExportUtils.fileName(2025, null), 'weeklet_stats_2025.pdf');
    });
  });

  group('formatBalance', () {
    test('negative has leading minus', () {
      expect(StatsExportUtils.formatBalance(-500, 'MDL'), '-500.00 MDL');
    });
    test('positive uses grouping and 2 decimals', () {
      expect(StatsExportUtils.formatBalance(1234.5, 'MDL'), '1,234.50 MDL');
    });
    test('zero', () {
      expect(StatsExportUtils.formatBalance(0, 'MDL'), '0.00 MDL');
    });
  });

  group('formatGrowth', () {
    test('signs and one decimal', () {
      expect(StatsExportUtils.formatGrowth(0.12), '+12.0%');
      expect(StatsExportUtils.formatGrowth(-0.05), '-5.0%');
      expect(StatsExportUtils.formatGrowth(0), '+0.0%');
    });
  });

  group('formatShare', () {
    test('one decimal percent', () {
      expect(StatsExportUtils.formatShare(0.4532), '45.3%');
      expect(StatsExportUtils.formatShare(1.0), '100.0%');
      expect(StatsExportUtils.formatShare(0), '0.0%');
    });
  });
}
