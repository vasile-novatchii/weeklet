/// Validation error codes for expense use cases.
///
/// LOC-01: Use cases throw [ExpenseValidationException] with one of these
/// codes. BLoCs catch the exception and emit `e.error.name` as a string
/// `actionError`; widgets translate the code via AppLocalizations.
enum ExpenseValidationError {
  invalidAmount,
  emptyDescription,
  emptyCategory,
  emptyExpenseId,
}

/// Domain-layer exception for expense validation failures.
/// Pure Dart — no Flutter imports.
class ExpenseValidationException implements Exception {
  const ExpenseValidationException(this.error);

  final ExpenseValidationError error;

  @override
  String toString() => 'ExpenseValidationException(${error.name})';
}
