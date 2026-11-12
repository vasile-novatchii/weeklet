import 'package:flutter/material.dart';
import 'package:weeklet/core/theme/colors.dart';

class AppTheme {
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: .light,
    scaffoldBackgroundColor: AppColors.lightBackground,
    colorScheme: const ColorScheme.light(
      // Primary Color
      primary: AppColors.lightPrimaryColor,
      onPrimary: AppColors.lightOnPrimaryColor,

      // Surface Colors
      surface: AppColors.lightSurface,
      onSurface: AppColors.lightOnSurface,
      surfaceContainerHighest: AppColors.lightSurfaceVariant,
      onSurfaceVariant: AppColors.lightOnSurfaceVariant,

      // Secondary/Tertiary Colors
      secondary: AppColors.lightSecondarySurface,
      onSecondary: AppColors.lightOnSecondarySurface,
      tertiary: AppColors.lightTertiary,
      onTertiary: AppColors.lightOnTertiary,
      error: AppColors.lightError,
      onError: AppColors.lightOnError,

      // Utility
      outline: AppColors.lightOutline,
      scrim: Colors.black54,
    ),

    // AppBar Theme
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: AppColors.lightAppSurface,
      foregroundColor: AppColors.lightOnAppSurface,
      titleTextStyle: TextStyle(
        color: AppColors.lightOnAppSurface,
        fontSize: 20,
        fontWeight: .w600,
      ),
      iconTheme: IconThemeData(
        color: AppColors.lightOnAppSurface,
      ),
    ),

    // Text Theme
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: AppColors.lightOnBackground,
        fontSize: 32,
        fontWeight: .w700,
      ),
      displayMedium: TextStyle(
        color: AppColors.lightOnBackground,
        fontSize: 28,
        fontWeight: .w700,
      ),
      bodyMedium: TextStyle(
        color: AppColors.lightOnBackground,
        fontSize: 14,
        fontWeight: .w400,
      ),
      bodySmall: TextStyle(
        color: AppColors.lightOnSurfaceVariant, // Muted text
        fontSize: 12,
        fontWeight: .w400,
      ),
      labelMedium: TextStyle(
        color: AppColors.lightOnBackground,
        fontSize: 12,
        fontWeight: .w500,
      ),
      labelSmall: TextStyle(
        color: AppColors.lightOnSurfaceVariant, // Muted text
        fontSize: 11,
        fontWeight: .w500,
      ),
    ),

    // Card Theme
    cardTheme: CardThemeData(
      color: AppColors.lightSurface,
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),

    // Input/TextField Theme
    inputDecorationTheme: InputDecorationTheme(
      floatingLabelBehavior: FloatingLabelBehavior.never,
      filled: true,
      fillColor: AppColors.lightInputFill,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: AppColors.lightOutline,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: AppColors.lightPrimaryColor,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: AppColors.lightError,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          8,
        ),
        borderSide: const BorderSide(
          color: AppColors.lightError,
        ),
      ),
      labelStyle: const TextStyle(
        color: AppColors.lightOnSurfaceVariant,
      ),
      hintStyle: const TextStyle(
        color: AppColors.lightSurfaceVariant,
      ),
    ),

    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 24,
        ),
        backgroundColor: AppColors.lightPrimaryColor,
        foregroundColor: AppColors.lightOnPrimaryColor,
        disabledBackgroundColor: AppColors.lightSurfaceVariant,
        disabledForegroundColor: AppColors.lightOnSurfaceVariant,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        enableFeedback: true,
      ),
    ),

    // Text Button Theme (Text is Primary/Purple)
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.lightPrimaryColor,
        enableFeedback: true,
      ),
    ),

    // Icon Button Theme (Icon is Primary/Purple)
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: AppColors.lightPrimaryColor,
        enableFeedback: true,
      ),
    ),

    // FloatingActionButton Theme
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.lightPrimaryColor,
      foregroundColor: AppColors.lightOnPrimaryColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          12,
        ),
      ),
      enableFeedback: true,
    ),

    // BottomNavigationBar Theme
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.lightBackground,
      selectedItemColor: AppColors.lightPrimaryColor,
      unselectedItemColor: AppColors.lightOnSurfaceVariant,
      elevation: 10,
      enableFeedback: true,
    ),

    // Dialog Theme
    dialogTheme: const DialogThemeData(
      backgroundColor: AppColors.lightSurface,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(12),
        ),
      ),
    ),

    // Divider Theme
    dividerTheme: const DividerThemeData(
      color: AppColors.lightOutline,
      thickness: 1,
    ),
  );

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: .dark,
    scaffoldBackgroundColor: AppColors.darkBackground,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.darkPrimaryColor,
      onPrimary: AppColors.darkOnPrimaryColor,

      // Surface Colors
      surface: AppColors.darkSurface,
      onSurface: AppColors.darkOnSurface,
      surfaceContainerHighest: AppColors.darkSurfaceVariant,
      onSurfaceVariant: AppColors.darkOnSurfaceVariant,

      // Secondary/Tertiary Colors
      secondary: AppColors.darkSecondarySurface,
      onSecondary: AppColors.darkOnSecondarySurface,
      tertiary: AppColors.darkTertiary,
      onTertiary: AppColors.darkOnTertiary,
      error: AppColors.darkError,
      onError: AppColors.darkOnError,

      // Utility
      outline: AppColors.darkOutline,
      scrim: Colors.black54,
    ),

    // AppBar Theme
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: AppColors.darkAppSurface,
      foregroundColor: AppColors.darkOnAppSurface,
      titleTextStyle: TextStyle(
        color: AppColors.darkOnAppSurface,
        fontSize: 20,
        fontWeight: .w600,
      ),
      iconTheme: IconThemeData(
        color: AppColors.darkOnAppSurface,
      ),
    ),

    // Text Theme
    textTheme: const TextTheme(
      bodyMedium: TextStyle(
        color: AppColors.darkOnBackground,
        fontSize: 14,
        fontWeight: .w400,
      ),
      bodySmall: TextStyle(
        color: AppColors.darkOnSurfaceVariant, // Muted text
        fontSize: 12,
        fontWeight: .w400,
      ),
      labelMedium: TextStyle(
        color: AppColors.darkOnBackground,
        fontSize: 12,
        fontWeight: .w500,
      ),
      labelSmall: TextStyle(
        color: AppColors.darkOnSurfaceVariant, // Muted text
        fontSize: 11,
        fontWeight: .w500,
      ),
    ),

    // Card Theme
    cardTheme: const CardThemeData(
      color: AppColors.darkSurface,
      elevation: 2,
      shadowColor: Colors.black54,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(12),
        ),
      ),
    ),

    // Input/TextField Theme
    inputDecorationTheme: InputDecorationTheme(
      floatingLabelBehavior: FloatingLabelBehavior.never,
      filled: true,
      fillColor: AppColors.darkInputFill,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: AppColors.darkOutline,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: AppColors.darkOnBackground,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: AppColors.darkError,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          8,
        ),
        borderSide: const BorderSide(
          color: AppColors.darkError,
        ),
      ),
      labelStyle: const TextStyle(
        color: AppColors.darkOnSurfaceVariant,
      ),
      hintStyle: const TextStyle(
        color: AppColors.darkSurfaceVariant,
      ),
    ),

    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 24,
        ),
        backgroundColor: AppColors.darkPrimaryColor,
        foregroundColor: AppColors.darkOnPrimaryColor,
        disabledBackgroundColor: AppColors.darkSurfaceVariant,
        disabledForegroundColor: AppColors.darkOnSurfaceVariant,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        enableFeedback: true,
      ),
    ),

    // Text Button Theme (Text is Primary/Purple)
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.darkPrimaryColor,
        enableFeedback: true,
      ),
    ),

    // Icon Button Theme (Icon is Primary/Purple)
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: AppColors.darkPrimaryColor,
        enableFeedback: true,
      ),
    ),

    // FloatingActionButton Theme
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.lightPrimaryColor,
      foregroundColor: AppColors.lightOnPrimaryColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          12,
        ),
      ),
      enableFeedback: true,
    ),

    // BottomNavigationBar Theme
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.darkBackground,
      selectedItemColor: AppColors.darkPrimaryColor,
      unselectedItemColor: AppColors.darkOnSurfaceVariant,
      elevation: 10,
      enableFeedback: true,
    ),

    // Dialog Theme
    dialogTheme: const DialogThemeData(
      backgroundColor: AppColors.darkBackground,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(12),
        ),
      ),
    ),

    // Divider Theme
    dividerTheme: const DividerThemeData(
      color: AppColors.darkOutline,
      thickness: 1,
    ),
  );
}
