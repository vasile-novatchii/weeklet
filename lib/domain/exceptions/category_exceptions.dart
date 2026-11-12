/// Validation error codes for category use cases.
///
/// LOC-01: Use cases throw [CategoryValidationException] with one of these
/// codes. BLoCs catch the exception and emit `e.error.name` as a string
/// in a [CategoryError] message; widgets translate the code via
/// AppLocalizations.
enum CategoryValidationError {
  emptyName,
  emptyIcon,
  emptyId,
  emptyCategoryId,
  duplicateName,
}

/// Domain-layer exception for category validation failures.
/// Pure Dart — no Flutter imports.
class CategoryValidationException implements Exception {
  const CategoryValidationException(this.error);

  final CategoryValidationError error;

  @override
  String toString() => 'CategoryValidationException(${error.name})';
}
