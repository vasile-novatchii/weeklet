import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:weeklet/domain/entities/income.dart';
import 'package:weeklet/domain/usecases/export/export_income_usecase.dart';
import 'package:weeklet/domain/usecases/export/transaction_pdf_labels.dart';

import '../../../helpers/pdf_unicode_text_extractor.dart';

class _FakePathProvider
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  @override
  Future<String?> getTemporaryPath() async => Directory.systemTemp.path;

  @override
  Future<String?> getApplicationDocumentsPath() async =>
      Directory.systemTemp.path;

  @override
  Future<String?> getApplicationSupportPath() async =>
      Directory.systemTemp.path;

  @override
  Future<String?> getApplicationCachePath() async =>
      Directory.systemTemp.path;

  @override
  Future<String?> getDownloadsPath() async => null;

  @override
  Future<List<String>?> getExternalCachePaths() async => null;

  @override
  Future<List<String>?> getExternalStoragePaths({
    StorageDirectory? type,
  }) async => null;

  @override
  Future<String?> getExternalStoragePath() async => null;

  @override
  Future<String?> getLibraryPath() async => null;
}


const _labelsRu = TransactionPdfLabels(
  reportTitleExpenses: 'Отчёт о расходах',
  reportTitleIncome: 'Отчёт о доходах',
  generatedLabel: 'Создано',
  recordsLabel: 'Записей',
  totalLabel: 'Итого',
  columnDate: 'Дата',
  columnCategory: 'Категория',
  columnDescription: 'Описание',
  columnAmount: 'Сумма',
  noRecordsLabel: 'Нет записей за',
  unknownCategoryLabel: 'Неизвестно',
);

ByteData _font(String name) =>
    ByteData.sublistView(File('assets/fonts/$name').readAsBytesSync());

int _pageCount(String path) => RegExp(
  r'/Type\s*/Page\b(?!s)',
).allMatches(latin1.decode(File(path).readAsBytesSync())).length;

void _setUpPaths() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() {
    PathProviderPlatform.instance = _FakePathProvider();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (MethodCall methodCall) async {
            if (methodCall.method == 'getTemporaryDirectory') {
              return Directory.systemTemp.path;
            }
            return null;
          },
        );
  });
}

ExportIncomeParams _params({
  required List<Income> incomes,
  int? month = 4,
  String localeCode = 'ru',
}) => ExportIncomeParams(
  incomes: incomes,
  currencySymbol: 'MDL',
  year: 2026,
  month: month,
  localeCode: localeCode,
  labels: _labelsRu,
  regularFont: _font('NotoSans-Regular.ttf'),
  boldFont: _font('NotoSans-Bold.ttf'),
);

Income _inc(int i, {String description = 'Salary'}) => Income(
  id: 'i$i',
  amount: 100.0 + i,
  description: description,
  date: DateTime(2026, 1 + i % 12, 1 + i % 27),
  createdAt: DateTime(2026, 1 + i % 12, 1 + i % 27),
);

void main() {
  _setUpPaths();
  const useCase = ExportIncomeUseCase();

  group('ExportIncomeUseCase', () {
    test('renders RU labels and Cyrillic data, no EN labels', () async {
      final path = await useCase(
        _params(incomes: [_inc(1, description: 'Зарплата')]),
      );
      final text = extractPdfUnicodeText(File(path));
      for (final s in [
        'Отчёт о доходах',
        'Создано',
        'Записей',
        'Дата',
        'Описание',
        'Сумма',
        'Итого',
        'Зарплата',
        'Апрель 2026',
      ]) {
        expect(text, contains(s));
      }
      expect(text, isNot(contains('Категория')));
      for (final s in [
        'Date',
        'Description',
        'Amount',
        'Records',
        'Income Report',
        'Generated',
      ]) {
        expect(text, isNot(contains(s)));
      }
    });

    test('month set gives month-named file', () async {
      final path = await useCase(_params(incomes: [_inc(1)]));
      expect(path.endsWith('/weeklet_income_april_2026.pdf'), isTrue);
    });

    test('month null gives year-only file name', () async {
      final path = await useCase(_params(incomes: [_inc(1)], month: null));
      expect(path.endsWith('/weeklet_income_2026.pdf'), isTrue);
    });

    test('whole-year export with 300 rows paginates', () async {
      final path = await useCase(
        _params(incomes: [for (var i = 0; i < 300; i++) _inc(i)], month: null),
      );
      expect(File(path).existsSync(), isTrue);
      expect(_pageCount(path), greaterThan(1));
    });

    test('empty list with null month renders no-records with year', () async {
      final path = await useCase(_params(incomes: [], month: null));
      expect(
        extractPdfUnicodeText(File(path)),
        contains('Нет записей за 2026'),
      );
    });
  });
}
