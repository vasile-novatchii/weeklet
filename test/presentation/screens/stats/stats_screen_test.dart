import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:share_plus_platform_interface/share_plus_platform_interface.dart';
import 'package:weeklet/core/utils/category_color_utils.dart';
import 'package:weeklet/core/theme/theme.dart';
import 'package:weeklet/domain/entities/settings.dart';
import 'package:weeklet/domain/entities/statistics.dart';
import 'package:weeklet/presentation/blocs/export/export_bloc.dart';
import 'package:weeklet/presentation/blocs/export/export_event.dart';
import 'package:weeklet/presentation/blocs/export/export_state.dart';
import 'package:weeklet/presentation/blocs/settings/settings_bloc.dart';
import 'package:weeklet/presentation/blocs/settings/settings_event.dart';
import 'package:weeklet/presentation/blocs/settings/settings_state.dart';
import 'package:weeklet/presentation/blocs/stats/stats_bloc.dart';
import 'package:weeklet/presentation/blocs/stats/stats_event.dart';
import 'package:weeklet/presentation/blocs/stats/stats_state.dart';
import 'package:weeklet/presentation/blocs/stats/stats_tab.dart';
import 'package:weeklet/presentation/screens/stats/stats_screen.dart';
import 'package:weeklet/presentation/screens/stats/widgets/category_details_list/category_details_item.dart';
import 'package:weeklet/presentation/screens/stats/widgets/annual_grouped_bar_chart.dart';
import 'package:weeklet/presentation/screens/stats/widgets/category_details_list/category_details_list.dart';
import 'package:weeklet/presentation/screens/stats/widgets/modern_donut_chart.dart';
import 'package:weeklet/presentation/screens/stats/widgets/stats_empty_view.dart';
import 'package:weeklet/presentation/screens/stats/widgets/stats_error_view.dart';
import 'package:weeklet/presentation/screens/stats/widgets/stats_filter_bar.dart';
import 'package:weeklet/presentation/screens/stats/widgets/stats_summary_cards/stats_summary_cards.dart';
import 'package:weeklet/presentation/screens/stats/widgets/stats_tabs_section.dart';
import '../../../helpers/fake_share_platform.dart';
import '../../../helpers/test_app.dart';
import '../../../helpers/test_data.dart';

// ---------------------------------------------------------------------------
// Mock declarations
// MockBloc<E, S> extends Bloc<E, S> — not the concrete XxxBloc subclass.
// StatsScreen and SettingsScreen are StatelessWidgets with no sl<> calls,
// so GetIt registration is omitted.
// ---------------------------------------------------------------------------

class MockStatsBloc extends MockBloc<StatsEvent, StatsState>
    implements StatsBloc {}

class MockExportBloc extends MockBloc<ExportEvent, ExportState>
    implements ExportBloc {}

class MockSettingsBloc extends MockBloc<SettingsEvent, SettingsState>
    implements SettingsBloc {}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late MockStatsBloc mockStatsBloc;
  late MockSettingsBloc mockSettingsBloc;
  late MockExportBloc mockExportBloc;
  late FakeSharePlatform fakeShare;

  setUpAll(() {
    // Use concrete subclasses as fallback values — sealed classes cannot be
    // implemented with Fake outside their defining library.
    registerFallbackValue(const LoadMonthlyStats(year: 2025));
    registerFallbackValue(const StatsInitial());
    registerFallbackValue(const LoadSettingsRequested());
    registerFallbackValue(const SettingsInitial());
    registerFallbackValue(const ResetExportRequested());
    registerFallbackValue(const ExportInitial());
  });

  setUp(() {
    mockStatsBloc = MockStatsBloc();
    mockSettingsBloc = MockSettingsBloc();
    mockExportBloc = MockExportBloc();
    fakeShare = FakeSharePlatform();
    SharePlatform.instance = fakeShare;
    when(() => mockExportBloc.state).thenReturn(const ExportInitial());
    whenListen(
      mockExportBloc,
      const Stream<ExportState>.empty(),
      initialState: const ExportInitial(),
    );

    when(() => mockStatsBloc.state).thenReturn(const StatsInitial());
    whenListen(
      mockStatsBloc,
      const Stream<StatsState>.empty(),
      initialState: const StatsInitial(),
    );

    when(() => mockSettingsBloc.state)
        .thenReturn(SettingsLoaded(settings: Settings.defaults()));
    whenListen(
      mockSettingsBloc,
      const Stream<SettingsState>.empty(),
      initialState: SettingsLoaded(settings: Settings.defaults()),
    );
  });

  tearDown(() async => GetIt.instance.reset());

  Future<void> pumpStatsScreen(WidgetTester tester) => pumpApp(
    tester,
    const StatsScreen(),
    providers: [
      BlocProvider<StatsBloc>.value(value: mockStatsBloc),
      BlocProvider<SettingsBloc>.value(value: mockSettingsBloc),
      BlocProvider<ExportBloc>.value(value: mockExportBloc),
    ],
    // AppTheme required: StatsTabsSection uses context.theme.appBarTheme
    // .backgroundColor! (with null assertion) which crashes with default theme.
    theme: AppTheme.lightTheme,
  );

  MonthlyStatsLoaded loadedWith({
    double income = 1000,
    double expenses = 500,
    int? month,
    StatsTab tab = StatsTab.monthly,
    EvolutionStats? evolution,
    List<CategoryStats> categories = const [],
    int? year,
  }) => MonthlyStatsLoaded(
    stats: MonthlyStats(
      totalIncome: income,
      totalExpenses: expenses,
      balance: income - expenses,
      incomeGrowthPercentage: 0,
      expenseGrowthPercentage: 0,
      categoryStats: categories,
    ),
    month: month,
    year: year ?? DateTime.now().year,
    currentTab: tab,
    evolutionStats: evolution,
  );

  void seed(StatsState state) {
    when(() => mockStatsBloc.state).thenReturn(state);
    whenListen(
      mockStatsBloc,
      const Stream<StatsState>.empty(),
      initialState: state,
    );
  }

  group('StatsScreen - export button visibility', () {
    const tooltip = 'Export as PDF';

    for (final entry in <String, StatsState>{
      'initial': const StatsInitial(),
      'loading': const StatsLoading(),
      'failure': const StatsFailure('x'),
    }.entries) {
      testWidgets('hidden when ${entry.key}', (tester) async {
        seed(entry.value);
        await pumpStatsScreen(tester);
        await tester.pump();

        expect(find.byIcon(Icons.picture_as_pdf), findsNothing);
      });
    }

    testWidgets('shown with tooltip when selection has data', (tester) async {
      seed(fakeMonthlyStatsLoaded());
      await pumpStatsScreen(tester);
      await tester.pump();

      expect(find.byIcon(Icons.picture_as_pdf), findsOneWidget);
      expect(find.byTooltip(tooltip), findsOneWidget);
    });

    testWidgets('hidden when income and expenses are both 0', (tester) async {
      seed(loadedWith(income: 0, expenses: 0));
      await pumpStatsScreen(tester);
      await tester.pump();

      expect(find.byIcon(Icons.picture_as_pdf), findsNothing);
    });

    testWidgets('shown for income-only selection', (tester) async {
      seed(loadedWith(income: 800, expenses: 0));
      await pumpStatsScreen(tester);
      await tester.pump();

      expect(find.byIcon(Icons.picture_as_pdf), findsOneWidget);
    });

    testWidgets('shown for expense-only selection', (tester) async {
      seed(loadedWith(income: 0, expenses: 50));
      await pumpStatsScreen(tester);
      await tester.pump();

      expect(find.byIcon(Icons.picture_as_pdf), findsOneWidget);
    });
  });

  group('StatsScreen - export dispatch', () {
    ExportStatsStarted tapAndCapture(WidgetTester tester) {
      final captured = verify(() => mockExportBloc.add(captureAny())).captured;
      expect(captured, hasLength(1));
      return captured.single as ExportStatsStarted;
    }

    testWidgets('single month dispatches filter-driven event', (tester) async {
      final cat = [
        CategoryStats(
          category: fakeCategory(id: 'cat-1', name: 'Food'),
          totalAmount: 500,
          percentage: 1,
        ),
      ];
      final loaded = loadedWith(
        month: 3,
        year: 2026,
        tab: StatsTab.annual,
        categories: cat,
      );
      seed(loaded);
      await pumpStatsScreen(tester);
      await tester.pump();

      await tester.tap(find.byIcon(Icons.picture_as_pdf));
      await tester.pump();

      final event = tapAndCapture(tester);
      expect(event.year, 2026);
      expect(event.month, 3);
      expect(event.monthRows, isEmpty);
      expect(event.currencySymbol, Settings.defaults().currencySymbol);
      expect(event.localeCode, 'en');
      expect(event.labels.reportTitle, 'Statistics Report');
      expect(event.labels.incomeLabel, 'Monthly Income');
      expect(event.stats, loaded.stats);
      expect(
        event.categoryColors['cat-1'],
        CategoryColorUtils.getColor('Food').toARGB32(),
      );
    });

    testWidgets('all months dispatches month rows from evolution', (
      tester,
    ) async {
      final year = DateTime.now().year - 1;
      final evolution = EvolutionStats(
        snapshots: [
          for (var m = 1; m <= 12; m++)
            MonthlySnapshot(
              month: m,
              year: year,
              totalIncome: m == 2 ? 100 : 0,
              totalExpenses: m == 2 ? 40 : 0,
              balance: m == 2 ? 60 : 0,
              categoryStats: const [],
            ),
        ],
      );
      seed(loadedWith(year: year, evolution: evolution));
      await pumpStatsScreen(tester);
      await tester.pump();

      await tester.tap(find.byIcon(Icons.picture_as_pdf));
      await tester.pump();

      final event = tapAndCapture(tester);
      expect(event.month, isNull);
      expect(event.monthRows, hasLength(12));
      expect(event.labels.incomeLabel, 'Annual Income');
    });

    testWidgets('all months without evolution stats gives empty rows', (
      tester,
    ) async {
      seed(loadedWith());
      await pumpStatsScreen(tester);
      await tester.pump();

      await tester.tap(find.byIcon(Icons.picture_as_pdf));
      await tester.pump();

      expect(tapAndCapture(tester).monthRows, isEmpty);
    });
  });

  group('StatsScreen - export listener', () {
    late StreamController<ExportState> controller;

    setUp(() {
      controller = StreamController<ExportState>.broadcast();
      addTearDown(controller.close);
    });

    Future<void> pumpWithStream(WidgetTester tester) async {
      seed(fakeMonthlyStatsLoaded());
      whenListen(
        mockExportBloc,
        controller.stream,
        initialState: const ExportInitial(),
      );
      await pumpStatsScreen(tester);
      await tester.pump();
    }

    Future<void> emit(WidgetTester tester, ExportState s) async {
      controller.add(s);
      await tester.pump();
      await tester.pump();
    }

    testWidgets('stats failure shows one error snackbar and resets', (
      tester,
    ) async {
      await pumpWithStream(tester);
      await emit(tester, const ExportFailure('x', exportType: ExportType.stats));

      expect(
        find.text('Failed to generate PDF. Please try again.'),
        findsOneWidget,
      );
      verify(() => mockExportBloc.add(any(that: isA<ResetExportRequested>())))
          .called(1);
    });

    testWidgets('expenses failure is ignored', (tester) async {
      await pumpWithStream(tester);
      await emit(
        tester,
        const ExportFailure('x', exportType: ExportType.expenses),
      );

      expect(
        find.text('Failed to generate PDF. Please try again.'),
        findsNothing,
      );
      verifyNever(() => mockExportBloc.add(any()));
    });

    testWidgets('stats success shares the file then resets', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      await pumpWithStream(tester);
      await emit(
        tester,
        const ExportSuccess(
          filePath: '/tmp/weeklet_stats_march_2026.pdf',
          subject: 's',
          exportType: ExportType.stats,
        ),
      );
      await tester.pump();

      expect(fakeShare.shareCalls, hasLength(1));
      expect(
        fakeShare.shareCalls.single.files!.first.path,
        endsWith('weeklet_stats_march_2026.pdf'),
      );
      verify(() => mockExportBloc.add(any(that: isA<ResetExportRequested>())))
          .called(1);
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('android success shows the share/print action sheet', (
      tester,
    ) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      await pumpWithStream(tester);
      await emit(
        tester,
        const ExportSuccess(
          filePath: '/tmp/weeklet_stats_march_2026.pdf',
          subject: 's',
          exportType: ExportType.stats,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Share'), findsOneWidget);
      expect(find.text('Print / Save as PDF'), findsOneWidget);
      expect(fakeShare.shareCalls, isEmpty);
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('income success is ignored', (tester) async {
      await pumpWithStream(tester);
      await emit(
        tester,
        const ExportSuccess(
          filePath: '/tmp/x.pdf',
          subject: 's',
          exportType: ExportType.income,
        ),
      );

      expect(fakeShare.shareCalls, isEmpty);
    });
  });

  group('StatsScreen - empty state', () {
    testWidgets('shows only filter bar and empty view', (tester) async {
      seed(loadedWith(income: 0, expenses: 0));
      await pumpStatsScreen(tester);
      await tester.pump();

      expect(find.byType(StatsEmptyView), findsOneWidget);
      expect(find.byType(StatsFilterBar), findsOneWidget);
      expect(find.byType(StatsSummaryCards), findsNothing);
      expect(find.byType(StatsTabsSection), findsNothing);
      expect(find.byType(ModernDonutChart), findsNothing);
      expect(find.byType(CategoryDetailsList), findsNothing);
      expect(find.byType(AnnualGroupedBarChart), findsNothing);
      expect(find.byIcon(Icons.picture_as_pdf), findsNothing);
    });

    testWidgets('income-only selection renders cards and tabs', (
      tester,
    ) async {
      seed(loadedWith(income: 800, expenses: 0));
      await pumpStatsScreen(tester);
      await tester.pump();

      expect(find.byType(StatsSummaryCards), findsOneWidget);
      expect(find.byType(StatsTabsSection), findsOneWidget);
      expect(find.byType(StatsFilterBar), findsOneWidget);
    });

    testWidgets('empty to non-empty selection restores cards and tabs', (
      tester,
    ) async {
      final controller = StreamController<StatsState>.broadcast();
      addTearDown(controller.close);
      final empty = loadedWith(income: 0, expenses: 0);
      when(() => mockStatsBloc.state).thenReturn(empty);
      whenListen(mockStatsBloc, controller.stream, initialState: empty);
      await pumpStatsScreen(tester);
      await tester.pump();
      expect(find.byType(StatsSummaryCards), findsNothing);

      final full = loadedWith();
      when(() => mockStatsBloc.state).thenReturn(full);
      controller.add(full);
      await tester.pump();
      await tester.pump();

      expect(find.byType(StatsSummaryCards), findsOneWidget);
      expect(find.byType(StatsTabsSection), findsOneWidget);
    });
  });

  group('StatsScreen', () {
    testWidgets(
      'shows CircularProgressIndicator when state is StatsInitial',
      (tester) async {
        await pumpStatsScreen(tester);
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      },
    );

    testWidgets(
      'shows CircularProgressIndicator when state is StatsLoading',
      (tester) async {
        when(() => mockStatsBloc.state).thenReturn(const StatsLoading());
        whenListen(
          mockStatsBloc,
          const Stream<StatsState>.empty(),
          initialState: const StatsLoading(),
        );

        await pumpStatsScreen(tester);
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      },
    );

    testWidgets(
      'renders CustomScrollView when MonthlyStatsLoaded',
      (tester) async {
        when(() => mockStatsBloc.state).thenReturn(fakeMonthlyStatsLoaded());
        whenListen(
          mockStatsBloc,
          const Stream<StatsState>.empty(),
          initialState: fakeMonthlyStatsLoaded(),
        );

        await pumpStatsScreen(tester);
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(find.byType(CustomScrollView), findsOneWidget);
      },
    );

    testWidgets(
      'shows error content when state is StatsFailure',
      (tester) async {
        const errorMessage = 'Failed to load stats';
        when(() => mockStatsBloc.state)
            .thenReturn(const StatsFailure(errorMessage));
        whenListen(
          mockStatsBloc,
          const Stream<StatsState>.empty(),
          initialState: const StatsFailure(errorMessage),
        );

        await pumpStatsScreen(tester);
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(find.byType(CustomScrollView), findsNothing);
        expect(find.byType(StatsErrorView), findsOneWidget);
      },
    );
  });

  // ---------------------------------------------------------------------------
  // STATS-04: a category with real spending must never vanish from the donut
  // or from the category details list. The fixture mirrors the e2e acceptance
  // example - a 23 MDL category inside an ~8570 MDL year (~0.27%).
  // ---------------------------------------------------------------------------

  group('StatsScreen - STATS-04 small category visibility', () {
    const totalExpenses = 8570.8;
    const bigAmount = 8547.8;
    const tinyAmount = 23.0;
    const bigPercentage = bigAmount / totalExpenses;
    const tinyPercentage = tinyAmount / totalExpenses;

    final bigStat = CategoryStats(
      category: fakeCategory(id: 'cat-big', name: 'Food'),
      totalAmount: bigAmount,
      percentage: bigPercentage,
    );
    final tinyStat = CategoryStats(
      category: fakeCategory(id: 'cat-tiny', name: 'Transport'),
      totalAmount: tinyAmount,
      percentage: tinyPercentage,
    );

    void seedLoaded(
      List<CategoryStats> categoryStats, {
      int touchedIndex = -1,
    }) {
      final state = MonthlyStatsLoaded(
        stats: MonthlyStats(
          totalIncome: 10000.0,
          totalExpenses: totalExpenses,
          balance: 10000.0 - totalExpenses,
          incomeGrowthPercentage: 0.0,
          expenseGrowthPercentage: 0.0,
          categoryStats: categoryStats,
        ),
        year: DateTime.now().year,
        touchedIndex: touchedIndex,
      );

      when(() => mockStatsBloc.state).thenReturn(state);
      whenListen(
        mockStatsBloc,
        const Stream<StatsState>.empty(),
        initialState: state,
      );
    }

    List<PieChartSectionData> donutSections(WidgetTester tester) =>
        tester.widget<PieChart>(find.byType(PieChart)).data.sections;

    List<LinearProgressIndicator> progressBars(WidgetTester tester) => tester
        .widgetList<LinearProgressIndicator>(
          find.descendant(
            of: find.byType(CategoryDetailsItem),
            matching: find.byType(LinearProgressIndicator),
          ),
        )
        .toList();

    testWidgets(
      'renders one donut section per category with spending',
      (tester) async {
        seedLoaded([bigStat, tinyStat]);

        await pumpStatsScreen(tester);
        await tester.pump();

        expect(donutSections(tester), hasLength(2));
      },
    );

    testWidgets(
      'floors a sub-1% slice at a 3% display share, leaving others exact',
      (tester) async {
        seedLoaded([bigStat, tinyStat]);

        await pumpStatsScreen(tester);
        await tester.pump();

        final sections = donutSections(tester);

        // The 0.27% slice is lifted to the locked 3% minimum display share so
        // fl_chart draws a wedge wide enough to see and tap.
        expect(sections[1].value, greaterThanOrEqualTo(totalExpenses * 0.03));
        // The clamp is a floor, not a rewrite - the big slice keeps its exact
        // amount.
        expect(sections[0].value, closeTo(bigAmount, 0.001));
      },
    );

    testWidgets(
      'shows a <1% badge, never 0%, for a touched sub-1% slice',
      (tester) async {
        seedLoaded([bigStat, tinyStat], touchedIndex: 1);

        await pumpStatsScreen(tester);
        await tester.pump();

        expect(find.text('<1%'), findsOneWidget);
        expect(find.text('0%'), findsNothing);
      },
    );

    testWidgets(
      'floors the progress bar fill so every category shows a sliver',
      (tester) async {
        seedLoaded([bigStat, tinyStat]);

        await pumpStatsScreen(tester);
        await tester.pump();

        final bars = progressBars(tester);

        expect(bars, hasLength(2));
        expect(bars[0].value, closeTo(bigPercentage, 0.0001));
        expect(bars[1].value, greaterThanOrEqualTo(0.02));
      },
    );

    testWidgets(
      'keeps the progress bar empty for a zero-spend category',
      (tester) async {
        final zeroStat = CategoryStats(
          category: fakeCategory(id: 'cat-zero', name: 'Utilities'),
          totalAmount: 0.0,
          percentage: 0.0,
        );
        seedLoaded([bigStat, zeroStat]);

        await pumpStatsScreen(tester);
        await tester.pump();

        expect(progressBars(tester)[1].value, 0.0);
      },
    );
  });
}
