import 'package:flutter/material.dart';
import 'package:fox/models/settings.dart';
import 'package:fox/services/repository_hive.dart';
import 'package:fox/services/settings_store.dart';

/// Persisted preferences.
///
/// Reads and writes go through the injected [SettingsStore]; the default is the
/// Hive store from the repository layer, so this service never touches Hive
/// directly.
class SettingsService {
  SettingsService({SettingsStore? store})
      : _store = store ?? HiveSettingsStore();

  final SettingsStore _store;

  Settings? _memory;

  /// Latest value passed to [save] before the store write completes, so a
  /// synchronous read straight after a write sees the new value.
  Settings? _pending;

  static final Settings _defaults = Settings(themeMode: 'system');

  Settings get settings => _pending ?? _store.read() ?? _memory ?? _defaults;

  Future<void> save(Settings settings) async {
    _pending = settings;
    try {
      await _store.write(settings);
      _memory = settings;
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
