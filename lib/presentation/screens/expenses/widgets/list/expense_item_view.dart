import 'package:flutter/material.dart';
import 'package:weeklet/core/constants/app_constants.dart';
import 'package:weeklet/core/di/service_locator.dart';
import 'package:weeklet/core/extensions/context_extensions.dart';
import 'package:weeklet/core/utils/number_formatter.dart';
import 'package:weeklet/domain/entities/category.dart';
import 'package:weeklet/domain/entities/expense.dart';
import 'package:weeklet/l10n/app_localizations.dart';
import 'package:weeklet/presentation/blocs/expense/expense_bloc.dart';
import 'package:weeklet/presentation/blocs/expense/expense_event.dart';
import 'package:weeklet/presentation/screens/expenses/widgets/edit_expense_form_view/edit_expense_form_view.dart';
import 'package:weeklet/presentation/widgets/common/category_icon_circle.dart';
import 'package:weeklet/presentation/widgets/common/common_menu_button.dart';
import 'package:weeklet/presentation/widgets/common/deletion_dialog/deletion_dialog.dart';
import 'package:weeklet/presentation/widgets/common/expense_amount_text.dart';
import 'package:weeklet/presentation/widgets/common/expense_details_column.dart';

class ExpenseItemView extends StatelessWidget {
  const ExpenseItemView({
    super.key,
    required this.expense,
    required this.category,
    this.currencySymbol = AppConstants.DEFAULT_CURRENCY,
    this.isIncome = false,
  });

  final Expense expense;
  final Category? category;
  final String currencySymbol;
  final bool isIncome;

  void _deleteExpense(BuildContext context) {
    sl<ExpenseBloc>().add(DeleteExpenseStarted(expense.id));
  }

  void _editExpense(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      useSafeArea: true,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => ScrollConfiguration(
        behavior: const ScrollBehavior(),
        child: SizedBox(
          height: context.screenHeight * 0.8,
          child: EditExpenseFormView(expense),
        ),
      ),
    );
  }

  List<MenuItem> _buildMenuItems(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return [
      MenuItem(
        label: l10n.editMenuLabel,
        icon: Icons.edit,
        onPressed: () => _editExpense(context),
        semanticLabel: 'Edit expense',
      ),
      MenuItem(
        label: l10n.deleteMenuLabel,
        icon: Icons.delete,
        iconColor: context.colorScheme.error,
        textColor: context.colorScheme.error,
        overlayColor: context.colorScheme.error,
        onPressed: () => CustomConfirmationDialog.show(
          context: context,
          icon: Icons.delete,
          iconBackgroundColor: context.colorScheme.error,
          title: l10n.deleteExpenseDialogTitle,
          subtitle1: l10n.deleteConfirmSubtitle1,
          subtitle1AccentText: ' ${expense.description}?',
          subtitle2: l10n.actionCannotBeUndone,
          confirmButtonColor: context.colorScheme.error,
          onConfirm: () => _deleteExpense(context),
          confirmButtonTextColor: Colors.white,
          confirmButtonText: l10n.deleteButtonLabel,
          cancelButtonColor: context.colorScheme.outline,
          cancelButtonTextColor: context.colorScheme.onSurface,
          cancelButtonText: l10n.cancelButtonLabel,
        ),
        semanticLabel: 'Delete expense',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final formattedAmount = NumberFormatter.formatAmountWithSign(
      expense.amount,
      isIncome: isIncome,
    );
    final formattedTime = NumberFormatter.formatTime(expense.createdAt);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        spacing: 12,
        children: [
          CategoryIconCircle(
            category: category,
            iconSize: 22,
            useTransparentBackground: true,
          ),
          Expanded(
            flex: 3,
            child: ExpenseDetailsColumn(
              description: expense.description,
              categoryName: category?.name ?? 'Unknown',
              time: formattedTime,
            ),
          ),
          Expanded(
            flex: 2,
            child: ExpenseAmountText(
              formattedAmount: formattedAmount,
              isIncome: isIncome,
            ),
          ),
          CommonMenuButton(menuItems: _buildMenuItems(context)),
        ],
      ),
    );
  }
}
