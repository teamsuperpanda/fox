import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/settings.dart';
import 'box_names.dart';

class SettingsService {
  static const _key = 'app_settings';

  Box<Settings> get _box => Hive.box<Settings>(BoxNames.settings);

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
    await _box.put(_key, getSettings().copyWith(themeMode: modeStr));
  }

  bool getShowTags() => getSettings().showTags;

  Future<void> setShowTags(bool show) async {
    await _box.put(_key, getSettings().copyWith(showTags: show));
  }

  bool getShowContent() => getSettings().showContent;

  Future<void> setShowContent(bool show) async {
    await _box.put(_key, getSettings().copyWith(showContent: show));
  }

  bool getAlternatingColors() => getSettings().alternatingColors;

  Future<void> setAlternatingColors(bool value) async {
    await _box.put(_key, getSettings().copyWith(alternatingColors: value));
  }

  bool getFabAnimation() => getSettings().fabAnimation;

  Future<void> setFabAnimation(bool value) async {
    await _box.put(_key, getSettings().copyWith(fabAnimation: value));
  }

  String getSortBy() => getSettings().sortBy;

  Future<void> setSortBy(String value) async {
    await _box.put(_key, getSettings().copyWith(sortBy: value));
  }

  /// Returns the persisted accent colour hex (e.g. '#8B9A6B'), or `null` for
  /// the default green.
  String? getAccentColor() => getSettings().accentColor;

  /// Persists an accent colour override.  Pass `null` to revert to default.
  Future<void> setAccentColor(String? value) async {
    if (value == null) {
      await _box.put(_key, getSettings().copyWith(clearAccentColor: true));
    } else {
      await _box.put(_key, getSettings().copyWith(accentColor: value));
    }
  }

  /// Returns the persisted locale tag (e.g. 'en', 'pt_PT'), or `null` for
  /// system default.
  String? getLocale() => getSettings().locale;

  /// Persists a locale override.  Pass `null` to revert to system default.
  Future<void> setLocale(String? value) async {
    if (value == null) {
      await _box.put(_key, getSettings().copyWith(clearLocale: true));
    } else {
      await _box.put(_key, getSettings().copyWith(locale: value));
    }
  }
}
