import 'package:flutter/material.dart' show Color, Icon;
import 'package:weeklet/core/constants/category_icons.dart';
import 'package:weeklet/domain/entities/category.dart';

extension CategoryToCategoryIcon on Category {
  CategoryIcon toCategoryIcon() => kCategoryIcons.firstWhere(
    (ci) => ci.name == icon,
    orElse: () => kCategoryIcons.first,
  );

  Icon toIcon({
    double? size,
    Color? color,
  }) {
    final ci = toCategoryIcon();
    return Icon(
      ci.icon,
      size: size,
      color: color,
    );
  }
}
