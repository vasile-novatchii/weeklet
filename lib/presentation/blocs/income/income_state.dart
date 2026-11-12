import 'package:equatable/equatable.dart';
import 'package:weeklet/domain/entities/income.dart';

sealed class IncomeState extends Equatable {
  const IncomeState();

  @override
  List<Object?> get props => [];
}

final class IncomeInitial extends IncomeState {
  const IncomeInitial();
}

final class IncomeLoading extends IncomeState {
  const IncomeLoading();
}

final class IncomeSuccess extends IncomeState {
  const IncomeSuccess({
    required this.allIncomes,
    required this.filteredIncomes,
    required this.selectedYear,
    required this.availableYears,
    required this.availableMonths,
    this.selectedMonth,
    this.actionError,
    this.formError,
  });

  final List<Income> allIncomes;
  final List<Income> filteredIncomes;
  final int selectedYear;
  final int? selectedMonth;
  final List<int> availableYears;
  final List<int> availableMonths;
  final String? actionError;
  final String? formError;

  @override
  List<Object?> get props => [
    allIncomes,
    filteredIncomes,
    selectedYear,
    selectedMonth,
    availableYears,
    availableMonths,
    actionError,
    formError,
  ];

  IncomeSuccess copyWith({
    List<Income>? allIncomes,
    List<Income>? filteredIncomes,
    int? selectedYear,
    int? selectedMonth,
    List<int>? availableYears,
    List<int>? availableMonths,
    String? actionError,
    String? formError,
  }) => IncomeSuccess(
    allIncomes: allIncomes ?? this.allIncomes,
    filteredIncomes: filteredIncomes ?? this.filteredIncomes,
    selectedYear: selectedYear ?? this.selectedYear,
    selectedMonth: selectedMonth, // Allow null to be set for "All Months"
    availableYears: availableYears ?? this.availableYears,
    availableMonths: availableMonths ?? this.availableMonths,
    actionError: actionError, // allow null to reset error
    formError: formError, // allow null to reset error
  );
}

final class IncomeFailure extends IncomeState {
  const IncomeFailure(this.message);

  final String message;
  @override
  List<Object?> get props => [message];
}
