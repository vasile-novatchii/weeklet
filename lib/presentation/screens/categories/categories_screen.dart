import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weeklet/core/extensions/context_extensions.dart';
import 'package:weeklet/core/router/app_routes.dart';
import 'package:weeklet/l10n/app_localizations.dart';
import 'package:weeklet/presentation/blocs/category/category_bloc.dart';
import 'package:weeklet/presentation/blocs/category/category_state.dart';
import 'package:weeklet/presentation/screens/categories/widgets/categories_empty_view.dart';
import 'package:weeklet/presentation/screens/categories/widgets/category_item_view.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.categoriesScreenTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: BlocBuilder<CategoryBloc, CategoryState>(
          builder: (context, state) {
            if (state is CategoryLoading) {
              return const Center(
                child: CircularProgressIndicator.adaptive(),
              );
            }

            if (state is CategoriesLoaded) {
              if (state.categories.isEmpty) {
                return const CategoriesEmptyView();
              }

              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: state.categories.length,
                itemBuilder: (_, index) {
                  final category = state.categories[index];
                  return CategoryItemView(category);
                },
              );
            }

            if (state is CategoryError) {
              final msg = switch (state.message) {
                'emptyName' => l10n.categoryNameValidationRequired,
                'errorCategoryNotFound' => l10n.errorCategoryNotFound,
                _ => l10n.errorGeneric,
              };
              return Center(
                child: Text(
                  msg,
                  textAlign: TextAlign.center,
                ),
              );
            }

            return const CategoriesEmptyView();
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: l10n.createCategoryTooltip,
        onPressed: () => context.pushNamed(AppRoutes.addCategoryScreen),
        child: const Icon(Icons.add),
      ),
    );
  }
}
