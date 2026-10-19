import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weeklet/core/utils/pdf_font_loader.dart';
import 'package:weeklet/domain/usecases/export/build_export_subject_usecase.dart';
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
    this.buildExportSubjectUseCase = const BuildExportSubjectUseCase(),
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
  final BuildExportSubjectUseCase buildExportSubjectUseCase;

  Future<void> _onExportExpenses(
    ExportExpensesStarted event,
    Emitter<ExportState> emit,
  ) async {
    // Ignore repeated taps while an export is already running.
    if (state is ExportInProgress) return;
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
      final subject = await buildExportSubjectUseCase(
        BuildExportSubjectParams(
          reportTitle: event.labels.reportTitleExpenses,
          localeCode: event.localeCode,
          year: event.year,
          month: event.month,
        ),
      );
      emit(
        ExportSuccess(
          filePath: filePath,
          subject: subject,
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
    // Ignore repeated taps while an export is already running.
    if (state is ExportInProgress) return;
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
      final subject = await buildExportSubjectUseCase(
        BuildExportSubjectParams(
          reportTitle: event.labels.reportTitleIncome,
          localeCode: event.localeCode,
          year: event.year,
          month: event.month,
        ),
      );
      emit(
        ExportSuccess(
          filePath: filePath,
          subject: subject,
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
    // Ignore repeated taps while an export is already running.
    if (state is ExportInProgress) return;
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
      final subject = await buildExportSubjectUseCase(
        BuildExportSubjectParams(
          reportTitle: event.labels.reportTitle,
          localeCode: event.localeCode,
          year: event.year,
          month: event.month,
        ),
      );
      emit(
        ExportSuccess(
          filePath: filePath,
          subject: subject,
          exportType: ExportType.stats,
        ),
      );
    } catch (e) {
      debugPrint('error in _onExportStats: $e');
      emit(ExportFailure(e.toString(), exportType: ExportType.stats));
    }
  }

  void _onResetExport(
    ResetExportRequested event,
    Emitter<ExportState> emit,
  ) {
    emit(const ExportInitial());
  }
}
