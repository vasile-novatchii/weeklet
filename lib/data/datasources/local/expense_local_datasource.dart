import 'package:flutter/foundation.dart' show debugPrint;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:weeklet/data/models/expense_model.dart';

abstract class ExpenseLocalDataSource {
  Future<void> addExpense(ExpenseModel expense);
  Future<void> deleteExpense(String id);
  Future<void> updateExpense(ExpenseModel expense);
  Future<List<ExpenseModel>> getExpensesByMonthYear(int month, int year);
  Future<List<ExpenseModel>> getAllExpenses();
  Future<void> clearAll();
}

class ExpenseLocalDataSourceImpl implements ExpenseLocalDataSource {
  ExpenseLocalDataSourceImpl(this.expenseBox);

  final Box<ExpenseModel> expenseBox;

  @override
  Future<void> addExpense(ExpenseModel model) async {
    try {
      await expenseBox.put(model.id, model);
    } catch (e) {
      debugPrint('[ExpenseLocalDataSourceImpl.addEpense] error: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteExpense(String id) async {
    try {
      await expenseBox.delete(id);
    } catch (e) {
      debugPrint('[ExpenseLocalDataSourceImpl.deleteExpense] error: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateExpense(ExpenseModel model) async {
    try {
      await expenseBox.put(model.id, model);
    } catch (e) {
      debugPrint('[ExpenseLocalDataSourceImpl.updateExpense] error: $e');
      rethrow;
    }
  }

  @override
  Future<List<ExpenseModel>> getExpensesByMonthYear(int month, int year) async {
    try {
      final expenses = expenseBox.values.where(
        (expense) =>
            expense.createdAt.month == month && expense.createdAt.year == year,
      );
      return expenses.toList();
    } catch (e) {
      debugPrint(
        '[ExpenseLocalDataSourceImpl.getExpensesByMonthYear] error: $e',
      );
      rethrow;
    }
  }

  @override
  Future<List<ExpenseModel>> getAllExpenses() async {
    try {
      return expenseBox.values.toList();
    } catch (e) {
      debugPrint('[ExpenseLocalDataSourceImpl.getAllExpenses] error: $e');
      rethrow;
    }
  }

  @override
  Future<void> clearAll() async {
    try {
      await expenseBox.clear();
    } catch (e) {
      debugPrint('[ExpenseLocalDataSourceImpl.clearAll] error: $e');
      rethrow;
    }
  }
}
