import 'package:weeklet/core/utils/category_color_utils.dart';
import 'package:weeklet/domain/usecases/export/stats_pdf_labels.dart';
import 'package:weeklet/domain/utils/stats_export_utils.dart';
import 'package:weeklet/l10n/app_localizations.dart';
import 'package:weeklet/presentation/blocs/stats/stats_state.dart';
import 'package:weeklet/presentation/blocs/export/export_event.dart';

/// Assembles the stats PDF export request (localized labels, month rows and
/// category colors) so the Stats screen only forwards what it already has.
class StatsExportRequestFactory {
  const StatsExportRequestFactory._();

  static ExportStatsStarted build({
    required AppLocalizations l10n,
    required MonthlyStatsLoaded loaded,
    required String currencySymbol,
    required String localeCode,
  }) => ExportStatsStarted(
    stats: loaded.stats,
    monthRows: StatsExportUtils.monthRowsForSelection(
      evolution: loaded.evolutionStats,
      year: loaded.year,
      month: loaded.month,
    ),
    year: loaded.year,
    month: loaded.month,
    currencySymbol: currencySymbol,
    localeCode: localeCode,
    labels: labels(l10n, isAnnual: loaded.month == null),
    categoryColors: {
      for (final stat in loaded.stats.categoryStats)
        stat.category.id: CategoryColorUtils.getColor(
          stat.category.name,
        ).toARGB32(),
    },
  );

  static StatsPdfLabels labels(
    AppLocalizations l10n, {
    required bool isAnnual,
  }) => StatsPdfLabels(
    reportTitle: l10n.statsPdfReportTitle,
    generatedLabel: l10n.statsPdfGeneratedLabel,
    incomeLabel: isAnnual ? l10n.statsAnnualIncome : l10n.statsMonthlyIncome,
    expensesLabel: isAnnual
        ? l10n.statsAnnualExpenses
        : l10n.statsMonthlyExpenses,
    balanceLabel: isAnnual ? l10n.statsAnnualBalance : l10n.statsMonthlyBalance,
    vsLastMonthLabel: l10n.statsVsLastMonth,
    categoryBreakdownTitle: l10n.statsPdfCategoryBreakdownTitle,
    columnCategory: l10n.statsPdfColumnCategory,
    columnAmount: l10n.statsPdfColumnAmount,
    columnShare: l10n.statsPdfColumnShare,
    monthBreakdownTitle: l10n.statsMonthlyBreakdownTitle,
    columnMonth: l10n.statsPdfColumnMonth,
    columnIncome: l10n.incomeBarLabel,
    columnExpenses: l10n.expensesBarLabel,
    columnBalance: l10n.statsPdfColumnBalance,
    totalLabel: l10n.statsPdfTotal,
    noExpensesLabel: l10n.statsPdfNoExpenses,
  );
}
