/// Validation error codes for income use cases.
///
/// LOC-01: Use cases throw [IncomeValidationException] with one of these
/// codes. BLoCs catch the exception and emit `e.error.name` as a string
/// `actionError`; widgets translate the code via AppLocalizations.
enum IncomeValidationError {
  invalidAmount,
  emptyDescription,
  emptyIncomeId,
}

/// Domain-layer exception for income validation failures.
/// Pure Dart — no Flutter imports.
class IncomeValidationException implements Exception {
  const IncomeValidationException(this.error);

  final IncomeValidationError error;

  @override
  String toString() => 'IncomeValidationException(${error.name})';
}
