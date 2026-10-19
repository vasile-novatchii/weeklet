import 'package:intl/intl.dart' show DateFormat;
import 'package:weeklet/core/utils/locale_manager.dart';

/// [DateFormatStyle] enum defines various styles for formatting dates.
///
/// DateTime date = DateTime(2026, 1, 15);
/// [DateFormatStyle.short] - "1/15/26"
/// [DateFormatStyle.medium] - "Jan 15, 2026"
/// [DateFormatStyle.long] - "January 15, 2026"
/// [DateFormatStyle.full] - "Thursday, January 15, 2026"
/// [DateFormatStyle.input] - EN "15/01/2026", RO/RU "15.01.2026"
/// (add/edit date input, per D-01/D-03)
enum DateFormatStyle {
  short,
  medium,
  long,
  full,
  input,
}

extension DateTimeExtension on DateTime {
  String format({DateFormatStyle style = DateFormatStyle.medium}) =>
      formatByLocale(
        LocaleManager().currentLocaleString,
        style: style,
      );

  String formatByLocale(
    String locale, {
    DateFormatStyle style = DateFormatStyle.medium,
  }) {
    try {
      final pattern = _getPatternByStyle(style, locale);
      final formatter = DateFormat(pattern, locale);
      return formatter.format(this);
    } catch (e) {
      return _fallbackFormat();
    }
  }

  String formatWithPattern(String pattern) => formatWithPatternAndLocale(
    pattern,
    LocaleManager().currentLocaleString,
  );

  String formatWithPatternAndLocale(String pattern, String locale) {
    try {
      final formatter = DateFormat(pattern, locale);
      return formatter.format(this);
    } catch (e) {
      return _fallbackFormat();
    }
  }

  String getMonthName({bool abbreviated = false}) => getMonthNameWithLocale(
    LocaleManager().currentLocaleString,
    abbreviated: abbreviated,
  );

  String getMonthNameWithLocale(
    String locale, {
    bool abbreviated = false,
  }) {
    try {
      final formatter = DateFormat('MMMM', locale);
      final abbreviatedFormatter = DateFormat('MMM', locale);
      return abbreviated
          ? abbreviatedFormatter.format(this)
          : formatter.format(this);
    } catch (e) {
      return _fallbackFormat();
    }
  }

  String getWeekdayName({bool abbreviated = false}) => getWeekdayNameWithLocale(
    LocaleManager().currentLocaleString,
    abbreviated: abbreviated,
  );

  String getWeekdayNameWithLocale(
    String locale, {
    bool abbreviated = false,
  }) {
    try {
      final formatter = DateFormat('EEEE', locale);
      final abbreviatedFormatter = DateFormat('EEE', locale);
      return abbreviated
          ? abbreviatedFormatter.format(this)
          : formatter.format(this);
    } catch (e) {
      return _fallbackFormat();
    }
  }

  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year &&
        month == tomorrow.month &&
        day == tomorrow.day;
  }

  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  DateTime get startOfWeek {
    final daysToMonday = weekday - 1;
    return subtract(Duration(days: daysToMonday)).toDateOnly();
  }

  DateTime get endOfWeek {
    final daysToSunday = 7 - weekday;
    return add(
      Duration(days: daysToSunday),
    ).toDateOnly().copyWith(hour: 23, minute: 59, second: 59);
  }

  int get getWeekOfMonth {
    final firstDayOfMonth = DateTime(year, month, 1);
    final firstMonday = firstDayOfMonth.weekday == 1
        ? firstDayOfMonth
        : firstDayOfMonth.add(Duration(days: 8 - firstDayOfMonth.weekday));

    if (day < firstMonday.day) {
      return 0;
    }

    return ((day - firstMonday.day) ~/ 7) + 1;
  }

  bool isSameDay(DateTime other) =>
      year == other.year && month == other.month && day == other.day;

  DateTime toDateOnly() => DateTime(year, month, day);

  DateTime toDateTime() => DateTime(year, month, day, hour, minute, second);

  static Map<String, dynamic> getCompleteLocaleInfo(DateTime date) {
    final locale = LocaleManager().currentLocale;
    final localeString = LocaleManager().currentLocaleString;

    return {
      'localeString': localeString,
      'languageCode': locale.languageCode,
      'countryCode': locale.countryCode,
      'localeName': _getLocaleName(localeString),
      'dateFormatted': date.format(),
      'dateShort': date.format(style: DateFormatStyle.short),
      'dateMedium': date.format(style: DateFormatStyle.medium),
      'dateLong': date.format(style: DateFormatStyle.long),
      'dateFull': date.format(style: DateFormatStyle.full),
      'monthName': date.getMonthName(),
      'monthAbbr': date.getMonthName(abbreviated: true),
      'weekdayName': date.getWeekdayName(),
      'weekdayAbbr': date.getWeekdayName(abbreviated: true),
    };
  }

  static String _getLocaleName(String localeString) {
    final localeNames = {
      'en_US': 'English (United States)',
      'en_GB': 'English (Great Britain)',
      'ro_RO': 'Romanian (Romania)',
      'ru_RU': 'Russian (Russia)',
      'de_DE': 'German (Germany)',
      'fr_FR': 'French (France)',
      'es_ES': 'Spanish (Spain)',
      'it_IT': 'Italian (Italy)',
    };
    return localeNames[localeString] ?? localeString;
  }

  String _getPatternByStyle(DateFormatStyle style, String locale) {
    switch (style) {
      case DateFormatStyle.short:
        return _getShortPattern(locale);
      case DateFormatStyle.medium:
        return 'MMM d, yyyy';
      case DateFormatStyle.long:
        return 'MMMM d, yyyy';
      case DateFormatStyle.full:
        return 'EEEE, MMMM d, yyyy';
      case DateFormatStyle.input:
        return _getInputPattern(locale);
    }
  }

  /// Numeric input pattern: RO/RU `dd.MM.yyyy`, everything else `dd/MM/yyyy`.
  String _getInputPattern(String locale) {
    switch (locale.split('_').first) {
      case 'ro':
      case 'ru':
        return 'dd.MM.yyyy';
      default:
        return 'dd/MM/yyyy';
    }
  }

  /// Get locale-specific short format pattern
  ///
  /// Different locales use different date separators and orders:
  /// - US: M/d/yy (month first)
  /// - UK: d/M/yy (day first)
  /// - EU: dd.MM.yy or dd/MM/yy (day first with different separator)
  String _getShortPattern(String locale) {
    final shortPatterns = {
      'en': 'M/d/yy',
      'en_US': 'M/d/yy',
      'en_GB': 'd/M/yy',
      'ro': 'dd.MM.yy',
      'ro_RO': 'dd.MM.yy',
      'ru': 'dd.MM.yy',
      'ru_RU': 'dd.MM.yy',
      'de': 'dd.MM.yy',
      'de_DE': 'dd.MM.yy',
      'fr': 'dd/MM/yy',
      'fr_FR': 'dd/MM/yy',
      'es': 'dd/MM/yy',
      'es_ES': 'dd/MM/yy',
      'it': 'dd/MM/yy',
      'it_IT': 'dd/MM/yy',
    };
    return shortPatterns[locale] ?? 'M/d/yy';
  }

  /// Fallback format (ISO 8601)
  ///
  /// Used when DateFormat fails for any reason
  /// Format: YYYY-MM-DD (e.g., "2026-01-15")
  String _fallbackFormat() =>
      '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
}
