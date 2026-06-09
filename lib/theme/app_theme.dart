import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData light(Color accent) {
    const base = Color(0xFFF8F5F1);
    final bg = Color.lerp(base, accent, 0.06)!;

    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Inter',
      scaffoldBackgroundColor: bg,
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        foregroundColor: const Color(0xFF333333),
        elevation: 0,
        titleTextStyle: const TextStyle(
          fontFamily: 'Inter',
          color: Color(0xFF333333),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accent,
        foregroundColor: bg,
      ),
      textTheme: ThemeData.light().textTheme,
      colorScheme: ColorScheme.fromSeed(
        seedColor: accent,
      ).copyWith(
        secondary: const Color(0xFFC7B8A5),
        error: const Color(0xFFD9534F),
      ),
    );
  }

  static ThemeData dark(Color accent) {
    const base = Color(0xFF202124);
    final bg = Color.lerp(base, accent, 0.04)!;

    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      fontFamily: 'Inter',
      scaffoldBackgroundColor: bg,
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        foregroundColor: const Color(0xFFF8F5F1),
        elevation: 0,
        titleTextStyle: const TextStyle(
          fontFamily: 'Inter',
          color: Color(0xFFF8F5F1),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accent,
        foregroundColor: bg,
      ),
      textTheme: ThemeData.dark().textTheme,
      colorScheme: ColorScheme.fromSeed(
        seedColor: accent,
        brightness: Brightness.dark,
      ).copyWith(
        secondary: const Color(0xFFE8D5C2),
        error: const Color(0xFFD9534F),
      ),
    );
  }
}
