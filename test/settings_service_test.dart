import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:fox/models/settings.dart';
import 'package:fox/models/settings_adapter.dart';
import 'package:fox/services/settings_service.dart';

void main() {
  group('SettingsService', () {
    late SettingsService settingsService;

    setUpAll(() async {
      // Initialize Hive for testing
      Hive.init('./test/hive_settings_test');
      if (!Hive.isAdapterRegistered(2)) {
        Hive.registerAdapter(SettingsAdapter());
      }
    });

    setUp(() async {
      // Open a test box before each test  
      await Hive.openBox<Settings>('settings_db');
      settingsService = SettingsService();
      
      // Clear any existing data
      final box = Hive.box<Settings>('settings_db');
      await box.clear();
    });

    tearDown(() async {
      // Close the box after each test
      if (Hive.isBoxOpen('settings_db')) {
        final box = Hive.box<Settings>('settings_db');
        await box.close();
      }
    });

    tearDownAll(() async {
      // Clean up Hive after all tests
      await Hive.deleteFromDisk();
    });

    test('getSettings returns default when no settings exist', () {
      final settings = settingsService.getSettings();
      expect(settings.themeMode, equals('system'));
      expect(settings.locale, isNull);
    });

    test('getThemeMode returns system by default', () {
      final themeMode = settingsService.getThemeMode();
      expect(themeMode, equals(ThemeMode.system));
    });

    test('setThemeMode stores and retrieves light theme', () async {
      await settingsService.setThemeMode(ThemeMode.light);
      
      final themeMode = settingsService.getThemeMode();
      expect(themeMode, equals(ThemeMode.light));
      
      final settings = settingsService.getSettings();
      expect(settings.themeMode, equals('light'));
    });

    test('setThemeMode stores and retrieves dark theme', () async {
      await settingsService.setThemeMode(ThemeMode.dark);
      
      final themeMode = settingsService.getThemeMode();
      expect(themeMode, equals(ThemeMode.dark));
      
      final settings = settingsService.getSettings();
      expect(settings.themeMode, equals('dark'));
    });

    test('setThemeMode stores and retrieves system theme', () async {
      await settingsService.setThemeMode(ThemeMode.system);
      
      final themeMode = settingsService.getThemeMode();
      expect(themeMode, equals(ThemeMode.system));
      
      final settings = settingsService.getSettings();
      expect(settings.themeMode, equals('system'));
    });

    test('setThemeMode preserves existing locale', () async {
      // Set initial settings with locale
      final box = Hive.box<Settings>('settings_db');
      final initialSettings = Settings(themeMode: 'system', locale: 'en_US');
      await box.put('app_settings', initialSettings);
      
      // Change theme mode
      await settingsService.setThemeMode(ThemeMode.dark);
      
      // Verify locale is preserved
      final settings = settingsService.getSettings();
      expect(settings.themeMode, equals('dark'));
      expect(settings.locale, equals('en_US'));
    });

    test('Settings theme getter converts strings correctly', () {
      final lightSettings = Settings(themeMode: 'light');
      expect(lightSettings.theme, equals(ThemeMode.light));
      
      final darkSettings = Settings(themeMode: 'dark');
      expect(darkSettings.theme, equals(ThemeMode.dark));
      
      final systemSettings = Settings(themeMode: 'system');
      expect(systemSettings.theme, equals(ThemeMode.system));
      
      final unknownSettings = Settings(themeMode: 'unknown');
      expect(unknownSettings.theme, equals(ThemeMode.system));
    });
  });
}
