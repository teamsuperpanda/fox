import 'package:flutter/material.dart';
import '../services/settings_service.dart';

/// Predefined accent colour options.  The first entry is the app default.
const List<Color> accentColorOptions = [
  Color(0xFF8B9A6B), // Sage green (default)
  Color(0xFF5B8DBE), // Steel blue
  Color(0xFFD4845A), // Terracotta
  Color(0xFF9B6B9E), // Plum
  Color(0xFFCB4B4B), // Crimson
  Color(0xFF4A9B8E), // Teal
  Color(0xFFD4A843), // Amber gold
  Color(0xFF6B7B8D), // Slate
  Color(0xFFE07BA0), // Rose
  Color(0xFF5C6BC0), // Indigo
];

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  Color _accentColor = accentColorOptions.first;

  ThemeMode get themeMode => _themeMode;
  Color get accentColor => _accentColor;
  
  /// Load persisted theme mode from shared preferences.
  Future<void> load() async {
    try {
      final service = SettingsService();
      _themeMode = service.getThemeMode();
      final hex = service.getAccentColor();
      if (hex != null && hex.length == 7) {
        try {
          _accentColor = Color(int.parse('FF${hex.substring(1)}', radix: 16));
        } catch (_) {}
      }
    } catch (_) {
      _themeMode = ThemeMode.system;
    }
  }

  /// Persist the current theme mode.
  Future<void> _save() async {
    try {
      final service = SettingsService();
      await service.setThemeMode(_themeMode);
    } catch (_) {}
  }

  void toggleTheme() {
    if (_themeMode == ThemeMode.light) {
      _themeMode = ThemeMode.dark;
    } else if (_themeMode == ThemeMode.dark) {
      _themeMode = ThemeMode.system;
    } else {
      _themeMode = ThemeMode.light;
    }
    // persist change (fire-and-forget)
    _save();
    notifyListeners();
  }

  /// Set a new accent colour and persist it.
  void setAccentColor(Color color) {
    _accentColor = color;
    try {
      final hex =
          '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
      // Fire-and-forget but swallow async Hive errors (e.g. in tests).
      SettingsService().setAccentColor(hex).catchError((_) {});
    } catch (_) {}
    notifyListeners();
  }

  IconData getThemeIcon() {
    return switch (_themeMode) {
      ThemeMode.light => Icons.wb_sunny_outlined,
      ThemeMode.dark => Icons.nightlight_round,
      ThemeMode.system => Icons.brightness_auto,
    };
  }
}
