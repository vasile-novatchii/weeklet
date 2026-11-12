import 'dart:typed_data';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:weeklet/domain/entities/category.dart';
import 'package:weeklet/domain/entities/expense.dart';
import 'package:weeklet/core/utils/pdf_font_loader.dart';
import 'package:weeklet/domain/entities/income.dart';
import 'package:weeklet/domain/entities/statistics.dart';
import 'package:weeklet/domain/usecases/export/export_expenses_usecase.dart';
import 'package:weeklet/domain/usecases/export/export_income_usecase.dart';
import 'package:weeklet/domain/usecases/export/export_stats_usecase.dart';
import 'package:weeklet/domain/usecases/export/stats_pdf_labels.dart';
import 'package:weeklet/domain/usecases/export/transaction_pdf_labels.dart';
import 'package:weeklet/presentation/blocs/export/export_bloc.dart';
import 'package:weeklet/presentation/blocs/export/export_event.dart';
import 'package:weeklet/presentation/blocs/export/export_state.dart';

// Stub use cases — no PDF generation, no filesystem access.
// Subclass the concrete use cases so they satisfy typed constructor parameters.
class _StubExportExpensesUseCase extends ExportExpensesUseCase {
  _StubExportExpensesUseCase({this.shouldThrow = false});

  final bool shouldThrow;
  ExportExpensesParams? lastParams;

  @override
  Future<String> call(ExportExpensesParams params) async {
    lastParams = params;
    if (shouldThrow) throw Exception('export failed');
    return '/tmp/weeklet_expenses_january_2024.pdf';
  }
}

class _StubExportIncomeUseCase extends ExportIncomeUseCase {
  _StubExportIncomeUseCase({this.shouldThrow = false});

  final bool shouldThrow;
  ExportIncomeParams? lastParams;

  @override
  Future<String> call(ExportIncomeParams params) async {
    lastParams = params;
    if (shouldThrow) throw Exception('export failed');
    return '/tmp/weeklet_income_january_2024.pdf';
  }
}

class _StubExportStatsUseCase extends ExportStatsUseCase {
  _StubExportStatsUseCase({this.shouldThrow = false});

  final bool shouldThrow;
  ExportStatsParams? lastParams;
  int callCount = 0;

  @override
  Future<String> call(ExportStatsParams params) async {
    lastParams = params;
    callCount++;
    if (shouldThrow) throw Exception('export failed');
    return params.month == null
        ? '/tmp/weeklet_stats_2025.pdf'
        : '/tmp/weeklet_stats_march_2026.pdf';
  }
}

class _StubPdfFontLoader extends PdfFontLoader {
  _StubPdfFontLoader({this.shouldThrow = false});

  final bool shouldThrow;
  final ByteData regular = ByteData(4);
  final ByteData bold = ByteData(4);

  @override
  Future<({ByteData regular, ByteData bold})> load() async {
    if (shouldThrow) throw Exception('font load failed');
    return (regular: regular, bold: bold);
  }
}

StatsPdfLabels _labelsEn() => const StatsPdfLabels(
  reportTitle: 'Statistics Report',
  generatedLabel: 'Generated',
  incomeLabel: 'Income',
  expensesLabel: 'Expenses',
  balanceLabel: 'Balance',
  vsLastMonthLabel: 'vs last month',
  categoryBreakdownTitle: 'Category breakdown',
  columnCategory: 'Category',
  columnAmount: 'Amount',
  columnShare: 'Share',
  monthBreakdownTitle: 'Monthly breakdown',
  columnMonth: 'Month',
  columnIncome: 'Income',
  columnExpenses: 'Expenses',
  columnBalance: 'Balance',
  totalLabel: 'Total',
  noExpensesLabel: 'No expenses',
);

const _txLabels = TransactionPdfLabels(
  reportTitleExpenses: 'Expense Report',
  reportTitleIncome: 'Income Report',
  generatedLabel: 'Generated',
  recordsLabel: 'Records',
  totalLabel: 'Total',
  columnDate: 'Date',
  columnCategory: 'Category',
  columnDescription: 'Description',
  columnAmount: 'Amount',
  noRecordsLabel: 'No records for',
  unknownCategoryLabel: 'Unknown',
);

const _fakeStats = MonthlyStats(
  totalIncome: 100,
  totalExpenses: 40,
  balance: 60,
  incomeGrowthPercentage: 0,
  expenseGrowthPercentage: 0,
  categoryStats: [],
);

ExportStatsStarted _statsEvent({int? month, int year = 2026}) =>
    ExportStatsStarted(
      stats: _fakeStats,
      monthRows: const [],
      year: year,
      month: month,
      currencySymbol: r'$',
      localeCode: 'en',
      labels: _labelsEn(),
      categoryColors: const {},
    );

// Shared fixtures
final _fakeExpenses = <Expense>[
  Expense(
    id: 'e-1',
    amount: 50.0,
    description: 'Groceries',
    categoryId: 'cat-1',
    createdAt: DateTime(2024, 1, 10),
  ),
];

final _fakeCategories = <Category>[
  Category(
    id: 'cat-1',
    name: 'Food',
    icon: '🍎',
    createdAt: DateTime(2024, 1, 1),
  ),
];

final _fakeIncomes = <Income>[
  Income(
    id: 'i-1',
    amount: 2000.0,
    description: 'Salary',
    date: DateTime(2024, 1, 5),
    createdAt: DateTime(2024, 1, 5),
  ),
];

ExportBloc _makeBloc({
  bool expensesThrows = false,
  bool incomeThrows = false,
  bool statsThrows = false,
  bool fontsThrow = false,
  _StubExportStatsUseCase? statsStub,
  _StubExportExpensesUseCase? expensesStub,
  _StubExportIncomeUseCase? incomeStub,
  _StubPdfFontLoader? loader,
}) => ExportBloc(
  exportExpensesUseCase:
      expensesStub ?? _StubExportExpensesUseCase(shouldThrow: expensesThrows),
  exportIncomeUseCase:
      incomeStub ?? _StubExportIncomeUseCase(shouldThrow: incomeThrows),
  exportStatsUseCase:
      statsStub ?? _StubExportStatsUseCase(shouldThrow: statsThrows),
  fontLoader: loader ?? _StubPdfFontLoader(shouldThrow: fontsThrow),
);

void main() {
  setUpAll(() async {
    // ExportBloc uses DateFormat.yMMMM('en') to build the subject string.
    // intl locale data must be initialized before tests run.
    await initializeDateFormatting('en');
  });

  group('ExportBloc', () {
    test('initial state is ExportInitial', () {
      final bloc = _makeBloc();
      expect(bloc.state, const ExportInitial());
      bloc.close();
    });

    blocTest<ExportBloc, ExportState>(
      'ExportExpensesStarted success emits [ExportInProgress, ExportSuccess]'
      ' with correct filePath, exportType and subject',
      build: _makeBloc,
      act: (bloc) => bloc.add(
        ExportExpensesStarted(
          expenses: _fakeExpenses,
          categories: _fakeCategories,
          currencySymbol: r'$',
          year: 2024,
          month: 1,
          localeCode: 'en',
          labels: _txLabels,
        ),
      ),
      expect: () => [
        const ExportInProgress(),
        isA<ExportSuccess>()
            .having(
              (s) => s.filePath,
              'filePath',
              contains('weeklet_expenses'),
            )
            .having(
              (s) => s.exportType,
              'exportType',
              ExportType.expenses,
            )
            .having(
              (s) => s.subject,
              'subject',
              contains('Weeklet'),
            ),
      ],
    );

    blocTest<ExportBloc, ExportState>(
      'ExportExpensesStarted failure emits [ExportInProgress, ExportFailure]',
      build: () => _makeBloc(expensesThrows: true),
      act: (bloc) => bloc.add(
        ExportExpensesStarted(
          expenses: _fakeExpenses,
          categories: _fakeCategories,
          currencySymbol: r'$',
          year: 2024,
          month: 1,
          localeCode: 'en',
          labels: _txLabels,
        ),
      ),
      expect: () => [
        const ExportInProgress(),
        isA<ExportFailure>().having(
          (s) => s.exportType,
          'exportType',
          ExportType.expenses,
        ),
      ],
    );

    blocTest<ExportBloc, ExportState>(
      'ExportIncomeStarted success emits [ExportInProgress, ExportSuccess]'
      ' with exportType == income',
      build: _makeBloc,
      act: (bloc) => bloc.add(
        ExportIncomeStarted(
          incomes: _fakeIncomes,
          currencySymbol: r'$',
          year: 2024,
          month: 1,
          localeCode: 'en',
          labels: _txLabels,
        ),
      ),
      expect: () => [
        const ExportInProgress(),
        isA<ExportSuccess>()
            .having(
              (s) => s.exportType,
              'exportType',
              ExportType.income,
            )
            .having(
              (s) => s.subject,
              'subject',
              contains('Weeklet'),
            ),
      ],
    );

    blocTest<ExportBloc, ExportState>(
      'ExportIncomeStarted failure emits [ExportInProgress, ExportFailure]',
      build: () => _makeBloc(incomeThrows: true),
      act: (bloc) => bloc.add(
        ExportIncomeStarted(
          incomes: _fakeIncomes,
          currencySymbol: r'$',
          year: 2024,
          month: 1,
          localeCode: 'en',
          labels: _txLabels,
        ),
      ),
      expect: () => [
        const ExportInProgress(),
        isA<ExportFailure>().having(
          (s) => s.exportType,
          'exportType',
          ExportType.income,
        ),
      ],
    );

    blocTest<ExportBloc, ExportState>(
      'ExportStatsStarted month success emits stats ExportSuccess',
      build: _makeBloc,
      act: (bloc) => bloc.add(_statsEvent(month: 3)),
      expect: () => [
        const ExportInProgress(),
        const ExportSuccess(
          filePath: '/tmp/weeklet_stats_march_2026.pdf',
          subject: 'Weeklet Statistics Report - March 2026',
          exportType: ExportType.stats,
        ),
      ],
    );

    test('ExportStatsStarted all months passes null month and fonts', () async {
      final stub = _StubExportStatsUseCase();
      final loader = _StubPdfFontLoader();
      final bloc = _makeBloc(statsStub: stub, loader: loader);
      bloc.add(_statsEvent(year: 2025));
      await bloc.stream.firstWhere((s) => s is ExportSuccess).then((s) {
        expect(
          (s as ExportSuccess).subject,
          'Weeklet Statistics Report - 2025',
        );
      });
      expect(stub.lastParams!.month, isNull);
      expect(stub.lastParams!.monthRows, isEmpty);
      expect(identical(stub.lastParams!.regularFont, loader.regular), isTrue);
      expect(identical(stub.lastParams!.boldFont, loader.bold), isTrue);
      await bloc.close();
    });

    blocTest<ExportBloc, ExportState>(
      'ExportStatsStarted use case failure emits stats ExportFailure',
      build: () => _makeBloc(statsThrows: true),
      act: (bloc) => bloc.add(_statsEvent(month: 3)),
      expect: () => [
        const ExportInProgress(),
        isA<ExportFailure>().having(
          (s) => s.exportType,
          'exportType',
          ExportType.stats,
        ),
      ],
    );

    test(
      'ExportStatsStarted font failure emits failure, use case skipped',
      () async {
        final stub = _StubExportStatsUseCase();
        final bloc = _makeBloc(statsStub: stub, fontsThrow: true);
        bloc.add(_statsEvent(month: 3));
        final s = await bloc.stream.firstWhere((s) => s is ExportFailure);
        expect((s as ExportFailure).exportType, ExportType.stats);
        expect(stub.lastParams, isNull);
        await bloc.close();
      },
    );

    test(
      'ExportExpensesStarted null month: year-only subject, fonts forwarded',
      () async {
        final stub = _StubExportExpensesUseCase();
        final loader = _StubPdfFontLoader();
        final bloc = _makeBloc(expensesStub: stub, loader: loader);
        bloc.add(
          ExportExpensesStarted(
            expenses: _fakeExpenses,
            categories: _fakeCategories,
            currencySymbol: r'$',
            year: 2024,
            localeCode: 'en',
            labels: _txLabels,
          ),
        );
        final s = await bloc.stream.firstWhere((s) => s is ExportSuccess);
        expect(
          (s as ExportSuccess).subject,
          'Weeklet Expense Report - 2024',
        );
        expect(s.exportType, ExportType.expenses);
        expect(stub.lastParams!.month, isNull);
        expect(stub.lastParams!.labels, _txLabels);
        expect(identical(stub.lastParams!.regularFont, loader.regular), isTrue);
        expect(identical(stub.lastParams!.boldFont, loader.bold), isTrue);
        await bloc.close();
      },
    );

    test(
      'ExportIncomeStarted null month: year-only subject, fonts forwarded',
      () async {
        final stub = _StubExportIncomeUseCase();
        final loader = _StubPdfFontLoader();
        final bloc = _makeBloc(incomeStub: stub, loader: loader);
        bloc.add(
          ExportIncomeStarted(
            incomes: _fakeIncomes,
            currencySymbol: r'$',
            year: 2024,
            localeCode: 'en',
            labels: _txLabels,
          ),
        );
        final s = await bloc.stream.firstWhere((s) => s is ExportSuccess);
        expect((s as ExportSuccess).subject, 'Weeklet Income Report - 2024');
        expect(s.exportType, ExportType.income);
        expect(stub.lastParams!.month, isNull);
        expect(identical(stub.lastParams!.regularFont, loader.regular), isTrue);
        expect(identical(stub.lastParams!.boldFont, loader.bold), isTrue);
        await bloc.close();
      },
    );

    blocTest<ExportBloc, ExportState>(
      'ResetExportRequested from ExportSuccess seed emits [ExportInitial]',
      build: _makeBloc,
      seed: () => const ExportSuccess(
        filePath: '/tmp/test.pdf',
        subject: 'Weeklet Expense Report - January 2024',
        exportType: ExportType.expenses,
      ),
      act: (bloc) => bloc.add(const ResetExportRequested()),
      expect: () => [const ExportInitial()],
    );
  });

  group('ExportBloc in-progress guard', () {
    test('second export while one is running is ignored', () async {
      final stub = _StubExportStatsUseCase();
      final bloc = _makeBloc(statsStub: stub);
      final states = <ExportState>[];
      final sub = bloc.stream.listen(states.add);

      bloc
        ..add(_statsEvent(month: 3))
        ..add(_statsEvent(month: 3));
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(stub.callCount, 1);
      expect(states.whereType<ExportInProgress>(), hasLength(1));
      expect(states.whereType<ExportSuccess>(), hasLength(1));
      await sub.cancel();
      await bloc.close();
    });
  });
}
