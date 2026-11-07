import 'package:flutter/material.dart';
import 'package:fox/models/settings.dart';
import 'package:fox/services/box_names.dart';
import 'package:hive/hive.dart';

/// Single owner of persisted preferences.
///
/// Everything (theme, locale, view flags, sort order) is one [Settings]
/// value: read it with [settings], write the whole object with [save]. The
/// typed helpers are thin wrappers over those two so callers never hold a
/// second copy of a preference.
class SettingsService {
  static const _key = 'app_settings';

  Settings _memory = Settings(themeMode: 'system');

  /// Latest value passed to [save] before the box write completes, so a
  /// synchronous read straight after a write sees the new value.
  Settings? _pending;

  Box<Settings>? get _box {
    try {
      if (!Hive.isBoxOpen(BoxNames.settings)) return null;
      return Hive.box<Settings>(BoxNames.settings);
    } catch (_) {
      // Storage not ready: reads and writes fall back to the in-memory copy.
      return null;
    }
  }

  Settings get settings => _pending ?? _box?.get(_key) ?? _memory;

  Future<void> save(Settings settings) async {
    _pending = settings;
    final box = _box;
    try {
      if (box != null) {
        await box.put(_key, settings);
      } else {
        _memory = settings;
      }
    } finally {
      if (identical(_pending, settings)) _pending = null;
    }
  }

  ThemeMode getThemeMode() => settings.theme;

  Future<void> setThemeMode(ThemeMode mode) =>
      save(settings.copyWith(themeMode: mode.name));

  bool getShowTags() => settings.showTags;

  Future<void> setShowTags(bool show) =>
      save(settings.copyWith(showTags: show));

  bool getShowContent() => settings.showContent;

  Future<void> setShowContent(bool show) =>
      save(settings.copyWith(showContent: show));

  bool getAlternatingColors() => settings.alternatingColors;

  Future<void> setAlternatingColors(bool value) =>
      save(settings.copyWith(alternatingColors: value));

  bool getFabAnimation() => settings.fabAnimation;

  Future<void> setFabAnimation(bool value) =>
      save(settings.copyWith(fabAnimation: value));

  String getSortBy() => settings.sortBy;

  Future<void> setSortBy(String value) =>
      save(settings.copyWith(sortBy: value));

  String? getAccentColor() => settings.accentColor;

  Future<void> setAccentColor(String? value) => save(
        value == null
            ? settings.copyWith(clearAccentColor: true)
            : settings.copyWith(accentColor: value),
      );

  String? getLocale() => settings.locale;

  Future<void> setLocale(String? value) => save(
        value == null
            ? settings.copyWith(clearLocale: true)
            : settings.copyWith(locale: value),
      );
}
