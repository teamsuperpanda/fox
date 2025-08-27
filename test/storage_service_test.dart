import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:fox/models/settings.dart';
import 'package:fox/models/settings_adapter.dart';

void main() {
  group('StorageService', () {
    setUpAll(() async {
      // Initialize Hive for testing (without Flutter)
      Hive.init('./test/hive_storage_test');
      if (!Hive.isAdapterRegistered(2)) {
        Hive.registerAdapter(SettingsAdapter());
      }
    });

    setUp(() async {
      // Open boxes for testing
      await Hive.openBox<Settings>('settings_db');
      await Hive.openBox('migration_flags');
    });

    tearDown(() async {
      // Clean up after each test
      if (Hive.isBoxOpen('settings_db')) {
        final box = Hive.box<Settings>('settings_db');
        await box.clear();
        await box.close();
      }
      if (Hive.isBoxOpen('migration_flags')) {
        final box = Hive.box('migration_flags');
        await box.clear();
        await box.close();
      }
    });

    tearDownAll(() async {
      // Clean up Hive after all tests
      await Hive.deleteFromDisk();
    });

    test('adapter is registered correctly', () {
      expect(Hive.isAdapterRegistered(2), isTrue);
    });

    test('can open and access settings box', () async {
      final box = Hive.box<Settings>('settings_db');
      expect(box, isNotNull);
    });

    test('can store and retrieve Settings object', () async {
      final box = Hive.box<Settings>('settings_db');
      final settings = Settings(themeMode: 'dark', locale: 'en_US');
      
      // Store settings
      await box.put('test_settings', settings);
      
      // Retrieve settings
      final retrieved = box.get('test_settings');
      expect(retrieved, isNotNull);
      expect(retrieved!.themeMode, equals('dark'));
      expect(retrieved.locale, equals('en_US'));
    });

    test('adapter correctly serializes and deserializes Settings', () async {
      final box = Hive.box<Settings>('settings_db');
      
      // Test with all fields
      final fullSettings = Settings(themeMode: 'light', locale: 'fr_FR');
      await box.put('full', fullSettings);
      final retrievedFull = box.get('full');
      expect(retrievedFull!.themeMode, equals('light'));
      expect(retrievedFull.locale, equals('fr_FR'));
      
      // Test with null locale
      final partialSettings = Settings(themeMode: 'system');
      await box.put('partial', partialSettings);
      final retrievedPartial = box.get('partial');
      expect(retrievedPartial!.themeMode, equals('system'));
      expect(retrievedPartial.locale, isNull);
    });
  });
}
