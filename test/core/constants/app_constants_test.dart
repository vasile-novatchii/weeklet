import 'package:flutter_test/flutter_test.dart';
import 'package:weeklet/core/constants/app_constants.dart';

void main() {
  group('AppConstants (REL-03)', () {
    test('DEFAULT_CURRENCY is MDL', () {
      expect(AppConstants.DEFAULT_CURRENCY, equals('MDL'));
    });
  });
}
