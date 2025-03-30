import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      fontFamily: 'Lufga',
      useMaterial3: true,
      primaryColor: const Color(0xFF212121),
      scaffoldBackgroundColor: Colors.white,
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF212121),
        onPrimary: Colors.white,
        secondary: Color(0xFF808080),
        surface: Colors.white,
        outline: Color(0xFFD4D4D4),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Color(0xFF585656)),
        bodyMedium: TextStyle(color: Color(0xFF585656)),
        titleMedium: TextStyle(color: Color(0xFF585656)),
      ),
    );
  }
}