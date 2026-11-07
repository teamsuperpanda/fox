import 'package:flutter/material.dart';

class AppTheme {
  static const _fontFamily = 'Inter';

  static ThemeData light(Color accent) {
    final bg = Color.lerp(const Color(0xFFF8F5F1), accent, 0.06)!;
    return _build(
      brightness: Brightness.light,
      accent: accent,
      bg: bg,
      fg: const Color(0xFF333333),
      secondary: const Color(0xFFC7B8A5),
    );
  }

  static ThemeData dark(Color accent) {
    final bg = Color.lerp(const Color(0xFF202124), accent, 0.04)!;
    return _build(
      brightness: Brightness.dark,
      accent: accent,
      bg: bg,
      fg: const Color(0xFFF8F5F1),
      secondary: const Color(0xFFE8D5C2),
    );
  }

  static ThemeData _build({
    required Brightness brightness,
    required Color accent,
    required Color bg,
    required Color fg,
    required Color secondary,
  }) {
    return ThemeData(
      brightness: brightness,
      useMaterial3: true,
      fontFamily: _fontFamily,
      scaffoldBackgroundColor: bg,
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        foregroundColor: fg,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontFamily: _fontFamily,
          color: fg,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accent,
        foregroundColor: bg,
      ),
      textTheme: ThemeData(brightness: brightness).textTheme,
      colorScheme: _colorScheme(brightness, accent, secondary),
    );
  }

  /// WCAG AA friendly error colours. The Material defaults derived from a
  /// light seed can drop below 4.5:1 on our tinted backgrounds, so error and
  /// onError are pinned to a pair that passes in both themes.
  static ColorScheme _colorScheme(
    Brightness brightness,
    Color accent,
    Color secondary,
  ) {
    final base = ColorScheme.fromSeed(
      seedColor: accent,
      brightness: brightness,
    );
    final isLight = brightness == Brightness.light;
    return base.copyWith(
      secondary: secondary,
      error: isLight ? const Color(0xFFB3261E) : const Color(0xFFF2B8B5),
      onError: isLight ? Colors.white : const Color(0xFF601410),
    );
  }
}
