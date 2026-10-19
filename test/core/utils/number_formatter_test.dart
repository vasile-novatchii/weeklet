import 'package:flutter_test/flutter_test.dart';
import 'package:weeklet/core/utils/number_formatter.dart';

void main() {
  group('NumberFormatter.formatCompact (UX-04)', () {
    test('formats amount >= 1000 as compact K notation', () {
      expect(NumberFormatter.formatCompact(1200.0, 'MDL'), equals('1.2K MDL'));
    });

    test('formats negative amount >= 1000 with leading minus', () {
      expect(
        NumberFormatter.formatCompact(-3500.0, 'EUR'),
        equals('-3.5K EUR'),
      );
    });

    test('delegates to formatCurrency for amount < 1000', () {
      expect(
        NumberFormatter.formatCompact(999.99, 'MDL'),
        equals('999.99 MDL'),
      );
    });
  });

  group('NumberFormatter amount helpers without currency', () {
    test('formatAmount renders grouped absolute value', () {
      expect(NumberFormatter.formatAmount(105.19), equals('105.19'));
      expect(NumberFormatter.formatAmount(1234.5), equals('1,234.50'));
      expect(NumberFormatter.formatAmount(-1234.5), equals('1,234.50'));
    });

    test('formatAmountWithSign prefixes + only for income', () {
      expect(
        NumberFormatter.formatAmountWithSign(39.98, isIncome: true),
        equals('+39.98'),
      );
      expect(NumberFormatter.formatAmountWithSign(105.19), equals('105.19'));
    });

    test('currency formatters are unchanged', () {
      expect(NumberFormatter.formatCurrency(105.19, 'lei'), '105.19 lei');
      expect(
        NumberFormatter.formatCurrencyWithSign(39.98, 'lei', isIncome: true),
        '+39.98 lei',
      );
    });
  });
}
