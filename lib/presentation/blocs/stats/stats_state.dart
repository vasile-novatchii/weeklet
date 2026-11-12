import 'package:equatable/equatable.dart';
import 'package:weeklet/domain/entities/statistics.dart';
import 'package:weeklet/presentation/blocs/stats/stats_tab.dart';

sealed class StatsState extends Equatable {
  const StatsState();

  @override
  List<Object?> get props => [];
}

final class StatsInitial extends StatsState {
  const StatsInitial();
}

final class StatsLoading extends StatsState {
  const StatsLoading();
}

final class MonthlyStatsLoaded extends StatsState {
  const MonthlyStatsLoaded({
    required this.stats,
    this.month,
    required this.year,
    this.currentTab = StatsTab.monthly,
    this.touchedIndex = -1,
    this.evolutionStats,
    this.availablePeriods = const {},
    this.actionError,
  });

  final MonthlyStats stats;
  final int? month;
  final int year;
  final StatsTab currentTab;
  final int touchedIndex;
  final EvolutionStats? evolutionStats;
  final Map<int, List<int>> availablePeriods;
  final String? actionError;

  List<int> get availableYears {
    final years = availablePeriods.keys.toList()..sort((a, b) => b.compareTo(a));
    return years;
  }

  MonthlyStatsLoaded copyWith({
    MonthlyStats? stats,
    int? month,
    bool clearMonth = false,
    int? year,
    StatsTab? currentTab,
    int? touchedIndex,
    EvolutionStats? evolutionStats,
    Map<int, List<int>>? availablePeriods,
    String? actionError,
    bool clearActionError = false,
  }) => MonthlyStatsLoaded(
    stats: stats ?? this.stats,
    month: clearMonth ? null : (month ?? this.month),
    year: year ?? this.year,
    currentTab: currentTab ?? this.currentTab,
    touchedIndex: touchedIndex ?? this.touchedIndex,
    evolutionStats: evolutionStats ?? this.evolutionStats,
    availablePeriods: availablePeriods ?? this.availablePeriods,
    actionError: clearActionError ? null : (actionError ?? this.actionError),
  );

  @override
  List<Object?> get props => [
    stats,
    month,
    year,
    currentTab,
    touchedIndex,
    evolutionStats,
    availablePeriods,
    actionError,
  ];
}

final class StatsFailure extends StatsState {
  const StatsFailure(this.message);

  final String message;

  @override
  List<Object> get props => [message];
}
