import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weeklet/core/constants/category_icons.dart';
import 'package:weeklet/l10n/app_localizations.dart';
import 'package:weeklet/presentation/utils/category_icon_labels.dart';

void main() {
  Future<AppLocalizations> load(String code) =>
      AppLocalizations.delegate.load(Locale(code));

  test('every icon resolves to a non-empty label in en, ro and ru', () async {
    for (final code in ['en', 'ro', 'ru']) {
      final l10n = await load(code);
      for (final icon in kCategoryIcons) {
        expect(
          CategoryIconLabels.of(l10n, icon),
          isNotEmpty,
          reason: '$code ${icon.name}',
        );
      }
    }
  });

  test('en labels match the const English labels', () async {
    final l10n = await load('en');
    for (final icon in kCategoryIcons) {
      expect(CategoryIconLabels.of(l10n, icon), icon.label, reason: icon.name);
    }
  });

  for (final code in ['ro', 'ru']) {
    test('$code labels differ from en for the majority of icons', () async {
      final l10n = await load(code);
      final differing = kCategoryIcons
          .where((i) => CategoryIconLabels.of(l10n, i) != i.label)
          .length;
      expect(differing, greaterThan(kCategoryIcons.length ~/ 2));
    });
  }

  test('unknown icon name falls back to the const label', () async {
    final l10n = await load('ro');
    const icon = CategoryIcon(
      name: 'unknown_icon',
      icon: Icons.help,
      label: 'Fallback',
    );
    expect(CategoryIconLabels.of(l10n, icon), 'Fallback');
  });
}
