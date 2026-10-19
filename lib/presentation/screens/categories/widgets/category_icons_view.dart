import 'package:flutter/material.dart';
import 'package:weeklet/core/constants/category_icons.dart';
import 'package:weeklet/core/extensions/context_extensions.dart';
import 'package:weeklet/core/mixins/category_search_mixin.dart';
import 'package:weeklet/l10n/app_localizations.dart';
import 'package:weeklet/presentation/screens/categories/widgets/add_category_empty_view.dart';
import 'package:weeklet/presentation/screens/categories/widgets/category_icon_view.dart';
import 'package:weeklet/presentation/screens/categories/widgets/clear_icon_view.dart';
import 'package:weeklet/presentation/widgets/input_view.dart';
import 'package:weeklet/presentation/widgets/label_view.dart';

class CategoryIconsView extends StatefulWidget {
  const CategoryIconsView({
    super.key,
    required this.onIconSelected,
    required this.selectedIconNotifier,
  });

  final void Function(CategoryIcon) onIconSelected;
  final ValueNotifier<CategoryIcon?> selectedIconNotifier;

  @override
  State<CategoryIconsView> createState() => _CategoryIconsViewState();
}

class _CategoryIconsViewState extends State<CategoryIconsView>
    with CategorySearchMixin<CategoryIconsView> {
  @override
  void initState() {
    super.initState();
    // Sync mixin's selectedIcon with parent's notifier
    selectedIcon = widget.selectedIconNotifier.value;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        LabelView(text: l10n.pickIconLabel),
        InputView(
          controller: searchController,
          hintText: l10n.iconSearchHint,
          onChanged: (text) => searchNotifier.value = text,
          prefixIcon: Icon(
            Icons.search,
            size: 22,
            color: context.colorScheme.surfaceContainerHighest,
          ),
          suffixIcon: ValueListenableBuilder<String>(
            valueListenable: searchNotifier,
            builder: (context, searchTerm, ___) => searchTerm.isNotEmpty
                ? ClearSearchButton(
                    onClearNotifier: () => searchNotifier.value = '',
                    onClearController: searchController.clear,
                  )
                : const SizedBox.shrink(),
          ),
        ),
        const SizedBox(),
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
            child: ValueListenableBuilder<List<CategoryIcon>>(
              valueListenable: filteredIconsNotifier,
              builder: (context, filteredIcons, child) => AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: filteredIcons.isEmpty
                    ? NoIconsFoundView(searchTerm: searchNotifier.value)
                    : ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: context.screenHeight * 0.35,
                        ),
                        child: ValueListenableBuilder<CategoryIcon?>(
                          valueListenable: widget.selectedIconNotifier,
                          builder: (context, selectedIcon, ___) => GridView.builder(
                            shrinkWrap: true,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 6,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                ),
                            itemCount: filteredIcons.length,
                            itemBuilder: (_, index) {
                              final categoryIcon = filteredIcons[index];
                              final isSelected =
                                  categoryIcon.name == selectedIcon?.name;
                              return CategoryIconView(
                                icon: categoryIcon,
                                isSelected: isSelected,
                                onSelected: () {
                                  setState(() {
                                    selectedIcon = categoryIcon;
                                    widget.onIconSelected(categoryIcon);
                                  });
                                  widget.selectedIconNotifier.value =
                                      categoryIcon;
                                },
                              );
                            },
                          ),
                        ),
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
