import 'package:flutter/material.dart';
import 'package:fox/models/settings.dart';
import 'package:fox/services/box_names.dart';
import 'package:hive/hive.dart';

class SettingsService {
  static const _key = 'app_settings';

  Settings _memory = Settings(themeMode: 'system');

  Box<Settings>? get _box {
    try {
      if (!Hive.isBoxOpen(BoxNames.settings)) return null;
      return Hive.box<Settings>(BoxNames.settings);
    } catch (_) {
      return null;
    }
  }

  Settings _get() => _box?.get(_key) ?? _memory;

  Future<void> _update(Settings Function(Settings) update) async {
    final updated = update(_get());
    final box = _box;
    if (box != null) {
      await box.put(_key, updated);
    } else {
      _memory = updated;
    }
  }

  ThemeMode getThemeMode() => _get().theme;

  Future<void> setThemeMode(ThemeMode mode) async {
    final modeStr = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      _ => 'system',
    };
    await _update((s) => s.copyWith(themeMode: modeStr));
  }

  bool getShowTags() => _get().showTags;

  Future<void> setShowTags(bool show) async {
    await _update((s) => s.copyWith(showTags: show));
  }

  bool getShowContent() => _get().showContent;

  Future<void> setShowContent(bool show) async {
    await _update((s) => s.copyWith(showContent: show));
  }

  bool getAlternatingColors() => _get().alternatingColors;

  Future<void> setAlternatingColors(bool value) async {
    await _update((s) => s.copyWith(alternatingColors: value));
  }

  bool getFabAnimation() => _get().fabAnimation;

  Future<void> setFabAnimation(bool value) async {
    await _update((s) => s.copyWith(fabAnimation: value));
  }

  String getSortBy() => _get().sortBy;

  Future<void> setSortBy(String value) async {
    await _update((s) => s.copyWith(sortBy: value));
  }

  String? getAccentColor() => _get().accentColor;

  Future<void> setAccentColor(String? value) async {
    if (value == null) {
      await _update((s) => s.copyWith(clearAccentColor: true));
    } else {
      await _update((s) => s.copyWith(accentColor: value));
    }
  }

  String? getLocale() => _get().locale;

  Future<void> setLocale(String? value) async {
    if (value == null) {
      await _update((s) => s.copyWith(clearLocale: true));
    } else {
      await _update((s) => s.copyWith(locale: value));
    }
  }
}
