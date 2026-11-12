import 'package:weeklet/core/constants/app_constants.dart';
import 'package:weeklet/core/utils/number_formatter.dart';

/// Utility class for monthly snapshot formatting and calculations
class MonthlySnapshotUtils {
  MonthlySnapshotUtils._();

  /// Formats balance text with proper sign and currency
  /// Returns text like "Balance: +2 081 MDL" or "Balance: -500 MDL"
  static String formatBalanceText(double balance) {
    final sign = balance >= 0 ? '+' : '-';
    final formatted = NumberFormatter.formatCurrency(
      balance.abs(),
      AppConstants.DEFAULT_CURRENCY,
    );
    return 'Balance: $sign$formatted';
  }

  /// Determines if balance is positive (should show in success color)
  static bool isBalancePositive(double balance) => balance >= 0;
}
