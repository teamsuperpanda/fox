import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

class Settings extends HiveObject {
  final String themeMode; // 'system'|'light'|'dark'

  final String? locale;

  Settings({required this.themeMode, this.locale});

  ThemeMode get theme {
    return switch (themeMode) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }
}
