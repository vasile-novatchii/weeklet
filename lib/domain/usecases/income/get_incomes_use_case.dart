import 'package:weeklet/domain/entities/income.dart';
import 'package:weeklet/domain/repositories/income_repository.dart';

class GetIncomesUseCase {
  const GetIncomesUseCase(this.repository);

  final IncomeRepository repository;

  Future<List<Income>> call() => repository.getIncomes();
}
