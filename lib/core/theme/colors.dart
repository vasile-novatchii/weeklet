import 'dart:ui' show Color;

class AppColors {
  factory AppColors() => _instance;
  AppColors._internal();
  static final AppColors _instance = AppColors._internal();

  // --- LIGHT MODE ---
  // Background Colors
  static const lightBackground = Color(0xFFFEFEFE);
  static const lightOnBackground = Color(0xFF262626); // Text on background

  // Surface Colors (Cards, Dialogs)
  static const lightSurface = Color(0xFFF0EDED);
  static const lightOnSurface = Color(0xFF262626); // Text on surface

  // Primary Color (Modern Purple - Applied to main buttons, accents)
  static const lightPrimaryColor = Color(0xFF1447E6);
  static const lightOnPrimaryColor = Color(0xFFFFFFFF); // Text on primary color

  // Secondary/Surface Variant Colors
  static const lightSecondarySurface = Color(0xFFF2F2F5);
  static const lightOnSecondarySurface = Color(0xFF030213);
  static const lightSurfaceVariant = Color(0xFF959AA5); // Muted surface
  static const lightOnSurfaceVariant = Color(0xFF878B93); // Muted text

  // Tertiary Colors (Accent)
  static const lightTertiary = Color(0xFF030213);
  static const lightOnTertiary = Color(0xFFFFFFFF);

  // Success Colors (Income)
  static const lightSuccess = Color(0xFF16A34A);
  static const darkSuccess = Color(0xFF4ADE80);

  // Error and Utility
  static const lightError = Color(0xFFD4183D);
  static const lightOnError = Color(0xFFFFFFFF);
  static const lightOutline = Color(0xFFE6E6E6); // Border color
  static const lightInputFill = Color(0xFFF3F3F5); // Input fill color
  static const lightRing = Color(0xFFB5B5B5);

  // App-specific Colors (AppBar, Sidebar, NavBar)
  static const lightAppSurface = Color(0xFF1447E6); // AppBar/Sidebar background
  static const lightOnAppSurface = Color(0xFFFFFFFF); // Text on AppBar/Sidebar

  // --- DARK MODE ---
  // Background Colors
  static const darkBackground = Color.fromARGB(255, 16, 24, 40);
  static const darkOnBackground = Color(0xFFFAFAFA);

  // Surface Colors (Cards, Dialogs)
  static const darkSurface = Color.fromARGB(255, 30, 41, 57);
  static const darkOnSurface = Color(0xFFFAFAFA);

  // Primary Color (Vibrant Purple - Applied to main buttons, accents)
  static const darkPrimaryColor = Color(0xFF51A2FF);
  static const darkOnPrimaryColor = Color(
    0xFF1A1A1A,
  ); // Text on primary color (Black for contrast)

  // Secondary/Surface Variant Colors
  static const darkSecondarySurface = Color(0xFF454545);
  static const darkOnSecondarySurface = Color(0xFFFAFAFA);
  static const darkSurfaceVariant = Color(0xFF959AA5); // Muted surface
  static const darkOnSurfaceVariant = Color(0xFFB5B5B5); // Muted text

  // Tertiary Colors (Accent)
  static const darkTertiary = Color(0xFFFAFAFA);
  static const darkOnTertiary = Color(0xFF1A1A1A);

  // Error and Utility
  static const darkError = Color.fromARGB(255, 209, 84, 84);
  static const darkOnError = Color(0xFFD4A5A5);
  static const darkOutline = Color(0xFF4A5565); // Border color
  static const darkInputFill = Color(0xFF364153); // Input fill color
  static const darkRing = Color(0xFF707070);

  // App-specific Colors (AppBar, Sidebar, NavBar)
  static const darkAppSurface = Color(0xFF1447E6); // AppBar/Sidebar background
  static const darkOnAppSurface = Color(0xFFFAFAFA); // Text on AppBar/Sidebar
}
