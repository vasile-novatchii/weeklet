import 'package:intl/intl.dart';

class NumberFormatter {
  NumberFormatter._();

  /// Formats a currency amount with specified decimal places
  ///
  /// Example:
  /// ```dart
  /// formatCurrency(105.19, 'lei') // "105.19 lei"
  /// formatCurrency(144.6543, 'USD', decimals: 2) // "144.65 USD"
  /// ```
  static String formatCurrency(
    double amount,
    String currencySymbol, {
    int decimals = 2,
    String locale = 'en_US',
  }) {
    final formatter = NumberFormat.currency(
      symbol: '',
      decimalDigits: decimals,
      locale: locale,
    );
    final formattedAmount = formatter.format(amount.abs()).trim();
    return '$formattedAmount $currencySymbol';
  }

  /// Formats a currency amount with income/expense indicator
  ///
  /// Example:
  /// ```dart
  /// formatCurrencyWithSign(105.19, 'lei', isIncome: false) // "105.19 lei"
  /// formatCurrencyWithSign(39.98, 'lei', isIncome: true) // "+39.98 lei"
  /// ```
  static String formatCurrencyWithSign(
    double amount,
    String currencySymbol, {
    bool isIncome = false,
    int decimals = 2,
    String locale = 'en_US',
  }) {
    final formatter = NumberFormat.currency(
      symbol: '',
      decimalDigits: decimals,
      locale: locale,
    );
    final formattedAmount = formatter.format(amount.abs()).trim();
    final sign = isIncome ? '+' : '';
    return '$sign$formattedAmount $currencySymbol';
  }

  /// Formats an amount without any currency symbol.
  ///
  /// Example:
  /// ```dart
  /// formatAmount(105.19) // "105.19"
  /// formatAmount(1234.5) // "1,234.50"
  /// ```
  static String formatAmount(
    double amount, {
    int decimals = 2,
    String locale = 'en_US',
  }) {
    final formatter = NumberFormat.currency(
      symbol: '',
      decimalDigits: decimals,
      locale: locale,
    );
    return formatter.format(amount.abs()).trim();
  }

  /// Formats an amount without currency, with income '+' indicator.
  ///
  /// Example:
  /// ```dart
  /// formatAmountWithSign(39.98, isIncome: true) // "+39.98"
  /// ```
  static String formatAmountWithSign(
    double amount, {
    bool isIncome = false,
    int decimals = 2,
    String locale = 'en_US',
  }) {
    final sign = isIncome ? '+' : '';
    return '$sign${formatAmount(amount, decimals: decimals, locale: locale)}';
  }

  /// Trims a formatted amount to [maxDigits] digits, appending an ellipsis.
  ///
  /// Separators and sign are kept as-is; only the digits past [maxDigits]
  /// (including decimals) are dropped.
  ///
  /// Example:
  /// ```dart
  /// trimDigits('+1,234.50') // "+1,234.50"
  /// trimDigits('1,234,567,890,123.45') // "1,234,567,890,12…"
  /// ```
  static String trimDigits(String formatted, {int maxDigits = 12}) {
    var digits = 0;
    for (var i = 0; i < formatted.length; i++) {
      final code = formatted.codeUnitAt(i);
      if (code < 0x30 || code > 0x39) continue;
      digits++;
      if (digits > maxDigits) {
        final kept = formatted.substring(0, i);
        return '${kept.replaceFirst(RegExp(r'[,.\s]+$'), '')}…';
      }
    }
    return formatted;
  }

  /// Formats a currency amount compactly — values >= 1000 are abbreviated.
  ///
  /// Example:
  /// ```dart
  /// formatCompact(1200.0, 'MDL')   // "1.2K MDL"
  /// formatCompact(-3500.0, 'EUR')  // "-3.5K EUR"
  /// formatCompact(999.99, 'MDL')   // "999.99 MDL"
  /// ```
  static String formatCompact(double amount, String currencySymbol) {
    if (amount.abs() >= 1000) {
      final sign = amount < 0 ? '-' : '';
      final compact = (amount.abs() / 1000).toStringAsFixed(1);
      return '$sign${compact}K $currencySymbol';
    }
    return formatCurrency(amount, currencySymbol);
  }

  /// Formats a currency amount compactly with income/expense sign.
  ///
  /// Example:
  /// ```dart
  /// formatCompactWithSign(15000.0, 'MDL', isIncome: true)  // "+15.0K MDL"
  /// formatCompactWithSign(-3500.0, 'EUR')                  // "-3.5K EUR"
  /// formatCompactWithSign(999.0, 'MDL', isIncome: true)    // "+999.00 MDL"
  /// ```
  static String formatCompactWithSign(
    double amount,
    String currencySymbol, {
    bool isIncome = false,
  }) {
    if (amount.abs() >= 1000) {
      final sign = amount < 0 ? '-' : (isIncome ? '+' : '');
      final compact = (amount.abs() / 1000).toStringAsFixed(1);
      return '$sign${compact}K $currencySymbol';
    }
    return formatCurrencyWithSign(amount, currencySymbol, isIncome: isIncome);
  }

  /// Formats time from DateTime to HH:mm format
  ///
  /// Example:
  /// ```dart
  /// formatTime(DateTime(2026, 1, 27, 15, 34)) // "15:34"
  /// ```
  static String formatTime(DateTime dateTime) =>
      DateFormat('HH:mm').format(dateTime);
}
