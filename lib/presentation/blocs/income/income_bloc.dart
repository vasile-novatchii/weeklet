import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weeklet/core/di/service_locator.dart';
import 'package:weeklet/domain/exceptions/income_exceptions.dart';
import 'package:weeklet/domain/usecases/income/add_income_use_case.dart';
import 'package:weeklet/domain/usecases/income/delete_income_use_case.dart';
import 'package:weeklet/domain/usecases/income/get_incomes_use_case.dart';
import 'package:weeklet/domain/usecases/income/update_income_use_case.dart';
import 'package:weeklet/domain/utils/income_filter_utils.dart';
import 'package:weeklet/presentation/blocs/stats/stats_bloc.dart';
import 'package:weeklet/presentation/blocs/stats/stats_event.dart';

import 'income_event.dart';
import 'income_state.dart';

class IncomeBloc extends Bloc<IncomeEvent, IncomeState> {
  IncomeBloc({
    required this.addIncomeUseCase,
    required this.updateIncomeUseCase,
    required this.deleteIncomeUseCase,
    required this.getIncomesUseCase,
  }) : super(const IncomeInitial()) {
    on<LoadIncomesRequested>(_onLoadIncomes);
    on<AddIncomeStarted>(_onAddIncome);
    on<UpdateIncomeStarted>(_onUpdateIncome);
    on<DeleteIncomeStarted>(_onDeleteIncome);
    on<IncomeFilterDateChanged>(_onFilterDateChanged);
    on<ClearIncomeActionErrorRequested>(_onClearActionError);
  }

  final AddIncomeUseCase addIncomeUseCase;
  final UpdateIncomeUseCase updateIncomeUseCase;
  final DeleteIncomeUseCase deleteIncomeUseCase;
  final GetIncomesUseCase getIncomesUseCase;

  void _onClearActionError(
    ClearIncomeActionErrorRequested event,
    Emitter<IncomeState> emit,
  ) {
    if (state case final IncomeSuccess st) {
      emit(
        st.copyWith(
          selectedMonth: st.selectedMonth,
          actionError: null,
        ),
      );
    }
  }

  Future<void> _onLoadIncomes(
    LoadIncomesRequested event,
    Emitter<IncomeState> emit,
  ) async {
    emit(const IncomeLoading());
    try {
      final incomes = await getIncomesUseCase();

      final availableYears = IncomeFilterUtils.extractAvailableYears(incomes);
      final currentYear = DateTime.now().year;

      // Default (no focus): fall back to today's year when we have data for it.
      final defaultYear = availableYears.contains(currentYear)
          ? currentYear
          : availableYears.first;

      // Focus (INC-05): land on the affected entry's year. The containment
      // check is a defensive guard - the year dropdown asserts if the selected
      // value is not one of its items.
      final focusYear = event.focusYear;
      final selectedYear =
          event.hasFocus &&
              focusYear != null &&
              availableYears.contains(focusYear)
          ? focusYear
          : defaultYear;

      final availableMonths = IncomeFilterUtils.extractAvailableMonthsForYear(
        incomes,
        selectedYear,
      );

      final int? selectedMonth;
      if (event.hasFocus) {
        // A null focusMonth means "keep All months" (D-02) and is honoured
        // as-is. A non-null month that is somehow absent from the dropdown
        // items falls back to null rather than to today's month, because
        // "All months" is always valid and always keeps the entry visible.
        final focusMonth = event.focusMonth;
        selectedMonth =
            focusMonth == null || availableMonths.contains(focusMonth)
            ? focusMonth
            : null;
      } else {
        final currentMonth = DateTime.now().month;
        selectedMonth = availableMonths.contains(currentMonth)
            ? currentMonth
            : (availableMonths.isNotEmpty ? availableMonths.last : null);
      }

      final filtered = incomes.where((income) {
        final matchYear = income.date.year == selectedYear;
        final matchMonth =
            selectedMonth == null || income.date.month == selectedMonth;
        return matchYear && matchMonth;
      }).toList();

      emit(
        IncomeSuccess(
          allIncomes: incomes,
          filteredIncomes: filtered,
          selectedYear: selectedYear,
          selectedMonth: selectedMonth,
          availableYears: availableYears,
          availableMonths: availableMonths,
        ),
      );
    } catch (e) {
      debugPrint('error in _onLoadIncomes: $e');
      emit(IncomeFailure(e.toString()));
    }
  }

  Future<void> _onAddIncome(
    AddIncomeStarted event,
    Emitter<IncomeState> emit,
  ) async {
    if (state case final IncomeSuccess st) {
      try {
        await addIncomeUseCase(
          AddIncomeParams(
            amount: event.amount,
            description: event.description,
            date: event.date,
          ),
        );
        // INC-05: `st` is the last place the pre-add filter is known - the
        // reload emits IncomeLoading and wipes it - so decide here.
        // D-01: jump to the entry's month + year. D-02: when "All months" is
        // active keep it, moving only the year.
        final allMonthsActive = st.selectedMonth == null;
        add(
          LoadIncomesRequested(
            focusYear: event.date.year,
            focusMonth: allMonthsActive ? null : event.date.month,
            hasFocus: true,
          ),
        );
        sl<StatsBloc>().add(LoadMonthlyStats(year: DateTime.now().year));
      } on IncomeValidationException catch (e) {
        debugPrint('error in _onAddIncome: $e');
        emit(
          st.copyWith(
            selectedMonth: st.selectedMonth,
            actionError: e.error.name,
          ),
        );
      } catch (e) {
        debugPrint('error in _onAddIncome: $e');
        emit(
          st.copyWith(
            selectedMonth: st.selectedMonth,
            actionError: 'genericError',
          ),
        );
      }
    }
  }

  Future<void> _onUpdateIncome(
    UpdateIncomeStarted event,
    Emitter<IncomeState> emit,
  ) async {
    if (state case final IncomeSuccess st) {
      try {
        await updateIncomeUseCase(event.income);
        // D-03: an edited date gets the same jump as an add, so the entry
        // never silently disappears from the visible list after saving.
        final allMonthsActive = st.selectedMonth == null;
        add(
          LoadIncomesRequested(
            focusYear: event.income.date.year,
            focusMonth: allMonthsActive ? null : event.income.date.month,
            hasFocus: true,
          ),
        );
        sl<StatsBloc>().add(LoadMonthlyStats(year: DateTime.now().year));
      } on IncomeValidationException catch (e) {
        debugPrint('error in _onUpdateIncome: $e');
        emit(
          st.copyWith(
            selectedMonth: st.selectedMonth,
            actionError: e.error.name,
          ),
        );
      } catch (e) {
        debugPrint('error in _onUpdateIncome: $e');
        emit(
          st.copyWith(
            selectedMonth: st.selectedMonth,
            actionError: 'genericError',
          ),
        );
      }
    }
  }

  Future<void> _onDeleteIncome(
    DeleteIncomeStarted event,
    Emitter<IncomeState> emit,
  ) async {
    if (state case final IncomeSuccess st) {
      try {
        await deleteIncomeUseCase(event.id);
        add(const LoadIncomesRequested());
        sl<StatsBloc>().add(LoadMonthlyStats(year: DateTime.now().year));
      } on IncomeValidationException catch (e) {
        debugPrint('error in _onDeleteIncome: $e');
        emit(
          st.copyWith(
            selectedMonth: st.selectedMonth,
            actionError: e.error.name,
          ),
        );
      } catch (e) {
        debugPrint('error in _onDeleteIncome: $e');
        emit(
          st.copyWith(
            selectedMonth: st.selectedMonth,
            actionError: 'genericError',
          ),
        );
      }
    }
  }

  Future<void> _onFilterDateChanged(
    IncomeFilterDateChanged event,
    Emitter<IncomeState> emit,
  ) async {
    if (state case final IncomeSuccess st) {
      final newYear = event.year ?? st.selectedYear;
      final yearChanged = newYear != st.selectedYear;

      final availableMonths = yearChanged
          ? IncomeFilterUtils.extractAvailableMonthsForYear(
              st.allIncomes,
              newYear,
            )
          : st.availableMonths;

      final int? selectedMonth;
      if (event.year != null && event.month == null) {
        selectedMonth = availableMonths.contains(st.selectedMonth)
            ? st.selectedMonth
            : (availableMonths.isNotEmpty ? availableMonths.first : null);
      } else if (event.year == null) {
        selectedMonth = event.month;
      } else {
        selectedMonth = event.month ?? st.selectedMonth;
      }

      final filtered = st.allIncomes.where((income) {
        final matchYear = income.date.year == newYear;
        final matchMonth =
            selectedMonth == null || income.date.month == selectedMonth;
        return matchYear && matchMonth;
      }).toList();

      emit(
        st.copyWith(
          filteredIncomes: filtered,
          selectedYear: newYear,
          selectedMonth: selectedMonth,
          availableMonths: availableMonths,
        ),
      );
    }
  }
}
