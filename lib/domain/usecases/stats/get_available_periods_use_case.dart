import 'package:weeklet/domain/repositories/statistics_repository.dart';
import 'package:weeklet/domain/usecases/base/use_case.dart';

class GetAvailablePeriodsUseCase
    implements UseCase<Map<int, List<int>>, NoParams> {
  const GetAvailablePeriodsUseCase(this.repository);

  final StatisticsRepository repository;

  @override
  Future<Map<int, List<int>>> call(NoParams params) =>
      repository.getAvailablePeriods();
}
