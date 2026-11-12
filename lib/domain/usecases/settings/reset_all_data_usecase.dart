import 'package:weeklet/domain/repositories/category_repository.dart';
import 'package:weeklet/domain/repositories/expense_repository.dart';
import 'package:weeklet/domain/repositories/income_repository.dart';
import 'package:weeklet/domain/repositories/settings_repository.dart';
import 'package:weeklet/domain/usecases/base/use_case.dart';

class ResetAllDataUseCase implements UseCase<void, NoParams> {
  const ResetAllDataUseCase({
    required this.expenseRepository,
    required this.incomeRepository,
    required this.categoryRepository,
    required this.settingsRepository,
  });

  final ExpenseRepository expenseRepository;
  final IncomeRepository incomeRepository;
  final CategoryRepository categoryRepository;
  final SettingsRepository settingsRepository;

  @override
  Future<void> call(NoParams params) async {
    // Run all clears in parallel; eagerError: false ensures all are attempted
    // even if one fails, preventing a partial-clear split state.
    await Future.wait(
      [
        expenseRepository.clearAll(),
        incomeRepository.clearAll(),
        categoryRepository.clearAll(),
        settingsRepository.clearAll(),
      ],
      eagerError: false,
    );
  }
}
