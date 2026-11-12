import 'package:flutter/material.dart';
import 'package:weeklet/core/constants/category_icons.dart';

mixin CategorySearchMixin<T extends StatefulWidget> on State<T> {
  final ValueNotifier<String> searchNotifier = ValueNotifier('');
  final searchController = TextEditingController();

  final ValueNotifier<List<CategoryIcon>> filteredIconsNotifier = ValueNotifier(
    kCategoryIcons,
  );
  CategoryIcon? selectedIcon;

  @override
  void initState() {
    super.initState();
    searchNotifier.addListener(
      _filterIcons,
    );
  }

  @override
  void dispose() {
    searchNotifier.removeListener(
      _filterIcons,
    );
    searchNotifier.dispose();
    searchController.dispose();
    filteredIconsNotifier.dispose();
    super.dispose();
  }

  void _filterIcons() {
    final searchTerm = searchNotifier.value.toLowerCase().trim();
    List<CategoryIcon> newFilteredIcons;

    if (searchTerm.isEmpty) {
      newFilteredIcons = kCategoryIcons;
    } else {
      newFilteredIcons = kCategoryIcons
          .where(
            (icon) =>
                icon.label.toLowerCase().contains(
                  searchTerm,
                ) ||
                icon.name.toLowerCase().contains(
                  searchTerm,
                ),
          )
          .toList();
    }

    filteredIconsNotifier.value = newFilteredIcons;
  }
}
