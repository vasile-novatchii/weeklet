import 'package:equatable/equatable.dart';
import 'package:weeklet/domain/entities/statistics.dart';
import 'package:weeklet/domain/repositories/statistics_repository.dart';
import 'package:weeklet/domain/usecases/base/use_case.dart';

class GetMonthlyStatsParams extends Equatable {
  const GetMonthlyStatsParams({
    this.month,
    required this.year,
  });

  final int? month;
  final int year;

  @override
  List<Object?> get props => [month, year];
}

class GetMonthlyStatsUseCase
    implements UseCase<MonthlyStats, GetMonthlyStatsParams> {
  const GetMonthlyStatsUseCase(this.repository);

  final StatisticsRepository repository;

  @override
  Future<MonthlyStats> call(GetMonthlyStatsParams params) =>
      repository.getMonthlyStats(params.month, params.year);
}
