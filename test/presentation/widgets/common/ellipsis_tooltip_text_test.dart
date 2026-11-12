import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weeklet/l10n/app_localizations.dart';
import 'package:weeklet/presentation/widgets/common/ellipsis_tooltip_text.dart';

void main() {
  // `EllipsisTooltipText` reads no BLoC state, so this uses the bare
  // MaterialApp pump shape (matching amount_field_view_test.dart) rather
  // than the shared `pumpApp` helper: `pumpApp`'s `providers` defaults to
  // `const []`, but `MultiBlocProvider` -> `MultiProvider` asserts
  // `children.isNotEmpty` (package:nested), which crashes on an empty list
  // regardless of `theme`. That is a pre-existing gap in the shared helper,
  // out of this plan's scope to fix.
  Future<void> pumpText(
    WidgetTester tester, {
    String text = '1234.56 MDL',
    TextStyle? style,
    ThemeData? theme,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        theme: theme,
        home: Scaffold(
          body: Center(child: EllipsisTooltipText(text: text, style: style)),
        ),
      ),
    );
    await tester.pump();
  }

  group('EllipsisTooltipText', () {
    testWidgets('renders the exact text passed in', (tester) async {
      await pumpText(tester, text: '1234.56 MDL');

      expect(find.text('1234.56 MDL'), findsOneWidget);
    });

    testWidgets('wraps the text in a Tooltip whose message equals the text', (
      tester,
    ) async {
      await pumpText(tester, text: '1234.56 MDL');

      final tooltip = tester.widget<Tooltip>(find.byType(Tooltip));
      expect(tooltip.message, '1234.56 MDL');
    });

    testWidgets(
      'renders a single-line, ellipsis-trimmed, non-wrapping Text',
      (tester) async {
        await pumpText(tester, text: '1234.56 MDL');

        final text = tester.widget<Text>(find.byType(Text));
        expect(text.maxLines, 1);
        expect(text.overflow, TextOverflow.ellipsis);
        expect(text.softWrap, false);
      },
    );

    testWidgets(
      'keeps the same Text contract and a single Tooltip under a dark theme',
      (tester) async {
        await pumpText(
          tester,
          text: '1234.56 MDL',
          theme: ThemeData(brightness: Brightness.dark),
        );

        expect(find.byType(Tooltip), findsOneWidget);
        final text = tester.widget<Text>(find.byType(Text));
        expect(text.maxLines, 1);
        expect(text.overflow, TextOverflow.ellipsis);
        expect(text.softWrap, false);
      },
    );
  });
}
