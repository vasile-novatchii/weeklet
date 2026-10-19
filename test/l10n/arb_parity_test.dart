import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _load(String locale) {
  final raw = File('lib/l10n/app_$locale.arb').readAsStringSync();
  return jsonDecode(raw) as Map<String, dynamic>;
}

Set<String> _messageKeys(Map<String, dynamic> arb) =>
    arb.keys.where((k) => !k.startsWith('@')).toSet();

void main() {
  group('ARB parity - LOC-02', () {
    final en = _load('en');
    final enKeys = _messageKeys(en);

    for (final locale in ['ro', 'ru']) {
      test('app_$locale.arb contains every app_en.arb key', () {
        final target = _load(locale);
        final missing = enKeys.difference(_messageKeys(target));
        expect(missing, isEmpty, reason: 'Missing in $locale: $missing');
      });

      test('app_$locale.arb has non-empty string values', () {
        final target = _load(locale);
        final bad = enKeys
            .where((k) => target[k] is! String || (target[k] as String).isEmpty)
            .toList();
        expect(bad, isEmpty, reason: 'Empty/non-string in $locale: $bad');
      });
    }
  });
}
