import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weeklet/l10n/app_localizations.dart';
import 'package:weeklet/l10n/app_localizations_en.dart';
import 'package:weeklet/presentation/screens/settings/privacy_policy_screen.dart';
import 'package:weeklet/presentation/screens/settings/terms_screen.dart';

Future<void> pumpApp(WidgetTester tester, Widget child) => tester.pumpWidget(
  MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
    home: child,
  ),
);

void main() {
  final l10n = AppLocalizationsEn();
  final repo = Uri.parse('https://github.com/Infvyr/weeklet');

  testWidgets('privacy screen renders localized section', (tester) async {
    await pumpApp(tester, const PrivacyPolicyScreen());
    expect(find.text(l10n.privacySection1Title), findsOneWidget);
    expect(find.text(l10n.privacySection1Body), findsOneWidget);
  });

  testWidgets('terms screen renders localized section', (tester) async {
    await pumpApp(tester, const TermsScreen());
    expect(find.text(l10n.termsSection1Title), findsOneWidget);
  });

  for (final entry in <String, Widget Function(Future<bool> Function(Uri))>{
    'privacy': (o) => PrivacyPolicyScreen(openUrl: o),
    'terms': (o) => TermsScreen(openUrl: o),
  }.entries) {
    testWidgets('${entry.key} link opens repo url', (tester) async {
      Uri? opened;
      await pumpApp(
        tester,
        entry.value((uri) async {
          opened = uri;
          return true;
        }),
      );
      await tester.scrollUntilVisible(
        find.text(l10n.legalRepoLinkLabel),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text(l10n.legalRepoLinkLabel));
      await tester.pump();
      expect(opened, repo);
      expect(find.text(l10n.errorGeneric), findsNothing);
    });

    for (final fail in ['false', 'throws']) {
      testWidgets('${entry.key} shows snackbar when opener $fail', (
        tester,
      ) async {
        await pumpApp(
          tester,
          entry.value((uri) async {
            if (fail == 'throws') {
              throw Exception('no browser');
            }
            return false;
          }),
        );
        await tester.scrollUntilVisible(
          find.text(l10n.legalRepoLinkLabel),
          200,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.tap(find.text(l10n.legalRepoLinkLabel));
        await tester.pump();
        expect(find.text(l10n.errorGeneric), findsOneWidget);
      });
    }
  }
}
