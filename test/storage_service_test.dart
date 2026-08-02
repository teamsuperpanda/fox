import 'package:flutter_test/flutter_test.dart';
import 'package:fox/models/settings.dart';
import 'package:fox/services/box_names.dart';
import 'package:hive/hive.dart';

import 'test_helpers.dart';

void main() {
  group('StorageService', () {
    setUp(() async {
      await hiveTestSetup('./test/hive_storage_test');
    });

    tearDown(() async {
      await hiveTestTeardown();
    });

    test('adapter is registered correctly', () {
      expect(Hive.isAdapterRegistered(2), isTrue);
    });

    test('can open and access settings box', () async {
      final box = Hive.box<Settings>(BoxNames.settings);
      expect(box, isNotNull);
    });

    test('can store and retrieve Settings object', () async {
      final box = Hive.box<Settings>(BoxNames.settings);
      final settings = Settings(themeMode: 'dark', locale: 'en_US');

      await box.put('test_settings', settings);

      final retrieved = box.get('test_settings');
      expect(retrieved, isNotNull);
      expect(retrieved!.themeMode, equals('dark'));
      expect(retrieved.locale, equals('en_US'));
    });

    test('adapter correctly serializes and deserializes Settings', () async {
      final box = Hive.box<Settings>(BoxNames.settings);

      final fullSettings = Settings(themeMode: 'light', locale: 'fr_FR');
      await box.put('full', fullSettings);
      final retrievedFull = box.get('full');
      expect(retrievedFull!.themeMode, equals('light'));
      expect(retrievedFull.locale, equals('fr_FR'));

      final partialSettings = Settings(themeMode: 'system');
      await box.put('partial', partialSettings);
      final retrievedPartial = box.get('partial');
      expect(retrievedPartial!.themeMode, equals('system'));
      expect(retrievedPartial.locale, isNull);
    });
  });
}
