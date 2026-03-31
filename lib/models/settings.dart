import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

class Settings extends HiveObject {
  final String themeMode; // 'system'|'light'|'dark'

  final String? locale;
  final bool showTags;
  final bool showContent;
  final bool alternatingColors;
  final bool fabAnimation;
  final String sortBy; // 'dateDesc'|'dateAsc'|'titleAsc'|'titleDesc'
  final String? accentColor; // Hex string e.g. '#8B9A6B'

  Settings({
    required this.themeMode,
    this.locale,
    this.showTags = true,
    this.showContent = true,
    this.alternatingColors = false,
    this.fabAnimation = true,
    this.sortBy = 'dateDesc',
    this.accentColor,
  });

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
    );
  }
}
