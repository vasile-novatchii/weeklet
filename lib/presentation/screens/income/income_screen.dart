import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weeklet/core/constants/app_constants.dart';
import 'package:weeklet/core/extensions/context_extensions.dart';
import 'package:weeklet/domain/utils/income_grouping.dart';
import 'package:weeklet/l10n/app_localizations.dart';
import 'package:weeklet/presentation/blocs/export/export_bloc.dart';
import 'package:weeklet/presentation/blocs/export/export_event.dart';
import 'package:weeklet/presentation/blocs/export/export_state.dart';
import 'package:weeklet/presentation/blocs/income/income_bloc.dart';
import 'package:weeklet/presentation/blocs/income/income_event.dart';
import 'package:weeklet/presentation/blocs/income/income_state.dart';
import 'package:weeklet/presentation/blocs/settings/settings_bloc.dart';
import 'package:weeklet/presentation/blocs/settings/settings_state.dart';
import 'package:weeklet/presentation/screens/income/widgets/add_income_form_view.dart';
import 'package:weeklet/presentation/screens/income/widgets/income_filter_bar.dart';
import 'package:weeklet/presentation/screens/income/widgets/income_total_card.dart';
import 'package:weeklet/presentation/screens/income/widgets/list/income_list_view.dart';
import 'package:weeklet/presentation/utils/transaction_pdf_labels_factory.dart';
import 'package:weeklet/presentation/utils/pdf_share_helper.dart';

class IncomeScreen extends StatefulWidget {
  const IncomeScreen({super.key});

  @override
  State<IncomeScreen> createState() => _IncomeScreenState();
}

class _IncomeScreenState extends State<IncomeScreen> {
  late ScrollController _scrollController;
  bool _isAtBottom = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScrolled);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScrolled);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScrolled() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    final isAtBottom = currentScroll >= maxScroll - 50;

    if (isAtBottom != _isAtBottom) {
      setState(() => _isAtBottom = isAtBottom);
    }
  }

  void _showAddIncomeSheet() => showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    useSafeArea: true,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => ScrollConfiguration(
      behavior: const ScrollBehavior(),
      child: SizedBox(
        height: context.screenHeight * 0.8,
        child: const AddIncomeFormView(),
      ),
    ),
  );

  Future<void> _onRefresh() async {
    if (!mounted) return;
    final bloc = context.read<IncomeBloc>();
    bloc.add(const LoadIncomesRequested());

    await bloc.stream
        .firstWhere(
          (s) => s is IncomeSuccess || s is IncomeFailure,
        )
        .timeout(
          const Duration(seconds: 10),
          onTimeout: () => bloc.state,
        );
  }

  void _onExportTapped() {
    final incomeState = context.read<IncomeBloc>().state;
    if (incomeState is! IncomeSuccess) return;

    final settingsState = context.read<SettingsBloc>().state;
    final currencySymbol = settingsState is SettingsLoaded
        ? settingsState.currencySymbol
        : AppConstants.DEFAULT_CURRENCY;

    context.read<ExportBloc>().add(
      ExportIncomeStarted(
        incomes: incomeState.filteredIncomes,
        currencySymbol: currencySymbol,
        year: incomeState.selectedYear,
        month: incomeState.selectedMonth,
        localeCode: Localizations.localeOf(context).languageCode,
        labels: TransactionPdfLabelsFactory.fromL10n(
          AppLocalizations.of(context),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final incomeState = context.watch<IncomeBloc>().state;
    final settingsState = context.watch<SettingsBloc>().state;
    final currencySymbol = settingsState is SettingsLoaded
        ? settingsState.currencySymbol
        : AppConstants.DEFAULT_CURRENCY;

    return BlocListener<IncomeBloc, IncomeState>(
      listenWhen: (_, s) => s is IncomeSuccess && s.actionError != null,
      listener: (context, state) {
        if (state case IncomeSuccess(
          actionError: final err?,
        ) when err.isNotEmpty) {
          final message = switch (err) {
            'invalidAmount' => l10n.errorInvalidAmount,
            'emptyDescription' => l10n.errorEmptyDescription,
            _ => l10n.errorGeneric,
          };
          context.showErrorSnackBar(message);
          context.read<IncomeBloc>().add(
            const ClearIncomeActionErrorRequested(),
          );
        }
      },
      child: BlocListener<ExportBloc, ExportState>(
        listenWhen: (_, s) =>
            (s is ExportSuccess && s.exportType == ExportType.income) ||
            (s is ExportFailure && s.exportType == ExportType.income),
        listener: (context, exportState) {
          if (exportState is ExportSuccess) {
            unawaited(
              PdfShareHelper.share(
                filePath: exportState.filePath,
                subject: exportState.subject,
              ).then((_) {
                if (!mounted) return;
                context.read<ExportBloc>().add(
                  const ResetExportRequested(),
                );
              }),
            );
          } else if (exportState is ExportFailure) {
            context.showErrorSnackBar(l10n.pdfExportError);
            context.read<ExportBloc>().add(const ResetExportRequested());
          }
        },
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Text(l10n.incomeScreenTitle),
            centerTitle: true,
            actions: [
              if (incomeState case final IncomeSuccess success)
                if (success.filteredIncomes.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.picture_as_pdf),
                    tooltip: l10n.exportPdfTooltip,
                    onPressed: _onExportTapped,
                  ),
            ],
            bottom: const PreferredSize(
              preferredSize: Size.fromHeight(60),
              child: IncomeFilterBar(),
            ),
          ),
          body: switch (incomeState) {
            IncomeLoading _ => const Center(
              child: CircularProgressIndicator.adaptive(),
            ),

            IncomeFailure _ => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: context.colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(l10n.incomeLoadError, style: context.bodyLarge),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => context.read<IncomeBloc>().add(
                      const LoadIncomesRequested(),
                    ),
                    child: Text(l10n.retryButtonLabel),
                  ),
                ],
              ),
            ),

            final IncomeSuccess success => RefreshIndicator.adaptive(
              onRefresh: _onRefresh,
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    IncomeTotalCard(
                      total: IncomeGrouping.calculateTotal(
                        success.filteredIncomes,
                      ),
                      selectedMonth: success.selectedMonth,
                      currencySymbol: currencySymbol,
                    ),
                    const SizedBox(height: 16),
                    IncomeListView(
                      incomes: success.filteredIncomes,
                      currencySymbol: currencySymbol,
                    ),
                  ],
                ),
              ),
            ),

            _ => const SizedBox.shrink(),
          },
          floatingActionButton: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            width: _isAtBottom ? context.screenWidth - 32 : 56,
            height: _isAtBottom ? 48 : 56,
            child: AnimatedSlide(
              duration: const Duration(milliseconds: 400),
              offset: Offset.zero,
              child: FloatingActionButton.extended(
                onPressed: _showAddIncomeSheet,
                icon: Transform.translate(
                  offset: _isAtBottom ? Offset.zero : const Offset(6, 0),
                  child: const Icon(Icons.add),
                ),
                label: Visibility(
                  visible: _isAtBottom,
                  child: Text(l10n.addIncomeButtonLabel),
                ),
                tooltip: _isAtBottom ? '' : l10n.addIncomeTooltip,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
