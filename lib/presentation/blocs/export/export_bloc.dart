import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:weeklet/core/utils/pdf_font_loader.dart';
import 'package:weeklet/domain/usecases/export/export_expenses_usecase.dart';
import 'package:weeklet/domain/usecases/export/export_income_usecase.dart';
import 'package:weeklet/domain/usecases/export/export_stats_usecase.dart';

import 'export_event.dart';
import 'export_state.dart';

class ExportBloc extends Bloc<ExportEvent, ExportState> {
  ExportBloc({
    required this.exportExpensesUseCase,
    required this.exportIncomeUseCase,
    required this.exportStatsUseCase,
    required this.fontLoader,
  }) : super(const ExportInitial()) {
    on<ExportExpensesStarted>(_onExportExpenses);
    on<ExportIncomeStarted>(_onExportIncome);
    on<ExportStatsStarted>(_onExportStats);
    on<ResetExportRequested>(_onResetExport);
  }

  final ExportExpensesUseCase exportExpensesUseCase;
  final ExportIncomeUseCase exportIncomeUseCase;
  final ExportStatsUseCase exportStatsUseCase;
  final PdfFontLoader fontLoader;

  Future<void> _onExportExpenses(
    ExportExpensesStarted event,
    Emitter<ExportState> emit,
  ) async {
    emit(const ExportInProgress());
    try {
      final fonts = await fontLoader.load();
      final filePath = await exportExpensesUseCase(
        ExportExpensesParams(
          expenses: event.expenses,
          categories: event.categories,
          currencySymbol: event.currencySymbol,
          year: event.year,
          month: event.month,
          localeCode: event.localeCode,
          labels: event.labels,
          regularFont: fonts.regular,
          boldFont: fonts.bold,
        ),
      );
      final period = await _periodLabel(
        event.localeCode,
        event.year,
        event.month,
      );
      emit(
        ExportSuccess(
          filePath: filePath,
          subject: 'Weeklet ${event.labels.reportTitleExpenses} - $period',
          exportType: ExportType.expenses,
        ),
      );
    } catch (e) {
      debugPrint('error in _onExportExpenses: $e');
      emit(ExportFailure(e.toString(), exportType: ExportType.expenses));
    }
  }

  Future<void> _onExportIncome(
    ExportIncomeStarted event,
    Emitter<ExportState> emit,
  ) async {
    emit(const ExportInProgress());
    try {
      final fonts = await fontLoader.load();
      final filePath = await exportIncomeUseCase(
        ExportIncomeParams(
          incomes: event.incomes,
          currencySymbol: event.currencySymbol,
          year: event.year,
          month: event.month,
          localeCode: event.localeCode,
          labels: event.labels,
          regularFont: fonts.regular,
          boldFont: fonts.bold,
        ),
      );
      final period = await _periodLabel(
        event.localeCode,
        event.year,
        event.month,
      );
      emit(
        ExportSuccess(
          filePath: filePath,
          subject: 'Weeklet ${event.labels.reportTitleIncome} - $period',
          exportType: ExportType.income,
        ),
      );
    } catch (e) {
      debugPrint('error in _onExportIncome: $e');
      emit(ExportFailure(e.toString(), exportType: ExportType.income));
    }
  }

  Future<void> _onExportStats(
    ExportStatsStarted event,
    Emitter<ExportState> emit,
  ) async {
    emit(const ExportInProgress());
    try {
      final fonts = await fontLoader.load();
      final filePath = await exportStatsUseCase(
        ExportStatsParams(
          stats: event.stats,
          monthRows: event.monthRows,
          year: event.year,
          month: event.month,
          currencySymbol: event.currencySymbol,
          localeCode: event.localeCode,
          labels: event.labels,
          categoryColors: event.categoryColors,
          regularFont: fonts.regular,
          boldFont: fonts.bold,
        ),
      );
      final period = await _periodLabel(
        event.localeCode,
        event.year,
        event.month,
      );
      emit(
        ExportSuccess(
          filePath: filePath,
          subject: 'Weeklet ${event.labels.reportTitle} - $period',
          exportType: ExportType.stats,
        ),
      );
    } catch (e) {
      debugPrint('error in _onExportStats: $e');
      emit(ExportFailure(e.toString(), exportType: ExportType.stats));
    }
  }

  /// Localized period (month name + year, or year only), first letter
  /// capitalized.
  Future<String> _periodLabel(String localeCode, int year, int? month) async {
    await initializeDateFormatting(localeCode);
    final period = month == null
        ? '$year'
        : DateFormat.yMMMM(localeCode).format(DateTime(year, month));
    if (period.isEmpty) {
      return period;
    }
    return period[0].toUpperCase() + period.substring(1);
  }

  void _onResetExport(
    ResetExportRequested event,
    Emitter<ExportState> emit,
  ) {
    emit(const ExportInitial());
  }
}
