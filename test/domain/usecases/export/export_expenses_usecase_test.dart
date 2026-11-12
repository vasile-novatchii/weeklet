import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:weeklet/domain/entities/category.dart';
import 'package:weeklet/domain/entities/expense.dart';
import 'package:weeklet/domain/usecases/export/export_expenses_usecase.dart';
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
  Future<String?> getApplicationCachePath() async => Directory.systemTemp.path;

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

ExportExpensesParams _params({
  required List<Expense> expenses,
  List<Category> categories = const [],
  int? month = 4,
  String localeCode = 'ru',
}) => ExportExpensesParams(
  expenses: expenses,
  categories: categories,
  currencySymbol: 'MDL',
  year: 2026,
  month: month,
  localeCode: localeCode,
  labels: _labelsRu,
  regularFont: _font('NotoSans-Regular.ttf'),
  boldFont: _font('NotoSans-Bold.ttf'),
);

Expense _exp(int i, {String description = 'Item', String categoryId = 'c1'}) =>
    Expense(
      id: 'e$i',
      amount: 10.0 + i,
      description: description,
      categoryId: categoryId,
      createdAt: DateTime(2026, 1 + i % 12, 1 + i % 27),
    );

final _categories = [
  Category(id: 'c1', name: 'Продукты', icon: '', createdAt: DateTime(2026)),
];

void main() {
  _setUpPaths();
  const useCase = ExportExpensesUseCase();

  group('ExportExpensesUseCase', () {
    test('renders RU labels and Cyrillic data, no EN labels', () async {
      final path = await useCase(
        _params(
          expenses: [_exp(1, description: 'Хлеб и молоко')],
          categories: _categories,
        ),
      );
      final text = extractPdfUnicodeText(File(path));
      for (final s in [
        'Отчёт о расходах',
        'Создано',
        'Записей',
        'Дата',
        'Категория',
        'Описание',
        'Сумма',
        'Итого',
        'Продукты',
        'Хлеб и молоко',
        'Апрель 2026',
      ]) {
        expect(text, contains(s));
      }
      for (final s in [
        'Date',
        'Category',
        'Description',
        'Amount',
        'Records',
        'Expense Report',
        'Generated',
      ]) {
        expect(text, isNot(contains(s)));
      }
    });

    test('uses unknown-category label for missing category', () async {
      final path = await useCase(_params(expenses: [_exp(1)]));
      expect(extractPdfUnicodeText(File(path)), contains('Неизвестно'));
    });

    test('month set gives month-named file', () async {
      final path = await useCase(_params(expenses: [_exp(1)]));
      expect(path.endsWith('/weeklet_expenses_april_2026.pdf'), isTrue);
    });

    test('month null gives year-only file name', () async {
      final path = await useCase(_params(expenses: [_exp(1)], month: null));
      expect(path.endsWith('/weeklet_expenses_2026.pdf'), isTrue);
    });

    test('whole-year export with 300 rows paginates', () async {
      final path = await useCase(
        _params(
          expenses: [for (var i = 0; i < 300; i++) _exp(i)],
          categories: _categories,
          month: null,
        ),
      );
      expect(File(path).existsSync(), isTrue);
      expect(_pageCount(path), greaterThan(1));
    });

    test('empty list with null month renders no-records with year', () async {
      final path = await useCase(_params(expenses: [], month: null));
      final text = extractPdfUnicodeText(File(path));
      expect(text, contains('Нет записей за 2026'));
    });
  });
}
