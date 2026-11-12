import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weeklet/presentation/widgets/common/form/sheet_footer_padding.dart';

void main() {
  Future<EdgeInsets> pumpWith(WidgetTester tester, double bottom) async {
    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(viewPadding: EdgeInsets.only(bottom: bottom)),
        child: const Directionality(
          textDirection: TextDirection.ltr,
          child: SheetFooterPadding(child: SizedBox()),
        ),
      ),
    );
    return tester
        .widget<Padding>(
          find.descendant(
            of: find.byType(SheetFooterPadding),
            matching: find.byType(Padding),
          ),
        )
        .padding
        .resolve(TextDirection.ltr);
  }

  testWidgets('adds view padding plus comfort spacing', (tester) async {
    final p = await pumpWith(tester, 34);
    expect(p.bottom, greaterThanOrEqualTo(34 + 8));
  });

  testWidgets('keeps a base inset without view padding', (tester) async {
    final p = await pumpWith(tester, 0);
    expect(p.bottom, greaterThanOrEqualTo(12));
  });
}
