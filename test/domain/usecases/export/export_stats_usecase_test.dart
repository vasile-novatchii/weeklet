import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:weeklet/domain/entities/statistics.dart';
import 'package:weeklet/domain/usecases/export/export_stats_usecase.dart';
import 'package:weeklet/domain/usecases/export/stats_pdf_labels.dart';

import '../../../helpers/pdf_unicode_text_extractor.dart';
import '../../../helpers/test_data.dart';

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

StatsPdfLabels _labelsEn() => const StatsPdfLabels(
  reportTitle: 'Statistics Report',
  generatedLabel: 'Generated',
  incomeLabel: 'Income',
  expensesLabel: 'Expenses',
  balanceLabel: 'Balance',
  vsLastMonthLabel: 'vs last month',
  categoryBreakdownTitle: 'Expenses by Category',
  columnCategory: 'Category',
  columnAmount: 'Amount',
  columnShare: 'Share',
  monthBreakdownTitle: 'Monthly Breakdown',
  columnMonth: 'Month',
  columnIncome: 'Income',
  columnExpenses: 'Expenses',
  columnBalance: 'Balance',
  totalLabel: 'Total',
  noExpensesLabel: 'No expenses for this period',
);

StatsPdfLabels _labelsRu() => const StatsPdfLabels(
  reportTitle: 'Статистический отчёт',
  generatedLabel: 'Создано',
  incomeLabel: 'Доходы',
  expensesLabel: 'Расходы',
  balanceLabel: 'Баланс',
  vsLastMonthLabel: 'к прошлому месяцу',
  categoryBreakdownTitle: 'Расходы по категориям',
  columnCategory: 'Категория',
  columnAmount: 'Сумма',
  columnShare: 'Доля',
  monthBreakdownTitle: 'Помесячная разбивка',
  columnMonth: 'Месяц',
  columnIncome: 'Доходы',
  columnExpenses: 'Расходы',
  columnBalance: 'Баланс',
  totalLabel: 'Итого',
  noExpensesLabel: 'Нет расходов за этот период',
);

StatsPdfLabels _labelsRo() => const StatsPdfLabels(
  reportTitle: 'Raport statistic',
  generatedLabel: 'Generat',
  incomeLabel: 'Venituri',
  expensesLabel: 'Cheltuieli',
  balanceLabel: 'Sold',
  vsLastMonthLabel: 'față de luna trecută',
  categoryBreakdownTitle: 'Cheltuieli pe categorii',
  columnCategory: 'Categorie',
  columnAmount: 'Sumă',
  columnShare: 'Pondere',
  monthBreakdownTitle: 'Defalcare lunară',
  columnMonth: 'Luna',
  columnIncome: 'Venituri',
  columnExpenses: 'Cheltuieli',
  columnBalance: 'Sold',
  totalLabel: 'Total',
  noExpensesLabel: 'Nicio cheltuială în această perioadă',
);

ByteData _font(String name) =>
    ByteData.sublistView(File('assets/fonts/$name').readAsBytesSync());

ExportStatsParams _params({
  required MonthlyStats stats,
  required StatsPdfLabels labels,
  List<MonthlySnapshot> monthRows = const [],
  int year = 2026,
  int? month = 3,
  String localeCode = 'en',
}) => ExportStatsParams(
  stats: stats,
  monthRows: monthRows,
  year: year,
  month: month,
  currencySymbol: 'MDL',
  localeCode: localeCode,
  labels: labels,
  categoryColors: const {'cat-1': 0xFF16A34A, 'cat-2': 0xFF1447E6},
  regularFont: _font('NotoSans-Regular.ttf'),
  boldFont: _font('NotoSans-Bold.ttf'),
  generatedAt: DateTime(2026, 3, 5),
);

MonthlyStats _monthStats({
  String food = 'Food',
  String transport = 'Transport',
}) => MonthlyStats(
  totalIncome: 1234.5,
  totalExpenses: 1734.5,
  balance: -500,
  incomeGrowthPercentage: 0.12,
  expenseGrowthPercentage: -0.05,
  categoryStats: [
    CategoryStats(
      category: fakeCategory(name: food),
      totalAmount: 1000,
      percentage: 0.5766,
    ),
    CategoryStats(
      category: fakeCategory(id: 'cat-2', name: transport),
      totalAmount: 734.5,
      percentage: 0.4234,
    ),
  ],
);

MonthlySnapshot _snap(int month, double income, double expenses) =>
    MonthlySnapshot(
      month: month,
      year: 2025,
      totalIncome: income,
      totalExpenses: expenses,
      balance: income - expenses,
      categoryStats: const [],
    );

final _zeroAmount = RegExp(r'(?<![\d,])0\.00 MDL');

void main() {
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

  group('ExportStatsUseCase single month', () {
    const useCase = ExportStatsUseCase();

    test('writes weeklet_stats_march_2026.pdf', () async {
      final path = await useCase(
        _params(stats: _monthStats(), labels: _labelsEn()),
      );
      expect(path.endsWith('/weeklet_stats_march_2026.pdf'), isTrue);
      expect(File(path).existsSync(), isTrue);
    });

    test('embeds NotoSans and no Helvetica', () async {
      final path = await useCase(
        _params(stats: _monthStats(), labels: _labelsEn()),
      );
      final raw = latin1.decode(File(path).readAsBytesSync());
      expect(raw.contains('NotoSans'), isTrue);
      expect(raw.contains('/Helvetica'), isFalse);
    });

    test('renders summary, growth and category table', () async {
      final path = await useCase(
        _params(stats: _monthStats(), labels: _labelsEn()),
      );
      final text = extractPdfUnicodeText(File(path));
      for (final s in [
        'Weeklet',
        'Statistics Report',
        'March 2026',
        'Generated',
        '5 March 2026',
        '1,234.50 MDL',
        '-500.00 MDL',
        '+12.0%',
        '-5.0%',
        'vs last month',
        'Food',
        'Transport',
        '57.7%',
        'Total',
        '1,734.50 MDL',
      ]) {
        expect(text, contains(s));
      }
      expect(text, isNot(contains('Monthly Breakdown')));
    });

    test('renders Russian text and capitalized month', () async {
      final path = await useCase(
        _params(
          stats: _monthStats(food: 'Продукты'),
          labels: _labelsRu(),
          localeCode: 'ru',
        ),
      );
      final text = extractPdfUnicodeText(File(path));
      expect(text, contains('Продукты'));
      expect(text, contains('Март'));
      expect(text, contains('Статистический отчёт'));
    });

    test('renders Romanian diacritics and capitalized month', () async {
      final path = await useCase(
        _params(
          stats: _monthStats(food: 'Ședință țară'),
          labels: _labelsRo(),
          localeCode: 'ro',
        ),
      );
      final text = extractPdfUnicodeText(File(path));
      expect(text, contains('Ședință'));
      expect(text, contains('Martie'));
    });

    test('income-only selection exports with no-expenses row', () async {
      final path = await useCase(
        _params(
          stats: const MonthlyStats(
            totalIncome: 800,
            totalExpenses: 0,
            balance: 800,
            incomeGrowthPercentage: 0,
            expenseGrowthPercentage: 0,
            categoryStats: [],
          ),
          labels: _labelsEn(),
        ),
      );
      final text = extractPdfUnicodeText(File(path));
      expect(text, contains('No expenses for this period'));
      expect(text, contains('800.00 MDL'));
      expect(_zeroAmount.allMatches(text).length, greaterThanOrEqualTo(1));
    });
  });

  group('ExportStatsUseCase all months', () {
    const useCase = ExportStatsUseCase();

    final rows = [
      _snap(1, 1000, 400),
      _snap(2, 0, 600),
      for (var m = 3; m <= 12; m++) _snap(m, 0, 0),
    ];
    final stats = MonthlyStats(
      totalIncome: 1000,
      totalExpenses: 1000,
      balance: 0,
      incomeGrowthPercentage: 0.5,
      expenseGrowthPercentage: 0.5,
      categoryStats: [
        CategoryStats(
          category: fakeCategory(),
          totalAmount: 700,
          percentage: 0.7,
        ),
        CategoryStats(
          category: fakeCategory(id: 'cat-2', name: 'Transport'),
          totalAmount: 300,
          percentage: 0.3,
        ),
      ],
    );

    Future<String> run({
      StatsPdfLabels? labels,
      String localeCode = 'en',
    }) => useCase(
      _params(
        stats: stats,
        labels: labels ?? _labelsEn(),
        monthRows: rows,
        year: 2025,
        month: null,
        localeCode: localeCode,
      ),
    );

    test('writes weeklet_stats_2025.pdf', () async {
      final path = await run();
      expect(path.endsWith('/weeklet_stats_2025.pdf'), isTrue);
    });

    test('renders month table with zero rows and signed balances', () async {
      final text = extractPdfUnicodeText(File(await run()));
      for (final s in [
        '2025',
        'Monthly Breakdown',
        'Month',
        'Balance',
        'January',
        'February',
        'December',
        '-600.00 MDL',
      ]) {
        expect(text, contains(s));
      }
      expect(text, isNot(contains('vs last month')));
      expect(_zeroAmount.allMatches(text).length, greaterThanOrEqualTo(30));
    });

    test('shows totals bars', () async {
      final text = extractPdfUnicodeText(File(await run()));
      expect(
        RegExp(RegExp.escape('1,000.00 MDL')).allMatches(text).length,
        6,
      );
    });

    test('renders Russian month names', () async {
      final text = extractPdfUnicodeText(
        File(await run(labels: _labelsRu(), localeCode: 'ru')),
      );
      expect(text, contains('Январь'));
    });
  });

  group('ExportStatsUseCase localization audit', () {
    const useCase = ExportStatsUseCase();

    // 'Total' is also the correct Romanian word, so it is only asserted
    // absent for Russian.
    const enStrings = [
      'Statistics Report',
      'Generated',
      'Expenses by Category',
      'Category',
      'Amount',
      'Share',
      'Balance',
      'Income',
      'Expenses',
      'Monthly Breakdown',
      'Month',
      'vs last month',
      'No expenses for this period',
      'March',
      'January',
    ];

    final rows = [
      _snap(1, 1000, 400),
      for (var m = 2; m <= 12; m++) _snap(m, 0, 0),
    ];

    for (final entry in {
      'ro': (_labelsRo(), 'Raport statistic', 'Martie', 'Ianuarie'),
      'ru': (_labelsRu(), 'Статистический отчёт', 'Март', 'Январь'),
    }.entries) {
      final (labels, title, singleMonth, allMonth) = entry.value;
      final extra = entry.key == 'ru' ? ['Total'] : <String>[];

      test('${entry.key} single-month PDF has no English labels', () async {
        final path = await useCase(
          _params(
            stats: _monthStats(food: 'Produse', transport: 'Transp'),
            labels: labels,
            localeCode: entry.key,
          ),
        );
        final text = extractPdfUnicodeText(File(path));
        expect(text, contains(title));
        expect(text, contains(singleMonth));
        for (final en in [...enStrings, ...extra]) {
          expect(text, isNot(contains(en)), reason: en);
        }
      });

      test('${entry.key} all-months PDF has no English labels', () async {
        final path = await useCase(
          _params(
            stats: _monthStats(food: 'Produse', transport: 'Transp'),
            labels: labels,
            monthRows: rows,
            year: 2025,
            month: null,
            localeCode: entry.key,
          ),
        );
        final text = extractPdfUnicodeText(File(path));
        expect(text, contains(title));
        expect(text, contains(allMonth));
        for (final en in [...enStrings, ...extra]) {
          expect(text, isNot(contains(en)), reason: en);
        }
      });
    }
  });
}
