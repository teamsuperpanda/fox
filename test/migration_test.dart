import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fox/models/settings.dart';
import 'package:fox/models/settings_adapter.dart';
import 'package:fox/migrations/migrate_prefs.dart';

void main() {
  group('Migration Tests', () {
    setUpAll(() async {
      // Initialize Hive for testing
      Hive.init('./test/hive_migration_test');
      if (!Hive.isAdapterRegistered(2)) {
        Hive.registerAdapter(SettingsAdapter());
      }
    });

    setUp(() async {
      // Open the settings and migration boxes
      await Hive.openBox<Settings>('settings_db');
      await Hive.openBox('migration_flags');
      
      // Clear any existing data
      final settingsBox = Hive.box<Settings>('settings_db');
      final migrationBox = Hive.box('migration_flags');
      await settingsBox.clear();
      await migrationBox.clear();
    });

    tearDown(() async {
      // Clean up SharedPreferences
      SharedPreferences.setMockInitialValues({});
      
      // Close the boxes
      if (Hive.isBoxOpen('settings_db')) {
        await Hive.box<Settings>('settings_db').close();
      }
      if (Hive.isBoxOpen('migration_flags')) {
        await Hive.box('migration_flags').close();
      }
    });

    tearDownAll(() async {
      // Clean up Hive after all tests
      await Hive.deleteFromDisk();
    });

    test('migrates theme preference from SharedPreferences to Hive', () async {
      // Set up mock SharedPreferences with a dark theme
      SharedPreferences.setMockInitialValues({
        'themeMode': 'dark',
      });

      // Run migration
      await migratePrefsToHive();

      // Verify migration was successful
      final settingsBox = Hive.box<Settings>('settings_db');
      final migrationBox = Hive.box('migration_flags');
      final settings = settingsBox.get('app_settings');
      final migrationFlag = migrationBox.get('migrated_prefs_v1');

      expect(settings, isNotNull);
      expect(settings!.themeMode, equals('dark'));
      expect(migrationFlag, isTrue);
    });

    test('migrates default system theme when no preference exists', () async {
      // Set up mock SharedPreferences with no theme preference
      SharedPreferences.setMockInitialValues({});

      // Run migration
      await migratePrefsToHive();

      // Verify default system theme was migrated
      final settingsBox = Hive.box<Settings>('settings_db');
      final migrationBox = Hive.box('migration_flags');
      final settings = settingsBox.get('app_settings');
      final migrationFlag = migrationBox.get('migrated_prefs_v1');

      expect(settings, isNotNull);
      expect(settings!.themeMode, equals('system'));
      expect(migrationFlag, isTrue);
    });

    test('migrates light theme preference correctly', () async {
      // Set up mock SharedPreferences with light theme
      SharedPreferences.setMockInitialValues({
        'themeMode': 'light',
      });

      // Run migration
      await migratePrefsToHive();

      // Verify light theme was migrated
      final settingsBox = Hive.box<Settings>('settings_db');
      final settings = settingsBox.get('app_settings');

      expect(settings, isNotNull);
      expect(settings!.themeMode, equals('light'));
    });

    test('does not run migration if already completed', () async {
      // Set up mock SharedPreferences with dark theme
      SharedPreferences.setMockInitialValues({
        'themeMode': 'dark',
      });

      // Mark migration as already completed with different settings
      final settingsBox = Hive.box<Settings>('settings_db');
      final migrationBox = Hive.box('migration_flags');
      await migrationBox.put('migrated_prefs_v1', true);
      await settingsBox.put('app_settings', Settings(themeMode: 'light'));

      // Run migration (should not change anything)
      await migratePrefsToHive();

      // Verify settings were not overwritten
      final settings = settingsBox.get('app_settings');
      expect(settings, isNotNull);
      expect(settings!.themeMode, equals('light')); // Should remain light
    });

    test('migration is idempotent', () async {
      // Set up mock SharedPreferences
      SharedPreferences.setMockInitialValues({
        'themeMode': 'dark',
      });

      // Run migration twice
      await migratePrefsToHive();
      await migratePrefsToHive();

      // Verify only one settings object exists and migration flag is still true
      final settingsBox = Hive.box<Settings>('settings_db');
      final migrationBox = Hive.box('migration_flags');
      final settings = settingsBox.get('app_settings');
      final migrationFlag = migrationBox.get('migrated_prefs_v1');

      expect(settings, isNotNull);
      expect(settings!.themeMode, equals('dark'));
      expect(migrationFlag, isTrue);
    });
  });
}
