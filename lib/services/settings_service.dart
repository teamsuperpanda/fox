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

  dynamic _getValue(String key, {dynamic defaultValue}) {
    final settings = _get();
    return switch (key) {
      'themeMode' => settings.themeMode,
      'showTags' => settings.showTags,
      'showContent' => settings.showContent,
      'alternatingColors' => settings.alternatingColors,
      'fabAnimation' => settings.fabAnimation,
      'sortBy' => settings.sortBy,
      'accentColor' => settings.accentColor,
      'selectedFolderId' => settings.selectedFolderId,
      'folderSorts' => settings.folderSorts,
      'locale' => settings.locale,
      _ => defaultValue,
    };
  }

  Future<void> _setValue(String key, dynamic value) async {
    switch (key) {
      case 'themeMode':
        await _update((s) => s.copyWith(themeMode: value as String));
      case 'showTags':
        await _update((s) => s.copyWith(showTags: value as bool));
      case 'showContent':
        await _update((s) => s.copyWith(showContent: value as bool));
      case 'alternatingColors':
        await _update((s) => s.copyWith(alternatingColors: value as bool));
      case 'fabAnimation':
        await _update((s) => s.copyWith(fabAnimation: value as bool));
      case 'sortBy':
        await _update((s) => s.copyWith(sortBy: value as String));
      case 'accentColor':
        await _update((s) => value == null
            ? s.copyWith(clearAccentColor: true)
            : s.copyWith(accentColor: value as String));
      case 'locale':
        await _update((s) => value == null
            ? s.copyWith(clearLocale: true)
            : s.copyWith(locale: value as String));
      case 'selectedFolderId':
        await _update((s) => value == null
            ? s.copyWith(clearSelectedFolder: true)
            : s.copyWith(selectedFolderId: value as String));
      case 'folderSorts':
        await _update(
            (s) => s.copyWith(folderSorts: value as Map<String, String>));
    }
  }

  ThemeMode getThemeMode() => _get().theme;

  Future<void> setThemeMode(ThemeMode mode) async {
    await _setValue('themeMode', mode.name);
  }

  bool getShowTags() => _getValue('showTags', defaultValue: true) as bool;

  Future<void> setShowTags(bool show) async {
    await _setValue('showTags', show);
  }

  bool getShowContent() => _getValue('showContent', defaultValue: true) as bool;

  Future<void> setShowContent(bool show) async {
    await _setValue('showContent', show);
  }

  bool getAlternatingColors() =>
      _getValue('alternatingColors', defaultValue: false) as bool;

  Future<void> setAlternatingColors(bool value) async {
    await _setValue('alternatingColors', value);
  }

  bool getFabAnimation() =>
      _getValue('fabAnimation', defaultValue: true) as bool;

  Future<void> setFabAnimation(bool value) async {
    await _setValue('fabAnimation', value);
  }

  String getSortBy() => _getValue('sortBy', defaultValue: 'dateDesc') as String;

  Future<void> setSortBy(String value) async {
    await _setValue('sortBy', value);
  }

  String? getAccentColor() => _getValue('accentColor') as String?;

  Future<void> setAccentColor(String? value) async {
    await _setValue('accentColor', value);
  }

  String? getLocale() => _getValue('locale') as String?;

  Future<void> setLocale(String? value) async {
    await _setValue('locale', value);
  }

  String? getSelectedFolderId() => _getValue('selectedFolderId') as String?;

  Future<void> setSelectedFolderId(String? value) async {
    await _setValue('selectedFolderId', value);
  }

  Map<String, String> getFolderSorts() {
    final value = _getValue('folderSorts');
    if (value is Map<String, String>) return value;
    if (value is Map) {
      return {
        for (final entry in value.entries)
          entry.key.toString(): entry.value.toString(),
      };
    }
    return const <String, String>{};
  }

  String? getFolderSort(String folderId) => getFolderSorts()[folderId];

  Future<void> setFolderSort(String folderId, String sortBy) async {
    await _update(
      (s) => s.copyWith(
        folderSorts: {...s.folderSorts, folderId: sortBy},
      ),
    );
  }

  Future<void> clearFolderSort(String folderId) async {
    await _update(
      (s) => s.copyWith(
        folderSorts: {
          for (final entry in s.folderSorts.entries)
            if (entry.key != folderId) entry.key: entry.value,
        },
      ),
    );
  }
}
