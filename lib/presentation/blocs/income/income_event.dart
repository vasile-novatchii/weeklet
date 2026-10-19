import 'package:equatable/equatable.dart';
import 'package:weeklet/domain/entities/income.dart';

sealed class IncomeEvent extends Equatable {
  const IncomeEvent();

  @override
  List<Object?> get props => [];
}

/// Event for the initial loading of the list from the database.
///
/// Optionally carries a focus target so a reload triggered right after a
/// successful add or edit can land the filter on the affected entry
/// (INC-05) instead of resetting to the current date.
final class LoadIncomesRequested extends IncomeEvent {
  const LoadIncomesRequested({
    this.focusYear,
    this.focusMonth,
    this.hasFocus = false,
  });

  /// Year the filter should land on. Only honoured when [hasFocus] is true.
  final int? focusYear;

  /// Month the filter should land on. Only honoured when [hasFocus] is true.
  ///
  /// A null value here is MEANINGFUL: it means "keep All months" (D-02), so it
  /// must stay distinguishable from "no focus supplied" - hence [hasFocus].
  final int? focusMonth;

  /// Whether [focusYear] / [focusMonth] carry a real target.
  ///
  /// Not redundant with nullability: `focusMonth: null` is a valid focus value
  /// ("keep All months"), so the nullable fields alone cannot express the
  /// difference between a deliberate All-months focus and a plain reload.
  final bool hasFocus;

  @override
  List<Object?> get props => [focusYear, focusMonth, hasFocus];
}

/// Triggered when the user wants to add a new income.
final class AddIncomeStarted extends IncomeEvent {
  const AddIncomeStarted({
    required this.amount,
    required this.description,
    required this.date,
  });

  final String amount;
  final String description;
  final DateTime date;

  @override
  List<Object?> get props => [amount, description, date];
}

/// Triggered to update an existing income.
final class UpdateIncomeStarted extends IncomeEvent {
  const UpdateIncomeStarted(this.income);

  final Income income;

  @override
  List<Object?> get props => [income];
}

/// Triggered to delete an income by ID.
final class DeleteIncomeStarted extends IncomeEvent {
  const DeleteIncomeStarted(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

/// Triggered when the user changes the filter criteria.
final class IncomeFilterDateChanged extends IncomeEvent {
  const IncomeFilterDateChanged({this.year, this.month});

  final int? year;
  final int? month;

  @override
  List<Object?> get props => [year, month];
}

/// Resets any error message from the success state.
final class ClearIncomeActionErrorRequested extends IncomeEvent {
  const ClearIncomeActionErrorRequested();
}

/// Resets any add/update form error from the success state.
final class ClearIncomeFormErrorRequested extends IncomeEvent {
  const ClearIncomeFormErrorRequested();
}

/// An add or edit income form started listening for its own save outcome.
///
/// While at least one form is open, add/update failures are reported through
/// `formError` (shown inline). Otherwise they fall back to `actionError` so
/// the screen snackbar still shows them.
final class IncomeFormOpened extends IncomeEvent {
  const IncomeFormOpened();
}

/// An add or edit income form was closed (saved, cancelled or swiped away).
final class IncomeFormClosed extends IncomeEvent {
  const IncomeFormClosed();
}
