import 'package:flutter/material.dart';
import 'package:weeklet/l10n/app_localizations.dart';
import 'package:weeklet/presentation/widgets/common/empty_state_view.dart';

class CategoriesEmptyView extends StatelessWidget {
  const CategoriesEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return EmptyStateView(
      icon: Icons.category_outlined,
      title: l10n.categoriesEmptyTitle,
      subtitle: l10n.categoriesEmptySubtitle,
    );
  }
}
