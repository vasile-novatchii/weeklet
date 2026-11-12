import 'package:flutter/material.dart';

class CategoryIcon {
  const CategoryIcon({
    required this.name,
    required this.icon,
    required this.label,
  });

  final String name;
  final IconData icon;
  final String label;
}

const List<CategoryIcon> kCategoryIcons = [
  CategoryIcon(
    name: 'home',
    icon: Icons.home,
    label: 'Home',
  ),
  CategoryIcon(
    name: 'wifi',
    icon: Icons.wifi,
    label: 'WiFi',
  ),
  CategoryIcon(
    name: 'shopping_cart',
    icon: Icons.shopping_cart,
    label: 'Cart',
  ),
  CategoryIcon(
    name: 'directions_car',
    icon: Icons.directions_car,
    label: 'Car',
  ),
  CategoryIcon(
    name: 'account_balance_wallet',
    icon: Icons.account_balance_wallet,
    label: 'Wallet',
  ),
  CategoryIcon(
    name: 'trending_up',
    icon: Icons.trending_up,
    label: 'Income',
  ),
  CategoryIcon(
    name: 'restaurant',
    icon: Icons.restaurant,
    label: 'Restaurant',
  ),
  CategoryIcon(
    name: 'local_cafe',
    icon: Icons.local_cafe,
    label: 'Coffee',
  ),
  CategoryIcon(
    name: 'movie',
    icon: Icons.movie,
    label: 'Movie',
  ),
  CategoryIcon(
    name: 'sports_esports',
    icon: Icons.sports_esports,
    label: 'Gaming',
  ),
  CategoryIcon(
    name: 'fitness_center',
    icon: Icons.fitness_center,
    label: 'Sport',
  ),
  CategoryIcon(
    name: 'flight_takeoff',
    icon: Icons.flight_takeoff,
    label: 'Travel',
  ),
  CategoryIcon(
    name: 'favorite',
    icon: Icons.favorite,
    label: 'Health',
  ),
  CategoryIcon(
    name: 'school',
    icon: Icons.school,
    label: 'Education',
  ),
  CategoryIcon(
    name: 'work',
    icon: Icons.work,
    label: 'Work',
  ),
  CategoryIcon(
    name: 'directions_bus',
    icon: Icons.directions_bus,
    label: 'Transport',
  ),
  CategoryIcon(
    name: 'local_gas_station',
    icon: Icons.local_gas_station,
    label: 'Fuel',
  ),
  CategoryIcon(
    name: 'phone_iphone',
    icon: Icons.phone_iphone,
    label: 'Phone',
  ),
  CategoryIcon(
    name: 'checkroom',
    icon: Icons.checkroom,
    label: 'Clothes',
  ),
  CategoryIcon(
    name: 'chair',
    icon: Icons.chair,
    label: 'Furniture',
  ),
  CategoryIcon(
    name: 'pets',
    icon: Icons.pets,
    label: 'Pets',
  ),
  CategoryIcon(
    name: 'shield',
    icon: Icons.shield,
    label: 'Insurance',
  ),
  CategoryIcon(
    name: 'medication',
    icon: Icons.medication,
    label: 'Medicine',
  ),
  CategoryIcon(
    name: 'menu_book',
    icon: Icons.menu_book,
    label: 'Books',
  ),
  CategoryIcon(
    name: 'music_note',
    icon: Icons.music_note,
    label: 'Music',
  ),
  CategoryIcon(
    name: 'card_giftcard',
    icon: Icons.card_giftcard,
    label: 'Gifts',
  ),
  CategoryIcon(
    name: 'savings',
    icon: Icons.savings,
    label: 'Savings',
  ),
  CategoryIcon(
    name: 'lightbulb',
    icon: Icons.lightbulb,
    label: 'Utilities',
  ),
  CategoryIcon(
    name: 'build',
    icon: Icons.build,
    label: 'Repairs',
  ),
  CategoryIcon(
    name: 'park',
    icon: Icons.park,
    label: 'Garden',
  ),
  CategoryIcon(
    name: 'child_friendly',
    icon: Icons.child_friendly,
    label: 'Kids',
  ),
  CategoryIcon(
    name: 'family_restroom',
    icon: Icons.family_restroom,
    label: 'Family',
  ),
  CategoryIcon(
    name: 'more_horiz',
    icon: Icons.more_horiz,
    label: 'Other',
  ),
];
