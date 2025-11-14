import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fox/providers/theme_provider.dart';

void main() {
  group('ThemeProvider', () {
    late ThemeProvider provider;

    setUp(() {
      provider = ThemeProvider();
    });

    test('initial theme mode is system', () {
      expect(provider.themeMode, equals(ThemeMode.system));
    });

    test('getThemeIcon returns correct icons for each mode', () {
      // Light mode
      provider.toggleTheme(); // system -> light
      expect(provider.getThemeIcon(), equals(Icons.wb_sunny_outlined));

      // Dark mode
      provider.toggleTheme(); // light -> dark
      expect(provider.getThemeIcon(), equals(Icons.nightlight_round));

      // System mode
      provider.toggleTheme(); // dark -> system
      expect(provider.getThemeIcon(), equals(Icons.brightness_auto));
    });

    test('toggleTheme cycles through modes: system -> light -> dark -> system', () {
      // Start at system
      expect(provider.themeMode, equals(ThemeMode.system));

      // Toggle to light
      provider.toggleTheme();
      expect(provider.themeMode, equals(ThemeMode.light));

      // Toggle to dark
      provider.toggleTheme();
      expect(provider.themeMode, equals(ThemeMode.dark));

      // Toggle back to system
      provider.toggleTheme();
      expect(provider.themeMode, equals(ThemeMode.system));
    });

    test('toggleTheme notifies listeners', () {
      bool notified = false;
      provider.addListener(() {
        notified = true;
      });

      provider.toggleTheme();
      expect(notified, isTrue);
    });

    test('load sets theme to system if SettingsService fails', () async {
      // Toggle to light mode first
      provider.toggleTheme(); // system -> light
      expect(provider.themeMode, equals(ThemeMode.light));
      
      await provider.load();
      // Should fallback to system due to test environment
      expect(provider.themeMode, equals(ThemeMode.system));
    });

    test('multiple toggles work correctly', () {
      final sequence = [
        ThemeMode.system,
        ThemeMode.light,
        ThemeMode.dark,
        ThemeMode.system,
        ThemeMode.light,
      ];

      for (int i = 0; i < sequence.length - 1; i++) {
        expect(provider.themeMode, equals(sequence[i]));
        provider.toggleTheme();
      }
      expect(provider.themeMode, equals(sequence.last));
    });

    test('themeMode getter returns current theme mode', () {
      provider.toggleTheme(); // system -> light
      expect(provider.themeMode, equals(ThemeMode.light));

      provider.toggleTheme(); // light -> dark
      expect(provider.themeMode, equals(ThemeMode.dark));
    });
  });
}
