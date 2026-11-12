import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:weeklet/core/extensions/date_time_extensions.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting();
  });

  group('DateTimeExtension - LOC-03 input pattern', () {
    final date = DateTime(2025, 1, 15);

    test('en uses dd/MM/yyyy', () {
      expect(
        date.formatByLocale('en', style: DateFormatStyle.input),
        '15/01/2025',
      );
    });

    test('ro and ru use dd.MM.yyyy', () {
      expect(
        date.formatByLocale('ro', style: DateFormatStyle.input),
        '15.01.2025',
      );
      expect(
        date.formatByLocale('ru', style: DateFormatStyle.input),
        '15.01.2025',
      );
    });

    test('unknown locale defaults to dd/MM/yyyy', () {
      expect(
        date.formatByLocale('fr', style: DateFormatStyle.input),
        '15/01/2025',
      );
    });

    test('regional locale splits on language code', () {
      expect(
        date.formatByLocale('ro_RO', style: DateFormatStyle.input),
        '15.01.2025',
      );
    });

    test('zero-pads day and month', () {
      expect(
        DateTime(2022, 6, 3).formatByLocale(
          'en',
          style: DateFormatStyle.input,
        ),
        '03/06/2022',
      );
    });

    test('ru has no year suffix', () {
      expect(
        DateTime(2022, 6, 3).formatByLocale(
          'ru',
          style: DateFormatStyle.input,
        ),
        '03.06.2022',
      );
    });

    test('other styles unchanged', () {
      expect(
        date.formatByLocale('en', style: DateFormatStyle.long),
        'January 15, 2025',
      );
      expect(
        date.formatByLocale('en', style: DateFormatStyle.short),
        '1/15/25',
      );
      expect(
        date.formatByLocale('en', style: DateFormatStyle.medium),
        'Jan 15, 2025',
      );
    });
  });
}
