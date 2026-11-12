import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weeklet/presentation/utils/app_bottom_sheet.dart';

const _sheetKey = Key('sheet');

Future<void> _pumpHost(
  WidgetTester tester, {
  required double bottomInset,
  required void Function(Future<String?>) onResult,
}) async {
  tester.view.physicalSize = const Size(400, 800);
  tester.view.devicePixelRatio = 1;
  tester.view.padding = FakeViewPadding(bottom: bottomInset);
  tester.view.viewPadding = FakeViewPadding(bottom: bottomInset);
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => onResult(
              showAppBottomSheet<String>(
                context: context,
                builder: (sheetContext) => SizedBox(
                  key: _sheetKey,
                  height: 100,
                  child: TextButton(
                    onPressed: () => Navigator.of(sheetContext).pop('done'),
                    child: const Text('close'),
                  ),
                ),
              ),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}

void main() {
  testWidgets('insets sheet content above the system bottom padding', (
    tester,
  ) async {
    await _pumpHost(tester, bottomInset: 34, onResult: (_) {});

    final bottom = tester.getBottomLeft(find.byKey(_sheetKey)).dy;
    expect(bottom, lessThanOrEqualTo(800 - 34));
  });

  testWidgets('adds no gap when there is no bottom padding', (tester) async {
    await _pumpHost(tester, bottomInset: 0, onResult: (_) {});

    final bottom = tester.getBottomLeft(find.byKey(_sheetKey)).dy;
    expect(bottom, 800);
  });

  testWidgets('returns the value popped by the sheet', (tester) async {
    late Future<String?> result;
    await _pumpHost(tester, bottomInset: 0, onResult: (f) => result = f);

    await tester.tap(find.text('close'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(await result, 'done');
  });
}
