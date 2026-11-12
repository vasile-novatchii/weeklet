import 'package:equatable/equatable.dart';
import 'package:weeklet/domain/entities/expense.dart';

sealed class ExpenseEvent extends Equatable {
  const ExpenseEvent();

  @override
  List<Object?> get props => [];
}

/// Event for the initial loading of the list from the database/API.
final class LoadExpensesRequested extends ExpenseEvent {
  const LoadExpensesRequested();
}

/// Triggered when the user wants to add a new expense.
/// We pass the raw data needed to create the object in the Bloc.
///
/// CAT-01 / D-11: a null [categoryId] means "no category was selected" and
/// instructs the Bloc to resolve the app-managed default category. It stays a
/// `required` named parameter so every call site states its intent explicitly.
/// [defaultCategoryName] is the default name resolved from the active locale
/// by the presentation layer; it is only consulted when a default actually has
/// to be created, and is ignored whenever [categoryId] is non-null.
final class AddExpenseStarted extends ExpenseEvent {
  const AddExpenseStarted({
    required this.amount,
    required this.description,
    required this.categoryId,
    required this.defaultCategoryName,
    required this.date,
  });

  final String amount;
  final String description;
  final String? categoryId;
  final String defaultCategoryName;
  final DateTime date;

  @override
  List<Object?> get props => [
    amount,
    description,
    categoryId,
    defaultCategoryName,
    date,
  ];
}

/// Triggered to update an existing expense.
final class UpdateExpenseStarted extends ExpenseEvent {
  const UpdateExpenseStarted(this.expense);

  final Expense expense;

  @override
  List<Object?> get props => [expense];
}

/// Triggered to delete an expense by ID.
final class DeleteExpenseStarted extends ExpenseEvent {
  const DeleteExpenseStarted(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

/// Triggered when the user changes the filter criteria.
final class FilterDateChanged extends ExpenseEvent {
  const FilterDateChanged({this.year, this.month});

  final int? year;
  final int? month;

  @override
  List<Object?> get props => [year, month];
}

/// (Optional) Resets any error message from the success state.
/// Useful for clearing the SnackBar in the UI after display.
final class ClearActionErrorRequested extends ExpenseEvent {
  const ClearActionErrorRequested();
}
