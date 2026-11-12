import 'package:flutter_test/flutter_test.dart';
import 'package:weeklet/core/utils/locale_manager.dart';

void main() {
  group('LocaleManager — LOC-01 supported locales contract', () {
    test('supportedLocales contains exactly [en, ro, ru]', () {
      expect(LocaleManager.supportedLocales, hasLength(3));
      expect(
        LocaleManager.supportedLocales.map((l) => l.languageCode).toList(),
        equals(['en', 'ro', 'ru']),
      );
    });

    test('supportedLocales does not contain de, fr, es, or it', () {
      final codes = LocaleManager.supportedLocales
          .map((l) => l.languageCode)
          .toSet();
      expect(codes.contains('de'), isFalse);
      expect(codes.contains('fr'), isFalse);
      expect(codes.contains('es'), isFalse);
      expect(codes.contains('it'), isFalse);
    });

    test('supportedLocales entries have no country code', () {
      for (final locale in LocaleManager.supportedLocales) {
        expect(
          locale.countryCode,
          isNull,
          reason:
              'LOC-01 expects bare language locales (e.g., Locale(\'en\')) '
              'so MaterialApp.localeResolutionCallback can match by '
              'languageCode and fall through to en for unsupported locales.',
        );
      }
    });
  });
}
