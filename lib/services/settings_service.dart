import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/settings.dart';

class SettingsService {
  static const _boxName = 'settings_db';
  static const _key = 'app_settings';

  Box<Settings> get _box => Hive.box<Settings>(_boxName);

  Settings getSettings() {
    return _box.get(_key) ?? Settings(themeMode: 'system');
  }

  ThemeMode getThemeMode() => getSettings().theme;

  Future<void> setThemeMode(ThemeMode mode) async {
    final modeStr = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      _ => 'system',
    };
    final settings = Settings(themeMode: modeStr, locale: getSettings().locale);
    await _box.put(_key, settings);
  }
}
