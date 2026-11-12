/// Shared ISO 8601 week computation used by the grouping utilities.
class WeekUtils {
  WeekUtils._();

  /// Returns the ISO 8601 `(year, week)` pair the given [date] belongs to.
  ///
  /// Per ISO 8601, weeks start on Monday and week 1 is the week containing the
  /// year's first Thursday. The returned `year` is the ISO year, which may
  /// differ from `date.year` at year boundaries: 2025-12-29 returns
  /// `(year: 2026, week: 1)` and 2027-01-01 returns `(year: 2026, week: 53)`.
  /// The returned `week` is always >= 1 - there is no week 0.
  ///
  /// The arithmetic runs on UTC date components deliberately. UTC has no
  /// daylight saving transitions, whereas the elapsed-time difference between
  /// two local midnights spanning a DST change is less than 24 hours times the
  /// day count, which silently truncates a whole day away.
  static ({int year, int week}) isoWeekOf(DateTime date) {
    final d = DateTime.utc(date.year, date.month, date.day);
    final thursday = d.add(Duration(days: DateTime.thursday - d.weekday));
    final firstJan = DateTime.utc(thursday.year, 1, 1);
    final week = thursday.difference(firstJan).inDays ~/ 7 + 1;

    return (year: thursday.year, week: week);
  }
}
