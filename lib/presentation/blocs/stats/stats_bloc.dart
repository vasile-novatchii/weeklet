import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weeklet/domain/usecases/base/use_case.dart';
import 'package:weeklet/domain/usecases/stats/get_available_periods_use_case.dart';
import 'package:weeklet/domain/usecases/stats/get_monthly_stats_use_case.dart';
import 'package:weeklet/domain/usecases/stats/get_evolution_stats_use_case.dart';
import 'package:weeklet/presentation/blocs/stats/stats_event.dart';
import 'package:weeklet/presentation/blocs/stats/stats_state.dart';


class StatsBloc extends Bloc<StatsEvent, StatsState> {
  StatsBloc({
    required this.getMonthlyStatsUseCase,
    required this.getEvolutionStatsUseCase,
    required this.getAvailablePeriodsUseCase,
  }) : super(const StatsInitial()) {
    on<LoadMonthlyStats>(_onLoadMonthlyStats);
    on<ChangeStatsTab>(_onChangeStatsTab);
    on<ChartTouchInteraction>(_onChartTouchInteraction);
  }

  final GetMonthlyStatsUseCase getMonthlyStatsUseCase;
  final GetEvolutionStatsUseCase getEvolutionStatsUseCase;
  final GetAvailablePeriodsUseCase getAvailablePeriodsUseCase;

  Future<void> _onLoadMonthlyStats(
    LoadMonthlyStats event,
    Emitter<StatsState> emit,
  ) async {
    // If we are already loaded, we want to keep the current state to avoid flickering
    // but re-fetch data. If not loaded, show loading.
    final isInitialLoad = state is! MonthlyStatsLoaded;
    if (isInitialLoad) {
      emit(const StatsLoading());
    }

    try {
      // Always fetch available periods so deleted months are removed
      final availablePeriods = await getAvailablePeriodsUseCase(NoParams());
      int? selectedMonth = event.month;

      if (isInitialLoad) {
        if (event.month == null) {
          final availableMonths = availablePeriods[event.year] ?? [];
          if (availableMonths.contains(DateTime.now().month) &&
              DateTime.now().year == event.year) {
            selectedMonth = DateTime.now().month;
          } else if (availableMonths.isNotEmpty) {
            selectedMonth = availableMonths.last;
          }
        }
      }

      final params = GetMonthlyStatsParams(
        month: selectedMonth,
        year: event.year,
      );
      final stats = await getMonthlyStatsUseCase(params);

      // Always re-fetch evolution so CRUD changes (add/delete expense or income)
      // are reflected immediately in the annual bar chart.
      final evolutionStats = await getEvolutionStatsUseCase(
        GetEvolutionStatsParams(year: event.year),
      );

      if (state case final MonthlyStatsLoaded st) {
        emit(
          st.copyWith(
            stats: stats,
            month: selectedMonth,
            clearMonth: selectedMonth == null,
            year: event.year,
            evolutionStats: evolutionStats,
            availablePeriods: availablePeriods,
            touchedIndex: -1,
          ),
        );
      } else {
        emit(
          MonthlyStatsLoaded(
            stats: stats,
            month: selectedMonth,
            year: event.year,
            availablePeriods: availablePeriods,
            evolutionStats: evolutionStats,
          ),
        );
      }
    } catch (e) {
      debugPrint('error in _onLoadMonthlyStats: $e');
      emit(StatsFailure(e.toString()));
    }
  }

  Future<void> _onChangeStatsTab(
    ChangeStatsTab event,
    Emitter<StatsState> emit,
  ) async {
    if (state case final MonthlyStatsLoaded st) {
      emit(st.copyWith(currentTab: event.tab));
      // No need to fetch EvolutionStats here, it's already fetched in LoadMonthlyStats
    }
  }

  void _onChartTouchInteraction(
    ChartTouchInteraction event,
    Emitter<StatsState> emit,
  ) {
    if (state case final MonthlyStatsLoaded st) {
      emit(st.copyWith(touchedIndex: event.index));
    }
  }
}
