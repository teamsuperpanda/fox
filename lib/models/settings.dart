import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

class Settings extends HiveObject {
  final String themeMode; // 'system'|'light'|'dark'

  final String? locale;
  final bool showTags;
  final bool showContent;
  final bool alternatingColors;
  final bool fabAnimation;

  Settings({
    required this.themeMode,
    this.locale,
    this.showTags = true,
    this.showContent = true,
    this.alternatingColors = false,
    this.fabAnimation = true,
  });

  ThemeMode get theme {
    return switch (themeMode) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Settings copyWith({
    String? themeMode,
    String? locale,
    bool? showTags,
    bool? showContent,
    bool? alternatingColors,
    bool? fabAnimation,
  }) {
    return Settings(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
      showTags: showTags ?? this.showTags,
      showContent: showContent ?? this.showContent,
      alternatingColors: alternatingColors ?? this.alternatingColors,
      fabAnimation: fabAnimation ?? this.fabAnimation,
    );
  }
}
