import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:weeklet/core/constants/app_constants.dart';
import 'package:weeklet/core/extensions/context_extensions.dart';
import 'package:weeklet/core/utils/category_color_utils.dart';
import 'package:weeklet/domain/entities/statistics.dart';
import 'package:weeklet/domain/usecases/export/stats_pdf_labels.dart';
import 'package:weeklet/domain/utils/evolution_stats_utils.dart';
import 'package:weeklet/domain/utils/stats_export_utils.dart';
import 'package:weeklet/l10n/app_localizations.dart';
import 'package:weeklet/presentation/blocs/export/export_bloc.dart';
import 'package:weeklet/presentation/blocs/export/export_event.dart';
import 'package:weeklet/presentation/blocs/export/export_state.dart';
import 'package:weeklet/presentation/blocs/settings/settings_bloc.dart';
import 'package:weeklet/presentation/blocs/settings/settings_state.dart';
import 'package:weeklet/presentation/blocs/stats/stats_bloc.dart';
import 'package:weeklet/presentation/blocs/stats/stats_event.dart';
import 'package:weeklet/presentation/blocs/stats/stats_state.dart';
import 'package:weeklet/presentation/blocs/stats/stats_tab.dart';
import 'package:weeklet/presentation/screens/stats/widgets/category_details_list/category_details_list.dart';
import 'package:weeklet/presentation/screens/stats/widgets/modern_donut_chart.dart';
import 'package:weeklet/presentation/screens/stats/widgets/annual_grouped_bar_chart.dart';
import 'package:weeklet/presentation/screens/stats/widgets/monthly_expenses_list.dart';
import 'package:weeklet/presentation/screens/stats/widgets/stats_empty_view.dart';
import 'package:weeklet/presentation/screens/stats/widgets/stats_error_view.dart';
import 'package:weeklet/presentation/screens/stats/widgets/stats_filter_bar.dart';
import 'package:weeklet/presentation/screens/stats/widgets/stats_summary_cards/stats_summary_cards.dart';
import 'package:weeklet/presentation/screens/stats/widgets/stats_tabs_section.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) => const StatsView();
}

class StatsView extends StatelessWidget {
  const StatsView({super.key});

  void _onExportTapped(BuildContext context, MonthlyStatsLoaded loaded) {
    final l10n = AppLocalizations.of(context);
    final settingsState = context.read<SettingsBloc>().state;
    final currencySymbol = settingsState is SettingsLoaded
        ? settingsState.currencySymbol
        : AppConstants.DEFAULT_CURRENCY;
    final isAnnual = loaded.month == null;
    final evolution = loaded.evolutionStats;

    context.read<ExportBloc>().add(
      ExportStatsStarted(
        stats: loaded.stats,
        monthRows: isAnnual && evolution != null
            ? StatsExportUtils.monthsForExport(evolution, loaded.year)
            : const <MonthlySnapshot>[],
        year: loaded.year,
        month: loaded.month,
        currencySymbol: currencySymbol,
        localeCode: Localizations.localeOf(context).languageCode,
        labels: _buildPdfLabels(l10n, isAnnual: isAnnual),
        categoryColors: {
          for (final stat in loaded.stats.categoryStats)
            stat.category.id: CategoryColorUtils.getColor(
              stat.category.name,
            ).toARGB32(),
        },
      ),
    );
  }

  static StatsPdfLabels _buildPdfLabels(
    AppLocalizations l10n, {
    required bool isAnnual,
  }) => StatsPdfLabels(
    reportTitle: l10n.statsPdfReportTitle,
    generatedLabel: l10n.statsPdfGeneratedLabel,
    incomeLabel: isAnnual ? l10n.statsAnnualIncome : l10n.statsMonthlyIncome,
    expensesLabel: isAnnual
        ? l10n.statsAnnualExpenses
        : l10n.statsMonthlyExpenses,
    balanceLabel: isAnnual
        ? l10n.statsAnnualBalance
        : l10n.statsMonthlyBalance,
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

  void _onExportState(BuildContext context, ExportState exportState) {
    if (exportState is ExportSuccess) {
      unawaited(
        SharePlus.instance
            .share(
              ShareParams(
                files: [XFile(exportState.filePath)],
                subject: exportState.subject,
                sharePositionOrigin: const Rect.fromLTWH(0, 0, 1, 1),
              ),
            )
            .then((_) {
              if (!context.mounted) return;
              context.read<ExportBloc>().add(const ResetExportRequested());
            }),
      );
    } else if (exportState is ExportFailure) {
      context.showErrorSnackBar(AppLocalizations.of(context).pdfExportError);
      context.read<ExportBloc>().add(const ResetExportRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final statsState = context.watch<StatsBloc>().state;
    final settingsState = context.watch<SettingsBloc>().state;
    final currencySymbol = settingsState is SettingsLoaded
        ? settingsState.currencySymbol
        : AppConstants.DEFAULT_CURRENCY;

    return BlocListener<ExportBloc, ExportState>(
      listenWhen: (_, s) =>
          (s is ExportSuccess && s.exportType == ExportType.stats) ||
          (s is ExportFailure && s.exportType == ExportType.stats),
      listener: _onExportState,
      child: Scaffold(
      appBar: AppBar(
        title: Text(l10n.statsScreenTitle),
        actions: [
          if (statsState case final MonthlyStatsLoaded loaded)
            if (StatsExportUtils.hasExportableData(loaded.stats))
              IconButton(
                icon: const Icon(Icons.picture_as_pdf),
                tooltip: l10n.exportPdfTooltip,
                onPressed: () => _onExportTapped(context, loaded),
              ),
        ],
      ),
      body: BlocBuilder<StatsBloc, StatsState>(
      builder: (context, state) => switch (state) {
        StatsLoading _ || StatsInitial _ => const Center(
          child: CircularProgressIndicator.adaptive(),
        ),
        final StatsFailure error => StatsErrorView(
          message: error.message,
          onRetry: () => context.read<StatsBloc>().add(
            LoadMonthlyStats(year: DateTime.now().year),
          ),
        ),
        final MonthlyStatsLoaded loaded => CustomScrollView(
          slivers: [
            SliverPersistentHeader(
              pinned: true,
              delegate: _StickyFilterHeaderDelegate(
                child: const StatsFilterBar(),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  spacing: 16,
                  children: [
                    StatsSummaryCards(
                      stats: loaded.stats,
                      isAnnual: loaded.month == null,
                      currencySymbol: currencySymbol,
                    ),
                    StatsTabsSection(currentTab: loaded.currentTab),
                    if (loaded.currentTab == StatsTab.monthly) ...[
                      if (loaded.stats.categoryStats.isEmpty)
                        const StatsEmptyView()
                      else ...[
                        ModernDonutChart(
                          categoryStats: loaded.stats.categoryStats,
                          totalExpenses: loaded.stats.totalExpenses,
                          currencySymbol: currencySymbol,
                        ),
                        CategoryDetailsList(
                          categoryStats: loaded.stats.categoryStats,
                          currencySymbol: currencySymbol,
                        ),
                      ],
                    ] else if (loaded.evolutionStats
                        case final EvolutionStats es) ...[
                      if (EvolutionStatsUtils.getSnapshotsWithData(
                        es,
                      ).isNotEmpty) ...[
                        AnnualGroupedBarChart(
                          evolutionStats: es,
                          currencySymbol: currencySymbol,
                        ),
                        MonthlyExpensesList(
                          evolutionStats: es,
                          currencySymbol: currencySymbol,
                        ),
                      ] else
                        const StatsEmptyView(),
                    ] else
                      const Center(
                        child: CircularProgressIndicator.adaptive(),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      },
    ),
  ),
    );
  }
}

class _StickyFilterHeaderDelegate extends SliverPersistentHeaderDelegate {
  _StickyFilterHeaderDelegate({required this.child});
  final Widget child;

  @override
  double get minExtent => 70;
  @override
  double get maxExtent => 70;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) => ColoredBox(
    color: context.scaffoldBackgroundColor,
    child: child,
  );

  @override
  bool shouldRebuild(covariant _StickyFilterHeaderDelegate oldDelegate) =>
      oldDelegate.child != child;
}
