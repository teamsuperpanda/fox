import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fox/models/note_colors.dart';
import 'package:fox/services/settings_service.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeProvider({SettingsService? settingsRepository})
      : _settingsRepository = settingsRepository ?? SettingsService();

  final SettingsService _settingsRepository;
  ThemeMode _themeMode = ThemeMode.system;
  Color _accentColor = accentColorOptions.first;

  ThemeMode get themeMode => _themeMode;
  Color get accentColor => _accentColor;

  /// Load persisted theme mode from shared preferences.
  Future<void> load() async {
    try {
      _themeMode = _settingsRepository.getThemeMode();
      final accentColor = parseHexColor(_settingsRepository.getAccentColor());
      if (accentColor != null) _accentColor = accentColor;
    } catch (e) {
      debugPrint('ThemeProvider: failed to load theme: $e');
      _themeMode = ThemeMode.system;
    }
  }

  /// Persist the current theme mode.
  Future<void> _save() async {
    try {
      await _settingsRepository.setThemeMode(_themeMode);
    } catch (e) {
      debugPrint('ThemeProvider: failed to save theme: $e');
    }
  }

  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.light) {
      _themeMode = ThemeMode.dark;
    } else if (_themeMode == ThemeMode.dark) {
      _themeMode = ThemeMode.system;
    } else {
      _themeMode = ThemeMode.light;
    }
    await _save();
    notifyListeners();
  }

  /// Set a new accent colour and persist it.
  void setAccentColor(Color color) {
    _accentColor = color;
    try {
      final hex = colorToHex(color);
      // Fire-and-forget but swallow async Hive errors (e.g. in tests).
      unawaited(_settingsRepository.setAccentColor(hex).catchError((Object e) {
        debugPrint('ThemeProvider: failed to persist accent color: $e');
      }));
    } catch (e) {
      debugPrint('ThemeProvider: failed to set accent color: $e');
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
