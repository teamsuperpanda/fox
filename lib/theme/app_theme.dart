import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData light(Color accent) {
    // Blend a subtle accent wash into the warm base background.
    final base = const Color(0xFFF8F5F1);
    final bg = Color.lerp(base, accent, 0.06)!;

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: bg,
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        foregroundColor: const Color(0xFF333333),
        elevation: 0,
        titleTextStyle: GoogleFonts.inter(
          textStyle: const TextStyle(
            color: Color(0xFF333333),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accent,
        foregroundColor: bg,
      ),
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.light().textTheme,
      ),
      colorScheme: ColorScheme.fromSeed(
        seedColor: accent,
        brightness: Brightness.light,
      ).copyWith(
        secondary: const Color(0xFFC7B8A5),
        error: const Color(0xFFD9534F),
      ),
    );
  }

  static ThemeData dark(Color accent) {
    // Blend a very subtle accent wash into the dark base background.
    final base = const Color(0xFF202124);
    final bg = Color.lerp(base, accent, 0.04)!;

    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      scaffoldBackgroundColor: bg,
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        foregroundColor: const Color(0xFFF8F5F1),
        elevation: 0,
        titleTextStyle: GoogleFonts.inter(
          textStyle: const TextStyle(
            color: Color(0xFFF8F5F1),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accent,
        foregroundColor: bg,
      ),
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.dark().textTheme,
      ),
      colorScheme: ColorScheme.fromSeed(
        seedColor: accent,
        brightness: Brightness.dark,
      ).copyWith(
        secondary: const Color(0xFFC7B8A5),
        error: const Color(0xFFD9534F),
      ),
    );
  }
}
