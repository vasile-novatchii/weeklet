import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weeklet/presentation/widgets/common/ellipsis_tooltip_text.dart';

import '../../../helpers/test_app.dart';

void main() {
  Future<void> pumpText(
    WidgetTester tester, {
    String text = '1234.56 MDL',
    TextStyle? style,
    ThemeData? theme,
  }) async {
    await pumpApp(
      tester,
      Scaffold(
        body: Center(child: EllipsisTooltipText(text: text, style: style)),
      ),
      theme: theme,
    );
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
