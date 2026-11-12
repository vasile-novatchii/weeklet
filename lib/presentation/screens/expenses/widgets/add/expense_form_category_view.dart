import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weeklet/core/extensions/category_extensions.dart';
import 'package:weeklet/core/extensions/context_extensions.dart';
import 'package:weeklet/domain/entities/category.dart';
import 'package:weeklet/l10n/app_localizations.dart';
import 'package:weeklet/presentation/blocs/category/category_bloc.dart';
import 'package:weeklet/presentation/blocs/category/category_state.dart';
import 'package:weeklet/presentation/widgets/common/common_dropdown_button.dart';

class ExpenseFormCategoryView extends StatelessWidget {
  const ExpenseFormCategoryView({
    super.key,
    required this.selectedCategory,
    required this.onChanged,
  });
  final Category? selectedCategory;
  final ValueChanged<Category?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
        List<Category> categories = [];
        String? errorText;

        if (state is CategoriesLoaded) {
          categories = state.categories;
        } else if (state is CategoryError) {
          errorText = l10n.categoryLoadError;
        }

        return CommonDropdownButton<Category>(
          label: l10n.categoryFieldLabel,
          items: categories,
          selectedItem: selectedCategory,
          hint: l10n.categoryFieldHint,
          isLoading: state is CategoryLoading,
          errorText: errorText,
          itemBuilder: (category) => Row(
            spacing: 10,
            children: [
              category.toIcon(size: 20),
              Text(
                category.name,
                style: context.bodyLarge?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          onChanged: onChanged,
        );
      },
    );
  }
}
