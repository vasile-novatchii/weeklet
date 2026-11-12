import 'package:weeklet/domain/entities/statistics.dart';

abstract class StatisticsRepository {
  Future<MonthlyStats> getMonthlyStats(int? month, int year);
  Future<EvolutionStats> getEvolutionStats(int year);
  Future<Map<int, List<int>>> getAvailablePeriods();
}
