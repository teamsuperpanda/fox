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
    final current = getSettings();
    final settings = Settings(
      themeMode: modeStr,
      locale: current.locale,
      showTags: current.showTags,
      showContent: current.showContent,
      alternatingColors: current.alternatingColors,
      fabAnimation: current.fabAnimation,
    );
    await _box.put(_key, settings);
  }

  bool getShowTags() => getSettings().showTags;

  Future<void> setShowTags(bool show) async {
    final current = getSettings();
    final settings = Settings(
      themeMode: current.themeMode,
      locale: current.locale,
      showTags: show,
      showContent: current.showContent,
      alternatingColors: current.alternatingColors,
      fabAnimation: current.fabAnimation,
    );
    await _box.put(_key, settings);
  }

  bool getShowContent() => getSettings().showContent;

  Future<void> setShowContent(bool show) async {
    final current = getSettings();
    final settings = Settings(
      themeMode: current.themeMode,
      locale: current.locale,
      showTags: current.showTags,
      showContent: show,
      alternatingColors: current.alternatingColors,
      fabAnimation: current.fabAnimation,
    );
    await _box.put(_key, settings);
  }

  bool getAlternatingColors() => getSettings().alternatingColors;

  Future<void> setAlternatingColors(bool value) async {
    final current = getSettings();
    final settings = Settings(
      themeMode: current.themeMode,
      locale: current.locale,
      showTags: current.showTags,
      showContent: current.showContent,
      alternatingColors: value,
      fabAnimation: current.fabAnimation,
    );
    await _box.put(_key, settings);
  }

  bool getFabAnimation() => getSettings().fabAnimation;

  Future<void> setFabAnimation(bool value) async {
    final current = getSettings();
    final settings = Settings(
      themeMode: current.themeMode,
      locale: current.locale,
      showTags: current.showTags,
      showContent: current.showContent,
      alternatingColors: current.alternatingColors,
      fabAnimation: value,
    );
    await _box.put(_key, settings);
  }
}
