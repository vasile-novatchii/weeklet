import 'package:bloc_test/bloc_test.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
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
import 'package:weeklet/presentation/screens/stats/widgets/stats_error_view.dart';
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
