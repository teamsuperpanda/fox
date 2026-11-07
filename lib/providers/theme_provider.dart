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
      // Loading is best effort: fall back to the default theme in memory.
      debugPrint('ThemeProvider: failed to load theme: $e');
      _themeMode = ThemeMode.system;
    }
  }

  /// Persist the current theme mode. Returns false when the write failed.
  Future<bool> _save() async {
    try {
      await _settingsRepository.setThemeMode(_themeMode);
      return true;
    } catch (e) {
      debugPrint('ThemeProvider: failed to save theme: $e');
      return false;
    }
  }

  Future<bool> toggleTheme() async {
    if (_themeMode == ThemeMode.light) {
      _themeMode = ThemeMode.dark;
    } else if (_themeMode == ThemeMode.dark) {
      _themeMode = ThemeMode.system;
    } else {
      _themeMode = ThemeMode.light;
    }
    final saved = await _save();
    notifyListeners();
    return saved;
  }

  /// Set a new accent colour and persist it. Returns false when the write
  /// failed; the colour still applies for the rest of the session.
  Future<bool> setAccentColor(Color color) async {
    _accentColor = color;
    var saved = true;
    try {
      await _settingsRepository.setAccentColor(colorToHex(color));
    } catch (e) {
      saved = false;
      debugPrint('ThemeProvider: failed to persist accent color: $e');
    }
    notifyListeners();
    return saved;
  }

  IconData getThemeIcon() {
    return switch (_themeMode) {
      ThemeMode.light => Icons.wb_sunny_outlined,
      ThemeMode.dark => Icons.nightlight_round,
      ThemeMode.system => Icons.brightness_auto,
    };
  }
}
