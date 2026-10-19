import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weeklet/core/constants/app_constants.dart';
import 'package:weeklet/core/extensions/context_extensions.dart';
import 'package:weeklet/domain/entities/statistics.dart';
import 'package:weeklet/domain/utils/evolution_stats_utils.dart';
import 'package:weeklet/domain/utils/filter_visibility_utils.dart';
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
import 'package:weeklet/presentation/utils/pdf_export_actions.dart';
import 'package:weeklet/presentation/utils/stats_export_request_factory.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) => const StatsView();
}

class StatsView extends StatelessWidget {
  const StatsView({super.key});

  void _onExportTapped(BuildContext context, MonthlyStatsLoaded loaded) {
    final settingsState = context.read<SettingsBloc>().state;
    final currencySymbol = settingsState is SettingsLoaded
        ? settingsState.currencySymbol
        : AppConstants.DEFAULT_CURRENCY;

    context.read<ExportBloc>().add(
      StatsExportRequestFactory.build(
        l10n: AppLocalizations.of(context),
        loaded: loaded,
        currencySymbol: currencySymbol,
        localeCode: Localizations.localeOf(context).languageCode,
      ),
    );
  }

  void _onExportState(BuildContext context, ExportState exportState) {
    if (exportState is ExportSuccess) {
      final exportBloc = context.read<ExportBloc>();
      unawaited(
        PdfExportActions.present(
          context,
          filePath: exportState.filePath,
          subject: exportState.subject,
        ).whenComplete(() => exportBloc.add(const ResetExportRequested())),
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
    final isExporting = context.watch<ExportBloc>().state is ExportInProgress;
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
                  onPressed: isExporting
                      ? null
                      : () => _onExportTapped(context, loaded),
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
            final MonthlyStatsLoaded loaded
                when !StatsExportUtils.hasExportableData(loaded.stats) =>
              CustomScrollView(
                slivers: [
                  if (FilterVisibilityUtils.showStatsFilter(
                    loaded.availablePeriods,
                  ))
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _StickyFilterHeaderDelegate(
                        child: const StatsFilterBar(),
                      ),
                    ),
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: StatsEmptyView(),
                  ),
                ],
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
