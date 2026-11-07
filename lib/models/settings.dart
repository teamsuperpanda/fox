import 'package:flutter/material.dart';

class Settings {
  Settings({
    required this.themeMode,
    this.locale,
    this.showTags = true,
    this.showContent = true,
    this.alternatingColors = false,
    this.fabAnimation = true,
    this.sortBy = 'dateDesc',
    this.accentColor,
    this.selectedFolderId,
    this.folderSorts = const <String, String>{},
  });
  final String themeMode; // 'system'|'light'|'dark'

  final String? locale;
  final bool showTags;
  final bool showContent;
  final bool alternatingColors;
  final bool fabAnimation;
  final String sortBy; // 'dateDesc'|'dateAsc'|'titleAsc'|'titleDesc'
  // Hex string e.g. '#8B9A6B'
  final String? accentColor;

  /// Last folder filter the user selected, restored on the next launch.
  final String? selectedFolderId;

  /// Per-folder sort overrides, keyed by folder id.
  final Map<String, String> folderSorts;

  ThemeMode get theme {
    return switch (themeMode) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  /// Sentinel used to explicitly clear the nullable [locale] field via
  /// [copyWith].  Pass `clearLocale: true` to set locale to `null`.
  Settings copyWith({
    String? themeMode,
    String? locale,
    bool clearLocale = false,
    bool? showTags,
    bool? showContent,
    bool? alternatingColors,
    bool? fabAnimation,
    String? sortBy,
    String? accentColor,
    bool clearAccentColor = false,
    String? selectedFolderId,
    bool clearSelectedFolder = false,
    Map<String, String>? folderSorts,
  }) {
    return Settings(
      themeMode: themeMode ?? this.themeMode,
      locale: clearLocale ? null : (locale ?? this.locale),
      showTags: showTags ?? this.showTags,
      showContent: showContent ?? this.showContent,
      alternatingColors: alternatingColors ?? this.alternatingColors,
      fabAnimation: fabAnimation ?? this.fabAnimation,
      sortBy: sortBy ?? this.sortBy,
      accentColor: clearAccentColor ? null : (accentColor ?? this.accentColor),
      selectedFolderId: clearSelectedFolder
          ? null
          : (selectedFolderId ?? this.selectedFolderId),
      folderSorts: folderSorts ?? this.folderSorts,
    );
  }
}
