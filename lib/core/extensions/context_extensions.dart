import 'package:flutter/material.dart';
import 'package:weeklet/core/theme/colors.dart';

extension ContextExtensions on BuildContext {
  // ThemeData & Colors
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => theme.colorScheme;
  TextTheme get textTheme => theme.textTheme;

  Color get primaryColor => theme.primaryColor;
  Color get scaffoldBackgroundColor => theme.scaffoldBackgroundColor;
  Color get successColor =>
      isDarkMode ? AppColors.darkSuccess : AppColors.lightSuccess;

  // MediaQuery - Size
  Size get screenSize => MediaQuery.of(this).size;
  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;

  bool get isPortrait => MediaQuery.orientationOf(this) == Orientation.portrait;
  bool get isLandscape =>
      MediaQuery.orientationOf(this) == Orientation.landscape;

  bool get isSmallScreen => screenWidth < 600;
  bool get isMediumScreen => screenWidth >= 600 && screenWidth < 840;
  bool get isLargeScreen => screenWidth >= 840;

  // MediaQuery - Padding & Insets
  EdgeInsets get padding => MediaQuery.paddingOf(this);
  EdgeInsets get viewInsets => MediaQuery.viewInsetsOf(this);
  double get bottomPadding => MediaQuery.paddingOf(this).bottom;
  double get topPadding => MediaQuery.paddingOf(this).top;
  double get leftPadding => MediaQuery.paddingOf(this).left;
  double get rightPadding => MediaQuery.paddingOf(this).right;

  double get bottomViewInset => MediaQuery.viewInsetsOf(
    this,
  ).bottom;
  double get topViewInset => MediaQuery.viewInsetsOf(this).top;

  // Device Properties
  double get devicePixelRatio =>
      MediaQuery.maybeDevicePixelRatioOf(
        this,
      ) ??
      1.0;
  double? get maybeDevicePixelRatio => MediaQuery.maybeDevicePixelRatioOf(
    this,
  );
  bool get isDarkMode => theme.brightness == Brightness.dark;
  bool get isLightMode => theme.brightness == Brightness.light;

  // Text Styles
  TextStyle? get displayLarge => textTheme.displayLarge;
  TextStyle? get displayMedium => textTheme.displayMedium;
  TextStyle? get displaySmall => textTheme.displaySmall;
  TextStyle? get headlineLarge => textTheme.headlineLarge;
  TextStyle? get headlineMedium => textTheme.headlineMedium;
  TextStyle? get headlineSmall => textTheme.headlineSmall;
  TextStyle? get titleLarge => textTheme.titleLarge;
  TextStyle? get titleMedium => textTheme.titleMedium;
  TextStyle? get titleSmall => textTheme.titleSmall;
  TextStyle? get bodyLarge => textTheme.bodyLarge;
  TextStyle? get bodyMedium => textTheme.bodyMedium;
  TextStyle? get bodySmall => textTheme.bodySmall;
  TextStyle? get labelLarge => textTheme.labelLarge;
  TextStyle? get labelMedium => textTheme.labelMedium;
  TextStyle? get labelSmall => textTheme.labelSmall;

  // Navigation
  Future<T?> push<T extends Object?>(
    Widget page,
  ) => Navigator.of(this).push<T>(
    MaterialPageRoute(
      builder: (_) => page,
    ),
  );

  Future<T?> pushNamed<T extends Object?>(
    String routeName, {
    Object? arguments,
  }) => Navigator.of(this).pushNamed<T>(
    routeName,
    arguments: arguments,
  );

  void pop<T extends Object?>([
    T? result,
  ]) {
    Navigator.of(this).pop<T>(result);
  }

  Future<T?> pushReplacementNamed<T extends Object?, TO extends Object?>(
    String routeName, {
    Object? arguments,
  }) => Navigator.of(this).pushReplacementNamed<T, TO>(
    routeName,
    arguments: arguments,
  );

  void popUntil(String routeName) {
    Navigator.of(this).popUntil(
      ModalRoute.withName(routeName),
    );
  }

  // Dialogs & Snackbars
  void showSnackBar(
    String message, {
    Duration duration = const Duration(
      seconds: 2,
    ),
  }) {
    ScaffoldMessenger.of(
      this,
    ).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
      ),
    );
  }

  void showErrorSnackBar(
    String message,
  ) {
    ScaffoldMessenger.of(
      this,
    ).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: colorScheme.error,
      ),
    );
  }

  void showSuccessSnackBar(
    String message,
  ) {
    ScaffoldMessenger.of(
      this,
    ).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<T?> showCustomDialog<T>({
    required Widget child,
    bool barrierDismissible = true,
  }) => showDialog<T>(
    context: this,
    barrierDismissible: barrierDismissible,
    builder: (_) => child,
  );

  // Focus
  void unfocus() => FocusScope.of(this).unfocus();

  // Localization
  Locale get locale => Localizations.localeOf(this);
  bool get isRussian => locale.languageCode == 'ru';
  bool get isEnglish => locale.languageCode == 'en';

  // Other
  ScaffoldMessengerState get scaffoldMessenger => ScaffoldMessenger.of(this);
}
