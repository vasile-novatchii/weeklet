import 'package:flutter/material.dart';
import 'package:weeklet/presentation/navigation/main_navigation.dart';
import 'package:weeklet/presentation/screens/categories/add_category_screen.dart';
import 'package:weeklet/presentation/screens/categories/categories_screen.dart';
import 'package:weeklet/presentation/screens/expenses/expenses_screen.dart';
import 'package:weeklet/presentation/screens/income/income_screen.dart';
import 'package:weeklet/presentation/screens/settings/privacy_policy_screen.dart';
import 'package:weeklet/presentation/screens/settings/settings_screen.dart';
import 'package:weeklet/presentation/screens/settings/terms_screen.dart';
import 'package:weeklet/presentation/screens/stats/stats_screen.dart';

class AppRoutes {
  static const home = '/';
  static const expensesScreen = '/expenses';
  static const categoriesScreen = '/categories';
  static const statsScreen = '/stats';
  static const settingsScreen = '/settings';
  static const incomeScreen = '/income';
  static const addCategoryScreen = '/add-category';
  static const privacyPolicyScreen = '/privacy-policy';
  static const termsScreen = '/terms';

  static Route<dynamic> onGenerateRoute(
    RouteSettings settings,
  ) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute<dynamic>(
          builder: (context) => const MainNavigation(),
        );
      case expensesScreen:
        return MaterialPageRoute<dynamic>(
          builder: (context) => const ExpensesScreen(),
        );
      case incomeScreen:
        return MaterialPageRoute<dynamic>(
          builder: (context) => const IncomeScreen(),
        );
      case categoriesScreen:
        return MaterialPageRoute<dynamic>(
          builder: (context) => const CategoriesScreen(),
        );
      case statsScreen:
        return MaterialPageRoute<dynamic>(
          builder: (context) => const StatsScreen(),
        );
      case settingsScreen:
        return MaterialPageRoute<dynamic>(
          builder: (context) => const SettingsScreen(),
        );
      case addCategoryScreen:
        return MaterialPageRoute<dynamic>(
          builder: (context) => const AddCategoryScreen(),
        );
      case privacyPolicyScreen:
        return MaterialPageRoute<dynamic>(
          builder: (context) => const PrivacyPolicyScreen(),
        );
      case termsScreen:
        return MaterialPageRoute<dynamic>(
          builder: (context) => const TermsScreen(),
        );
      default:
        return MaterialPageRoute<dynamic>(
          builder: (context) => const Scaffold(
            body: Center(
              child: Text('Route not found'),
            ),
          ),
        );
    }
  }
}
