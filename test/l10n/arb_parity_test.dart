import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _load(String locale) {
  final raw = File('lib/l10n/app_$locale.arb').readAsStringSync();
  return jsonDecode(raw) as Map<String, dynamic>;
}

Set<String> _messageKeys(Map<String, dynamic> arb) =>
    arb.keys.where((k) => !k.startsWith('@')).toSet();

final _placeholderPattern = RegExp(r'\{(\w+)\s*[,}]');

/// Placeholder names that the template declares or uses for [key].
///
/// Names come from the `@key.placeholders` metadata plus any `{name}` or
/// `{name, ...}` in the template text, so ICU branch text such as
/// `=1{one item}` is not mistaken for a placeholder.
Set<String> _templatePlaceholders(Map<String, dynamic> en, String key) {
  final meta = en['@$key'];
  final declared =
      meta is Map<String, dynamic> &&
          meta['placeholders'] is Map<String, dynamic>
      ? (meta['placeholders'] as Map<String, dynamic>).keys.toSet()
      : <String>{};
  final used = _placeholderPattern
      .allMatches(en[key] as String)
      .map((m) => m.group(1)!)
      .toSet();
  return {...declared, ...used};
}

/// The names from [names] that appear as a placeholder in [text].
Set<String> _usedPlaceholders(String text, Set<String> names) =>
    _placeholderPattern
        .allMatches(text)
        .map((m) => m.group(1)!)
        .where(names.contains)
        .toSet();

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

      test('app_$locale.arb has no keys absent from app_en.arb', () {
        final extra = _messageKeys(_load(locale)).difference(enKeys);
        expect(extra, isEmpty, reason: 'Stale in $locale: $extra');
      });

      test('app_$locale.arb placeholders match app_en.arb', () {
        final target = _load(locale);
        final bad = <String, String>{};
        for (final key in enKeys) {
          final value = target[key];
          if (value is! String) continue;
          final names = _templatePlaceholders(en, key);
          if (names.isEmpty) continue;
          final expected = _usedPlaceholders(en[key] as String, names);
          final actual = _usedPlaceholders(value, names);
          if (!_sameSet(expected, actual)) {
            bad[key] = 'expected $expected, got $actual';
          }
        }
        expect(bad, isEmpty, reason: 'Placeholder mismatch in $locale: $bad');
      });
    }
  });
}

bool _sameSet(Set<String> a, Set<String> b) =>
    a.length == b.length && a.containsAll(b);
