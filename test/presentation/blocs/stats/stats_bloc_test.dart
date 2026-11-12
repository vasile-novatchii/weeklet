import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weeklet/domain/entities/statistics.dart';
import 'package:weeklet/domain/repositories/statistics_repository.dart';
import 'package:weeklet/domain/usecases/stats/get_available_periods_use_case.dart';
import 'package:weeklet/domain/usecases/stats/get_evolution_stats_use_case.dart';
import 'package:weeklet/domain/usecases/stats/get_monthly_stats_use_case.dart';
import 'package:weeklet/presentation/blocs/stats/stats_bloc.dart';
import 'package:weeklet/presentation/blocs/stats/stats_event.dart';
import 'package:weeklet/presentation/blocs/stats/stats_state.dart';
import 'package:weeklet/presentation/blocs/stats/stats_tab.dart';

// Configurable in-memory stub repository
class _StubStatisticsRepository implements StatisticsRepository {
  _StubStatisticsRepository({
    this.shouldThrow = false,
    MonthlyStats? monthlyStats,
    EvolutionStats? evolutionStats,
    Map<int, List<int>>? availablePeriods,
  }) : _monthlyStats = monthlyStats ?? _fakeMonthlyStats(),
       _evolutionStats = evolutionStats ?? _fakeEvolutionStats(),
       _availablePeriods = availablePeriods ?? {2024: [1, 2, 3]};

  final bool shouldThrow;
  final MonthlyStats _monthlyStats;
  final EvolutionStats _evolutionStats;
  final Map<int, List<int>> _availablePeriods;

  @override
  Future<MonthlyStats> getMonthlyStats(int? month, int year) async {
    if (shouldThrow) throw Exception('stats failed');
    return _monthlyStats;
  }

  @override
  Future<EvolutionStats> getEvolutionStats(int year) async {
    if (shouldThrow) throw Exception('evolution failed');
    return _evolutionStats;
  }

  @override
  Future<Map<int, List<int>>> getAvailablePeriods() async {
    if (shouldThrow) throw Exception('periods failed');
    return _availablePeriods;
  }
}

MonthlyStats _fakeMonthlyStats() => const MonthlyStats(
  totalIncome: 1000.0,
  totalExpenses: 500.0,
  balance: 500.0,
  incomeGrowthPercentage: 0.1,
  expenseGrowthPercentage: -0.05,
  categoryStats: [],
);

EvolutionStats _fakeEvolutionStats() => const EvolutionStats(snapshots: []);

StatsBloc _makeBloc(_StubStatisticsRepository repo) => StatsBloc(
  getMonthlyStatsUseCase: GetMonthlyStatsUseCase(repo),
  getEvolutionStatsUseCase: GetEvolutionStatsUseCase(repo),
  getAvailablePeriodsUseCase: GetAvailablePeriodsUseCase(repo),
);

// Pre-built seeded MonthlyStatsLoaded state
MonthlyStatsLoaded _fakeLoadedState() => MonthlyStatsLoaded(
  stats: _fakeMonthlyStats(),
  month: 3,
  year: 2024,
  availablePeriods: const {2024: [1, 2, 3]},
  evolutionStats: _fakeEvolutionStats(),
);

void main() {
  group('StatsBloc', () {
    test('initial state is StatsInitial', () {
      final bloc = _makeBloc(_StubStatisticsRepository());
      expect(bloc.state, const StatsInitial());
      bloc.close();
    });

    // ------------------------------------------------------------------
    // LoadMonthlyStats from StatsInitial (initial load)
    // ------------------------------------------------------------------
    blocTest<StatsBloc, StatsState>(
      'LoadMonthlyStats from StatsInitial emits [StatsLoading, MonthlyStatsLoaded]',
      build: () => _makeBloc(_StubStatisticsRepository()),
      act: (bloc) => bloc.add(const LoadMonthlyStats(year: 2024, month: 3)),
      expect: () => [
        const StatsLoading(),
        isA<MonthlyStatsLoaded>(),
      ],
    );

    blocTest<StatsBloc, StatsState>(
      'LoadMonthlyStats failure from StatsInitial emits '
          '[StatsLoading, StatsFailure]',
      build: () => _makeBloc(_StubStatisticsRepository(shouldThrow: true)),
      act: (bloc) => bloc.add(const LoadMonthlyStats(year: 2024, month: 3)),
      expect: () => [
        const StatsLoading(),
        isA<StatsFailure>(),
      ],
    );

    // ------------------------------------------------------------------
    // LoadMonthlyStats from seeded MonthlyStatsLoaded (no-flicker reload)
    // ------------------------------------------------------------------
    blocTest<StatsBloc, StatsState>(
      'LoadMonthlyStats from seeded MonthlyStatsLoaded emits '
          '[MonthlyStatsLoaded] WITHOUT StatsLoading (no-flicker) '
          'and resets touchedIndex to -1',
      build: () => _makeBloc(_StubStatisticsRepository()),
      // Seed with touchedIndex = 2 so the copyWith(touchedIndex: -1) produces
      // a state that differs from seed — guaranteeing a real emit occurs.
      seed: () => _fakeLoadedState().copyWith(touchedIndex: 2),
      act: (bloc) => bloc.add(const LoadMonthlyStats(year: 2024, month: 3)),
      expect: () => [
        isA<MonthlyStatsLoaded>().having(
          (s) => s.touchedIndex,
          'touchedIndex',
          -1,
        ),
      ],
    );

    // ------------------------------------------------------------------
    // ChangeStatsTab
    // ------------------------------------------------------------------
    blocTest<StatsBloc, StatsState>(
      'ChangeStatsTab from seeded MonthlyStatsLoaded emits '
          '[MonthlyStatsLoaded] with updated currentTab',
      build: () => _makeBloc(_StubStatisticsRepository()),
      seed: _fakeLoadedState,
      act: (bloc) => bloc.add(const ChangeStatsTab(StatsTab.annual)),
      expect: () => [
        isA<MonthlyStatsLoaded>().having(
          (s) => s.currentTab,
          'currentTab',
          StatsTab.annual,
        ),
      ],
    );

    blocTest<StatsBloc, StatsState>(
      'ChangeStatsTab from StatsInitial emits nothing',
      build: () => _makeBloc(_StubStatisticsRepository()),
      act: (bloc) => bloc.add(const ChangeStatsTab(StatsTab.annual)),
      expect: () => <StatsState>[],
    );

    // ------------------------------------------------------------------
    // ChartTouchInteraction
    // ------------------------------------------------------------------
    blocTest<StatsBloc, StatsState>(
      'ChartTouchInteraction from seeded MonthlyStatsLoaded emits '
          '[MonthlyStatsLoaded] with updated touchedIndex',
      build: () => _makeBloc(_StubStatisticsRepository()),
      seed: _fakeLoadedState,
      act: (bloc) => bloc.add(const ChartTouchInteraction(3)),
      expect: () => [
        isA<MonthlyStatsLoaded>().having(
          (s) => s.touchedIndex,
          'touchedIndex',
          3,
        ),
      ],
    );

    blocTest<StatsBloc, StatsState>(
      'ChartTouchInteraction from StatsInitial emits nothing',
      build: () => _makeBloc(_StubStatisticsRepository()),
      act: (bloc) => bloc.add(const ChartTouchInteraction(3)),
      expect: () => <StatsState>[],
    );
  });
}
