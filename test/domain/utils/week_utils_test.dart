import 'package:flutter_test/flutter_test.dart';
import 'package:weeklet/domain/utils/week_utils.dart';

/// The reference matrix below was produced by executing a verified ISO 8601
/// implementation against the 2024-2027 year boundaries (see 14-RESEARCH.md,
/// Root Cause 4). Every entry is a case the previous `_getISOWeekNumber`
/// helper got wrong.
final _referenceMatrix = <(DateTime, ({int year, int week}))>[
  // DST-safe midnight Mondays: local-time `difference().inDays` truncates to
  // N-1 across the spring transition, pushing these into the previous week.
  (DateTime(2026, 6, 8), (year: 2026, week: 24)),
  (DateTime(2026, 8, 17), (year: 2026, week: 34)),
  (DateTime(2026, 6, 8, 14, 30), (year: 2026, week: 24)),
  // Year starting Friday: Jan 1-3 belong to the previous ISO year, never
  // to a bogus "week 0" of the new one.
  (DateTime(2027, 1, 1), (year: 2026, week: 53)),
  (DateTime(2027, 1, 2), (year: 2026, week: 53)),
  (DateTime(2027, 1, 3), (year: 2026, week: 53)),
  (DateTime(2027, 1, 4), (year: 2027, week: 1)),
  // No phantom week 53 / year-boundary split: Dec 29-31 2025 is ISO week 1
  // of 2026, so it must share a key with early January 2026.
  (DateTime(2025, 12, 29), (year: 2026, week: 1)),
  (DateTime(2025, 12, 30), (year: 2026, week: 1)),
  (DateTime(2025, 12, 31), (year: 2026, week: 1)),
  (DateTime(2024, 12, 29), (year: 2024, week: 52)),
  (DateTime(2024, 12, 30), (year: 2025, week: 1)),
  (DateTime(2026, 1, 1), (year: 2026, week: 1)),
];

void main() {
  group('WeekUtils.isoWeekOf - DST-safe midnight Mondays', () {
    test('Monday 2026-06-08 at local midnight is week 24, not 23', () {
      expect(
        WeekUtils.isoWeekOf(DateTime(2026, 6, 8)),
        equals((year: 2026, week: 24)),
      );
    });

    test('Monday 2026-08-17 at local midnight is week 34, not 33', () {
      expect(
        WeekUtils.isoWeekOf(DateTime(2026, 8, 17)),
        equals((year: 2026, week: 34)),
      );
    });

    test('time of day does not change the key', () {
      expect(
        WeekUtils.isoWeekOf(DateTime(2026, 6, 8, 14, 30)),
        equals(WeekUtils.isoWeekOf(DateTime(2026, 6, 8))),
      );
      expect(
        WeekUtils.isoWeekOf(DateTime(2026, 6, 8, 23, 59, 59)),
        equals((year: 2026, week: 24)),
      );
    });
  });

  group('WeekUtils.isoWeekOf - year starting Friday produces no week 0', () {
    test('2027-01-01 belongs to ISO week 53 of 2026', () {
      expect(
        WeekUtils.isoWeekOf(DateTime(2027, 1, 1)),
        equals((year: 2026, week: 53)),
      );
    });

    test('2027-01-02 belongs to ISO week 53 of 2026', () {
      expect(
        WeekUtils.isoWeekOf(DateTime(2027, 1, 2)),
        equals((year: 2026, week: 53)),
      );
    });

    test('2027-01-03 belongs to ISO week 53 of 2026', () {
      expect(
        WeekUtils.isoWeekOf(DateTime(2027, 1, 3)),
        equals((year: 2026, week: 53)),
      );
    });

    test('2027-01-04 opens ISO week 1 of 2027', () {
      expect(
        WeekUtils.isoWeekOf(DateTime(2027, 1, 4)),
        equals((year: 2027, week: 1)),
      );
    });
  });

  group('WeekUtils.isoWeekOf - no phantom week 53 / year-boundary split', () {
    test('2025-12-29 through 2025-12-31 all map to ISO 2026 week 1', () {
      for (final day in [29, 30, 31]) {
        expect(
          WeekUtils.isoWeekOf(DateTime(2025, 12, day)),
          equals((year: 2026, week: 1)),
          reason: '2025-12-$day',
        );
      }
    });

    test('2026-01-01 shares the key with the tail of December 2025', () {
      expect(
        WeekUtils.isoWeekOf(DateTime(2026, 1, 1)),
        equals(WeekUtils.isoWeekOf(DateTime(2025, 12, 29))),
      );
    });

    test('2024-12-29 is the last day of ISO 2024 week 52', () {
      expect(
        WeekUtils.isoWeekOf(DateTime(2024, 12, 29)),
        equals((year: 2024, week: 52)),
      );
    });

    test('2024-12-30 already belongs to ISO 2025 week 1', () {
      expect(
        WeekUtils.isoWeekOf(DateTime(2024, 12, 30)),
        equals((year: 2025, week: 1)),
      );
    });
  });

  group('WeekUtils.isoWeekOf - full reference matrix', () {
    for (final entry in _referenceMatrix) {
      final (date, expected) = entry;
      test('$date -> $expected', () {
        expect(WeekUtils.isoWeekOf(date), equals(expected));
      });
    }

    test('week number is never 0 or negative', () {
      for (final entry in _referenceMatrix) {
        final (date, _) = entry;
        expect(
          WeekUtils.isoWeekOf(date).week,
          greaterThanOrEqualTo(1),
          reason: '$date produced a week below 1',
        );
      }
    });

    test('every day of 2026 and 2027 yields a week between 1 and 53', () {
      var cursor = DateTime(2026, 1, 1);
      final end = DateTime(2028, 1, 1);
      while (cursor.isBefore(end)) {
        final result = WeekUtils.isoWeekOf(cursor);
        expect(result.week, greaterThanOrEqualTo(1), reason: '$cursor');
        expect(result.week, lessThanOrEqualTo(53), reason: '$cursor');
        cursor = DateTime(cursor.year, cursor.month, cursor.day + 1);
      }
    });
  });
}
