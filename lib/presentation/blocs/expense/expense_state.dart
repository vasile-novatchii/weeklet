import 'package:equatable/equatable.dart';
import 'package:weeklet/domain/entities/expense.dart';

sealed class ExpenseState extends Equatable {
  const ExpenseState();

  @override
  List<Object?> get props => [];
}

final class ExpenseInitial extends ExpenseState {
  const ExpenseInitial();
}

final class ExpenseLoading extends ExpenseState {
  const ExpenseLoading();
}

final class ExpenseSuccess extends ExpenseState {
  const ExpenseSuccess({
    required this.allExpenses,
    required this.filteredExpenses,
    required this.selectedYear,
    required this.availableYears,
    required this.availableMonths,
    this.selectedMonth,
    this.actionError,
  });

  final List<Expense> allExpenses;
  final List<Expense> filteredExpenses;
  final int selectedYear; // Default: DateTime.now().year
  final int? selectedMonth;
  final List<int> availableYears; // Unique years from all expenses
  final List<int> availableMonths; // Unique months for selectedYear
  final String? actionError;

  @override
  List<Object?> get props => [
    allExpenses,
    filteredExpenses,
    selectedYear,
    selectedMonth,
    availableYears,
    availableMonths,
    actionError,
  ];

  ExpenseSuccess copyWith({
    List<Expense>? allExpenses,
    List<Expense>? filteredExpenses,
    int? selectedYear,
    int? selectedMonth,
    List<int>? availableYears,
    List<int>? availableMonths,
    String? actionError,
  }) => ExpenseSuccess(
    allExpenses: allExpenses ?? this.allExpenses,
    filteredExpenses: filteredExpenses ?? this.filteredExpenses,
    selectedYear: selectedYear ?? this.selectedYear,
    selectedMonth: selectedMonth, // Allow null to be set for "All Months"
    availableYears: availableYears ?? this.availableYears,
    availableMonths: availableMonths ?? this.availableMonths,
    actionError: actionError, // allow null to reset error
  );
}

final class ExpenseFailure extends ExpenseState {
  const ExpenseFailure(this.message);

  final String message;
  @override
  List<Object?> get props => [message];
}
