import 'package:flutter/material.dart';
import 'package:fox/models/settings.dart';
import 'package:fox/services/box_names.dart';
import 'package:hive/hive.dart';

class SettingsService {
  static const _key = 'app_settings';

  Box<Settings>? _cachedBox;
  Box<Settings> get _box =>
      _cachedBox ??= Hive.box<Settings>(BoxNames.settings);

  Settings _get() => _box.get(_key) ?? Settings(themeMode: 'system');

  Settings getSettings() => _get();

  Future<void> _update(Settings Function(Settings) update) async {
    await _box.put(_key, update(_get()));
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

  /// Returns the persisted accent colour hex (e.g. '#8B9A6B'), or `null` for
  /// the default green.
  String? getAccentColor() => _get().accentColor;

  /// Persists an accent colour override.  Pass `null` to revert to default.
  Future<void> setAccentColor(String? value) async {
    if (value == null) {
      await _update((s) => s.copyWith(clearAccentColor: true));
    } else {
      await _update((s) => s.copyWith(accentColor: value));
    }
  }

  /// Returns the persisted locale tag (e.g. 'en', 'pt_PT'), or `null` for
  /// system default.
  String? getLocale() => _get().locale;

  bool getAnalyticsEnabled() => _get().analyticsEnabled;

  Future<void> setAnalyticsEnabled(bool value) async {
    await _update((s) => s.copyWith(analyticsEnabled: value));
  }

  /// Persists a locale override.  Pass `null` to revert to system default.
  Future<void> setLocale(String? value) async {
    if (value == null) {
      await _update((s) => s.copyWith(clearLocale: true));
    } else {
      await _update((s) => s.copyWith(locale: value));
    }
  }
}
