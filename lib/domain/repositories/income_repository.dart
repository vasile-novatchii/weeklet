import 'package:weeklet/domain/entities/income.dart';

abstract class IncomeRepository {
  Future<void> addIncome(Income income);
  Future<List<Income>> getIncomes();
  Future<void> updateIncome(Income income);
  Future<void> deleteIncome(String id);
  Future<void> clearAll();
}
