import 'package:flutter/material.dart';

class AppTheme {
  // Dimensions
  static const double borderRadius = 20.0;
  static const double padding = 16.0;

  // Text Styles (Shared across themes)
  static const TextStyle heading1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: Color(0xFF4A4A4A),
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: Color(0xFF4A4A4A),
  );

  static const TextStyle body = TextStyle(
    fontSize: 16,
    color: Color(0xFF4A4A4A),
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  // Theme Definitions
  static final List<Map<String, Color>> _themes = [
    { // 0: Original (Muted Red)
      'primary': const Color(0xFFD48686),
      'background': const Color(0xFFF9F7F2),
    },
    { // 1: Ocean (Muted Blue)
      'primary': const Color(0xFF6B8E23), // Actually this is Olive, let's use a nice blue
      'background': const Color(0xFFF0F8FF),
    },
    { // 2: Forest (Muted Green)
      'primary': const Color(0xFF66CDAA),
      'background': const Color(0xFFF0FFF0),
    },
    { // 3: Sunset (Muted Orange)
      'primary': const Color(0xFFFFA07A),
      'background': const Color(0xFFFFF5EE),
    },
    { // 4: Lavender (Muted Purple)
      'primary': const Color(0xFF9370DB),
      'background': const Color(0xFFF8F8FF),
    },
  ];

  // Fix for Ocean color above, I put a comment but didn't change the hex code correctly in the map structure logic.
  // Let's define them properly in the getTheme method or a better structure.
  
  static ThemeData getTheme(int index) {
    final safeIndex = index.clamp(0, 4);
    
    Color primary;
    Color background;

    switch (safeIndex) {
      case 1: // Ocean
        primary = const Color(0xFF6495ED);
        background = const Color(0xFFF0F8FF);
        break;
      case 2: // Forest
        primary = const Color(0xFF66CDAA);
        background = const Color(0xFFF0FFF0);
        break;
      case 3: // Sunset
        primary = const Color(0xFFFFA07A);
        background = const Color(0xFFFFF5EE);
        break;
      case 4: // Lavender
        primary = const Color(0xFF9370DB);
        background = const Color(0xFFF8F8FF);
        break;
      case 0: // Original
      default:
        primary = const Color(0xFFD48686);
        background = const Color(0xFFF9F7F2);
        break;
    }

    const text = Color(0xFF4A4A4A);
    const surface = Colors.white;

    return ThemeData(
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        background: background,
        surface: surface,
        primary: primary,
        onPrimary: Colors.white,
        onSurface: text,
      ),
      useMaterial3: true,
      fontFamily: 'Roboto',
      textTheme: const TextTheme(
        displayLarge: heading1,
        headlineMedium: heading2,
        bodyLarge: body,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          textStyle: buttonText,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: background,
        selectedItemColor: primary,
        unselectedItemColor: Colors.grey,
        elevation: 0,
      ),
    );
  }

  // Helper to get current theme colors for custom widgets
  static Color getPrimaryColor(int index) {
    switch (index.clamp(0, 4)) {
      case 1: return const Color(0xFF6495ED);
      case 2: return const Color(0xFF66CDAA);
      case 3: return const Color(0xFFFFA07A);
      case 4: return const Color(0xFF9370DB);
      default: return const Color(0xFFD48686);
    }
  }
  
  // Static accessors for default theme (backward compatibility if needed, though we should use provider)
  static const Color primary = Color(0xFFD48686);
  static const Color text = Color(0xFF4A4A4A);
  static const Color background = Color(0xFFF9F7F2);
}
