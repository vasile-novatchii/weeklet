import 'package:flutter/foundation.dart' show debugPrint;
import 'package:weeklet/data/datasources/local/expense_local_datasource.dart';
import 'package:weeklet/data/models/expense_model.dart';
import 'package:weeklet/domain/entities/expense.dart';
import 'package:weeklet/domain/repositories/expense_repository.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  ExpenseRepositoryImpl(this.localDataSource);

  final ExpenseLocalDataSource localDataSource;

  @override
  Future<void> addExpense(Expense expense) async {
    try {
      final model = ExpenseModel.fromEntity(expense);
      await localDataSource.addExpense(model);
    } catch (e) {
      debugPrint('[ExpenseRepositoryImpl.addExpense] error: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteExpense(String id) async {
    try {
      await localDataSource.deleteExpense(id);
    } catch (e) {
      debugPrint('[ExpenseRepositoryImpl.deleteExpense] error: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateExpense(Expense expense) async {
    try {
      final model = ExpenseModel.fromEntity(expense);
      await localDataSource.updateExpense(model);
    } catch (e) {
      debugPrint('[ExpenseRepositoryImpl.updateExpense] error: $e');
      rethrow;
    }
  }

  @override
  Future<List<Expense>> getExpensesByMonthYear(int month, int year) async {
    try {
      final models = await localDataSource.getExpensesByMonthYear(month, year);
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      debugPrint('[ExpenseRepositoryImpl.getExpensesByMonthYear] error: $e');
      rethrow;
    }
  }

  @override
  Future<List<Expense>> getAllExpenses() async {
    try {
      final models = await localDataSource.getAllExpenses();
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      debugPrint('[ExpenseRepositoryImpl.getAllExpenses] error: $e');
      rethrow;
    }
  }

  @override
  Future<void> clearAll() async {
    try {
      await localDataSource.clearAll();
    } catch (e) {
      debugPrint('[ExpenseRepositoryImpl.clearAll] error: $e');
      rethrow;
    }
  }
}
