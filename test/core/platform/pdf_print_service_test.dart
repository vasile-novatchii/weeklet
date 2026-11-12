import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weeklet/core/platform/pdf_print_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('com.infvyr.weeklet/pdf_print');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  tearDown(() {
    messenger.setMockMethodCallHandler(channel, null);
  });

  group('PdfPrintService.jobNameFor', () {
    test('strips directory and .pdf extension', () {
      expect(
        PdfPrintService.jobNameFor('/tmp/cache/weeklet_stats_2026.pdf'),
        'weeklet_stats_2026',
      );
    });

    test('strips uppercase extension', () {
      expect(PdfPrintService.jobNameFor('/tmp/a/Report.PDF'), 'Report');
    });

    test('keeps name without extension', () {
      expect(PdfPrintService.jobNameFor('/tmp/a/report'), 'report');
    });
  });

  group('PdfPrintService.printPdf', () {
    test('invokes channel with filePath and jobName', () async {
      MethodCall? received;
      messenger.setMockMethodCallHandler(channel, (call) async {
        received = call;
        return null;
      });

      await PdfPrintService().printPdf(
        filePath: '/tmp/cache/weeklet_stats_2026.pdf',
      );

      expect(received, isNotNull);
      expect(received!.method, 'printPdf');
      final args = received!.arguments as Map<Object?, Object?>;
      expect(args['filePath'], '/tmp/cache/weeklet_stats_2026.pdf');
      expect(args['jobName'], 'weeklet_stats_2026');
    });

    test('wraps PlatformException in PdfPrintException', () async {
      messenger.setMockMethodCallHandler(channel, (call) async {
        throw PlatformException(code: 'INVALID_PATH', message: 'bad path');
      });

      expect(
        PdfPrintService().printPdf(filePath: '/x/y.pdf'),
        throwsA(isA<PdfPrintException>()),
      );
    });

    test('wraps MissingPluginException in PdfPrintException', () async {
      messenger.setMockMethodCallHandler(channel, null);

      expect(
        PdfPrintService().printPdf(filePath: '/x/y.pdf'),
        throwsA(isA<PdfPrintException>()),
      );
    });
  });
}
