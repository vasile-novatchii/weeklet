import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:share_plus_platform_interface/share_plus_platform_interface.dart';
import 'package:weeklet/core/di/service_locator.dart';
import 'package:weeklet/core/platform/pdf_print_service.dart';
import 'package:weeklet/l10n/app_localizations.dart';
import 'package:weeklet/presentation/utils/pdf_export_actions.dart';

import '../../helpers/fake_share_platform.dart';

class _FakePrintService extends PdfPrintService {
  final List<String> printed = [];
  bool shouldFail = false;

  @override
  Future<void> printPdf({required String filePath}) async {
    printed.add(filePath);
    if (shouldFail) throw const PdfPrintException('boom');
  }
}

const _path = '/tmp/weeklet_stats_2026.pdf';

void main() {
  // SharePlus.instance captures the platform on first access, so the fake
  // must be created once and only reset between tests.
  final fakeShare = FakeSharePlatform();
  late _FakePrintService fakePrint;

  setUpAll(() => SharePlatform.instance = fakeShare);

  setUp(() {
    fakeShare.reset();
    fakePrint = _FakePrintService();
    if (sl.isRegistered<PdfPrintService>()) sl.unregister<PdfPrintService>();
    sl.registerSingleton<PdfPrintService>(fakePrint);
  });

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    sl.unregister<PdfPrintService>();
  });

  Future<void> pumpHost(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => PdfExportActions.present(
                context,
                filePath: _path,
                subject: 'subj',
              ),
              child: const Text('go'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();
  }

  testWidgets('android shows Share and Print tiles', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    await pumpHost(tester);
    expect(find.text('Share'), findsOneWidget);
    expect(find.text('Print / Save as PDF'), findsOneWidget);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('android Print dispatches to PdfPrintService', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    await pumpHost(tester);
    await tester.tap(find.text('Print / Save as PDF'));
    await tester.pumpAndSettle();
    expect(fakePrint.printed, [_path]);
    expect(fakeShare.shareCalls, isEmpty);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('android Share dispatches to share_plus', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    await pumpHost(tester);
    await tester.tap(find.text('Share'));
    await tester.pumpAndSettle();
    expect(fakeShare.shareCalls, hasLength(1));
    expect(fakeShare.shareCalls.single.files!.single.path, _path);
    expect(fakePrint.printed, isEmpty);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('ios shares directly without a sheet', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    await pumpHost(tester);
    expect(find.text('Print / Save as PDF'), findsNothing);
    expect(fakeShare.shareCalls, hasLength(1));
    expect(fakePrint.printed, isEmpty);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('print failure shows error snackbar', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    fakePrint.shouldFail = true;
    await pumpHost(tester);
    await tester.tap(find.text('Print / Save as PDF'));
    await tester.pumpAndSettle();
    expect(find.text('Could not open print dialog'), findsOneWidget);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('share failure shows error snackbar and does not throw', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    fakeShare.shouldThrow = true;
    await pumpHost(tester);
    await tester.tap(find.text('Share'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(
      find.text('Failed to generate PDF. Please try again.'),
      findsOneWidget,
    );
    debugDefaultTargetPlatformOverride = null;
  });
}
