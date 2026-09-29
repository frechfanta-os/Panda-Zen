import 'package:flutter/material.dart';

class GameTheme {
  GameTheme._();

  static ThemeData get zenTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFFF9F6F0),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF4CAF50),
        primary: const Color(0xFF388E3C),
        secondary: const Color(0xFF8D6E63),
        surface: const Color(0xFFFFF8E1),
      ),
      fontFamily: null, // Use system font with clean typography
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          color: Color(0xFF2E7D32),
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: TextStyle(
          color: Color(0xFF3E2723),
        ),
      ),
    );
  }
}
