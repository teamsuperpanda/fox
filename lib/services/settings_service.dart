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
}
