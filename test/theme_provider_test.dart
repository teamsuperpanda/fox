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

    test('getThemeIcon returns correct icons for each mode', () async {
      // Light mode
      await provider.toggleTheme(); // system -> light
      expect(provider.getThemeIcon(), equals(Icons.wb_sunny_outlined));

      // Dark mode
      await provider.toggleTheme(); // light -> dark
      expect(provider.getThemeIcon(), equals(Icons.nightlight_round));

      // System mode
      await provider.toggleTheme(); // dark -> system
      expect(provider.getThemeIcon(), equals(Icons.brightness_auto));
    });

    test('toggleTheme cycles through modes: system -> light -> dark -> system', () async {
      // Start at system
      expect(provider.themeMode, equals(ThemeMode.system));

      // Toggle to light
      await provider.toggleTheme();
      expect(provider.themeMode, equals(ThemeMode.light));

      // Toggle to dark
      await provider.toggleTheme();
      expect(provider.themeMode, equals(ThemeMode.dark));

      // Toggle back to system
      await provider.toggleTheme();
      expect(provider.themeMode, equals(ThemeMode.system));
    });

    test('toggleTheme notifies listeners', () async {
      var notified = false;
      provider.addListener(() {
        notified = true;
      });

      await provider.toggleTheme();
      expect(notified, isTrue);
    });

    test('load sets theme to system if SettingsService fails', () async {
      // Toggle to light mode first
      await provider.toggleTheme(); // system -> light
      expect(provider.themeMode, equals(ThemeMode.light));
      
      await provider.load();
      // Should fallback to system due to test environment
      expect(provider.themeMode, equals(ThemeMode.system));
    });

    test('multiple toggles work correctly', () async {
      final sequence = [
        ThemeMode.system,
        ThemeMode.light,
        ThemeMode.dark,
        ThemeMode.system,
        ThemeMode.light,
      ];

      for (var i = 0; i < sequence.length - 1; i++) {
        expect(provider.themeMode, equals(sequence[i]));
        await provider.toggleTheme();
      }
      expect(provider.themeMode, equals(sequence.last));
    });

    test('themeMode getter returns current theme mode', () async {
      await provider.toggleTheme(); // system -> light
      expect(provider.themeMode, equals(ThemeMode.light));

      await provider.toggleTheme(); // light -> dark
      expect(provider.themeMode, equals(ThemeMode.dark));
    });
  });
}
