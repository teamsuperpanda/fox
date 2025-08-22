import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    if (_themeMode == ThemeMode.light) {
      _themeMode = ThemeMode.dark;
    } else if (_themeMode == ThemeMode.dark) {
      _themeMode = ThemeMode.system;
    } else {
      _themeMode = ThemeMode.light;
    }
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
