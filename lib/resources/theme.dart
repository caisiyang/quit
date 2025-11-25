import 'package:flutter/material.dart';

class AppTheme {
  // Colors
  static const Color background = Color(0xFFF9F7F2); // Cream
  static const Color primary = Color(0xFFD48686); // Muted Red
  static const Color text = Color(0xFF4A4A4A); // Dark Grey
  static const Color surface = Colors.white;
  static const Color error = Color(0xFFB00020);

  // Dimensions
  static const double borderRadius = 20.0;
  static const double padding = 16.0;

  // Text Styles
  static const TextStyle heading1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: text,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: text,
  );

  static const TextStyle body = TextStyle(
    fontSize: 16,
    color: text,
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  // Theme Data
  static ThemeData get theme {
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
      fontFamily: 'Roboto', // Default, but good to specify if we had a custom one
      textTheme: const TextTheme(
        displayLarge: heading1,
        headlineMedium: heading2,
        bodyLarge: body,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0, // Flat or soft shadow
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          textStyle: buttonText,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: background,
        selectedItemColor: primary,
        unselectedItemColor: Colors.grey,
        elevation: 0,
      ),
    );
  }
}
