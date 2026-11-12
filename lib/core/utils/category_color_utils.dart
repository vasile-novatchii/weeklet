import 'package:flutter/material.dart';

class CategoryColorUtils {
  static Color getColor(String categoryName) {
    // Generate a consistent color based on the hash code of the name
    final int hash = categoryName.hashCode;
    // Use a predefined list of colors to ensure they look good
    final List<Color> colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.amber,
      Colors.indigo,
      Colors.cyan,
      Colors.brown,
      Colors.deepOrange,
    ];

    final int index = hash.abs() % colors.length;
    return colors[index];
  }
}
