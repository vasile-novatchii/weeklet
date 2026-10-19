import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weeklet/core/utils/date_picker_config.dart';

void main() {
  group('DatePickerConfig - LOC-03 picker locale', () {
    test('en maps to en_GB', () {
      final result = DatePickerConfig.pickerLocale(const Locale('en'));
      expect(result, const Locale('en', 'GB'));
      expect(result.countryCode, 'GB');
    });

    test('ro follows app locale', () {
      expect(
        DatePickerConfig.pickerLocale(const Locale('ro')),
        const Locale('ro'),
      );
    });

    test('ru follows app locale', () {
      expect(
        DatePickerConfig.pickerLocale(const Locale('ru')),
        const Locale('ru'),
      );
    });
  });
}
