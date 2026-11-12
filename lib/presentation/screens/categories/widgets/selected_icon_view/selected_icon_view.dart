import 'package:flutter/material.dart';
import 'package:weeklet/core/constants/category_icons.dart';
import 'package:weeklet/core/extensions/context_extensions.dart';
import 'package:weeklet/l10n/app_localizations.dart';
import 'package:weeklet/presentation/screens/categories/widgets/selected_icon_view/selected_icon.dart';
import 'package:weeklet/presentation/screens/categories/widgets/selected_icon_view/selected_icon_meta.dart';
import 'package:weeklet/presentation/widgets/label_view.dart';

class SelectedIconView extends StatelessWidget {
  const SelectedIconView({
    super.key,
    required this.selectedIcon,
    this.categoryName,
  });

  final CategoryIcon? selectedIcon;
  final String? categoryName;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: .start,
    spacing: 8,
    children: [
      LabelView(
        text: AppLocalizations.of(context).selectedIconLabel,
      ),
      Card(
        margin: EdgeInsets.zero,
        semanticContainer: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: context.colorScheme.outline,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            spacing: 12,
            children: [
              SelectedIcon(selectedIcon),
              SelectedIconMeta(selectedIcon, categoryName),
            ],
          ),
        ),
      ),
    ],
  );
}
