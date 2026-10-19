import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weeklet/core/constants/app_constants.dart';
import 'package:weeklet/core/extensions/context_extensions.dart';
import 'package:weeklet/core/router/app_routes.dart';
import 'package:weeklet/domain/entities/category.dart';
import 'package:weeklet/domain/utils/filter_visibility_utils.dart';
import 'package:weeklet/l10n/app_localizations.dart';
import 'package:weeklet/presentation/blocs/category/category_bloc.dart';
import 'package:weeklet/presentation/blocs/category/category_state.dart';
import 'package:weeklet/presentation/blocs/expense/expense_bloc.dart';
import 'package:weeklet/presentation/blocs/expense/expense_event.dart';
import 'package:weeklet/presentation/blocs/expense/expense_state.dart';
import 'package:weeklet/presentation/blocs/export/export_bloc.dart';
import 'package:weeklet/presentation/blocs/export/export_event.dart';
import 'package:weeklet/presentation/blocs/export/export_state.dart';
import 'package:weeklet/presentation/blocs/settings/settings_bloc.dart';
import 'package:weeklet/presentation/blocs/settings/settings_state.dart';
import 'package:weeklet/presentation/screens/expenses/widgets/add_expense_form_view.dart';
import 'package:weeklet/presentation/screens/expenses/widgets/expense_filter_bar.dart';
import 'package:weeklet/presentation/screens/expenses/widgets/list/expense_list_view.dart';
import 'package:weeklet/presentation/widgets/common/empty_state_view.dart';
import 'package:weeklet/presentation/utils/transaction_pdf_labels_factory.dart';
import 'package:weeklet/presentation/utils/pdf_export_actions.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
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

  void _showAddExpenseSheet() => showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    useSafeArea: true,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => ScrollConfiguration(
      behavior: const ScrollBehavior(),
      child: SizedBox(
        height: context.screenHeight * 0.8,
        child: const AddExpenseFormView(),
      ),
    ),
  );

  Future<void> _onRefresh() async {
    if (!mounted) return;
    final bloc = context.read<ExpenseBloc>();
    bloc.add(const LoadExpensesRequested());

    await bloc.stream
        .firstWhere(
          (s) => s is ExpenseSuccess || s is ExpenseFailure,
        )
        .timeout(
          const Duration(seconds: 10),
          onTimeout: () => bloc.state,
        );
  }

  void _onExportTapped() {
    final expenseState = context.read<ExpenseBloc>().state;
    if (expenseState is! ExpenseSuccess) return;

    final categoryState = context.read<CategoryBloc>().state;
    final categories = categoryState is CategoriesLoaded
        ? categoryState.categories
        : <Category>[];

    final settingsState = context.read<SettingsBloc>().state;
    final currencySymbol = settingsState is SettingsLoaded
        ? settingsState.currencySymbol
        : AppConstants.DEFAULT_CURRENCY;

    context.read<ExportBloc>().add(
      ExportExpensesStarted(
        expenses: expenseState.filteredExpenses,
        categories: categories,
        currencySymbol: currencySymbol,
        year: expenseState.selectedYear,
        month: expenseState.selectedMonth,
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
    final expenseState = context.watch<ExpenseBloc>().state;
    // Hide the filter bar only when no expense exists in any period; keep it
    // while loading/failed or when other periods hold data.
    final showFilter =
        expenseState is! ExpenseSuccess ||
        FilterVisibilityUtils.showExpenseFilter(expenseState.allExpenses);
    final categoryState = context.watch<CategoryBloc>().state;
    final settingsState = context.watch<SettingsBloc>().state;
    final currencySymbol = settingsState is SettingsLoaded
        ? settingsState.currencySymbol
        : AppConstants.DEFAULT_CURRENCY;

    return MultiBlocListener(
      listeners: [
        BlocListener<ExportBloc, ExportState>(
          listenWhen: (_, s) =>
              (s is ExportSuccess && s.exportType == ExportType.expenses) ||
              (s is ExportFailure && s.exportType == ExportType.expenses),
          listener: (context, exportState) {
            if (exportState is ExportSuccess) {
              unawaited(
                PdfExportActions.present(
                  context,
                  filePath: exportState.filePath,
                  subject: exportState.subject,
                ).then((_) {
                  if (!context.mounted) return;
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
        ),
        BlocListener<ExpenseBloc, ExpenseState>(
          listenWhen: (_, s) =>
              s is ExpenseSuccess && (s.actionError?.isNotEmpty ?? false),
          listener: (context, state) {
            if (state case ExpenseSuccess(
              actionError: final err?,
            ) when err.isNotEmpty) {
              final message = switch (err) {
                'invalidAmount' => l10n.errorInvalidAmount,
                'emptyDescription' => l10n.errorEmptyDescription,
                'emptyCategory' => l10n.errorEmptyCategory,
                _ => l10n.errorGeneric,
              };
              context.showErrorSnackBar(message);
              context.read<ExpenseBloc>().add(
                const ClearActionErrorRequested(),
              );
            }
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(l10n.expensesScreenTitle),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.category),
              tooltip: l10n.categoriesTooltip,
              onPressed: () => context.pushNamed(AppRoutes.categoriesScreen),
            ),
            if (expenseState case final ExpenseSuccess success)
              if (success.filteredExpenses.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.picture_as_pdf),
                  tooltip: l10n.exportPdfTooltip,
                  onPressed: _onExportTapped,
                ),
          ],
          bottom: showFilter
              ? const PreferredSize(
                  preferredSize: Size.fromHeight(60),
                  child: ExpenseFilterBar(),
                )
              : null,
        ),
        body: switch ((expenseState, categoryState)) {
          (ExpenseLoading _, _) || (_, CategoryLoading _) => const Center(
            child: CircularProgressIndicator.adaptive(),
          ),

          (ExpenseFailure _, _) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: context.colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(l10n.expensesLoadError, style: context.bodyLarge),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => context.read<ExpenseBloc>().add(
                    const LoadExpensesRequested(),
                  ),
                  child: Text(l10n.retryButtonLabel),
                ),
              ],
            ),
          ),

          (final ExpenseSuccess success, final CategoriesLoaded _)
              when success.filteredExpenses.isEmpty =>
            Center(
              child: EmptyStateView(
                icon: Icons.receipt_long_outlined,
                title: l10n.expensesEmptyTitle,
                subtitle: l10n.expensesEmptySubtitle,
              ),
            ),

          (final ExpenseSuccess success, final CategoriesLoaded catLoaded) =>
            RefreshIndicator.adaptive(
              onRefresh: _onRefresh,
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.all(16.0),
                child: ExpenseListView(
                  expenses: success.filteredExpenses,
                  categories: catLoaded.categories,
                  currencySymbol: currencySymbol,
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
              onPressed: _showAddExpenseSheet,
              icon: Transform.translate(
                offset: _isAtBottom ? Offset.zero : const Offset(6, 0),
                child: const Icon(Icons.add),
              ),
              label: Visibility(
                visible: _isAtBottom,
                child: Text(l10n.addExpenseButtonLabel),
              ),
              tooltip: _isAtBottom ? '' : l10n.addExpenseTooltip,
            ),
          ),
        ),
      ),
    );
  }
}
