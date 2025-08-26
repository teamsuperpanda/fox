import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _prefsKey = 'theme_mode';

  ThemeMode _themeMode = ThemeMode.system;

  ThemeProvider();

  /// Async factory to create and load saved theme mode.
  static Future<ThemeProvider> create() async {
    final provider = ThemeProvider();
    await provider._loadFromPreferences();
    return provider;
  }

  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    if (_themeMode == ThemeMode.light) {
      _themeMode = ThemeMode.dark;
    } else if (_themeMode == ThemeMode.dark) {
      _themeMode = ThemeMode.system;
    } else {
      _themeMode = ThemeMode.light;
    }
    _saveToPreferences();
    notifyListeners();
  }

  IconData getThemeIcon() {
    return switch (_themeMode) {
      ThemeMode.light => Icons.wb_sunny_outlined,
      ThemeMode.dark => Icons.nightlight_round,
      ThemeMode.system => Icons.brightness_auto,
    };
  }

  Future<void> _saveToPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final value = switch (_themeMode) {
        ThemeMode.light => 'light',
        ThemeMode.dark => 'dark',
        ThemeMode.system => 'system',
      };
      await prefs.setString(_prefsKey, value);
    } catch (_) {
      // ignore errors — persistence is best-effort
    }
  }

  Future<void> _loadFromPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final value = prefs.getString(_prefsKey);
      if (value == 'light') {
        _themeMode = ThemeMode.light;
      } else if (value == 'dark') {
        _themeMode = ThemeMode.dark;
      } else {
        _themeMode = ThemeMode.system;
      }
    } catch (_) {
      _themeMode = ThemeMode.system;
    }
  }
}
