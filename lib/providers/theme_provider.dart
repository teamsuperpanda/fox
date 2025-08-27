import 'package:flutter/material.dart';
import '../services/settings_service.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;
  
  /// Load persisted theme mode from shared preferences.
  Future<void> load() async {
    try {
      final service = SettingsService();
      _themeMode = service.getThemeMode();
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

  IconData getThemeIcon() {
    return switch (_themeMode) {
      ThemeMode.light => Icons.wb_sunny_outlined,
      ThemeMode.dark => Icons.nightlight_round,
      ThemeMode.system => Icons.brightness_auto,
    };
  }
}
