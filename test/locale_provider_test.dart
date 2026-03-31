import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:fox/models/settings.dart';
import 'package:fox/models/settings_adapter.dart';
import 'package:fox/providers/locale_provider.dart';

void main() {
  group('LocaleProvider', () {
    late LocaleProvider provider;

    setUpAll(() async {
      Hive.init('./test/hive_locale_provider_test');
      if (!Hive.isAdapterRegistered(2)) {
        Hive.registerAdapter(SettingsAdapter());
      }
    });

    setUp(() async {
      await Hive.openBox<Settings>('settings_db');
      final box = Hive.box<Settings>('settings_db');
      await box.clear();
      provider = LocaleProvider();
    });

    tearDown(() async {
      if (Hive.isBoxOpen('settings_db')) {
        await Hive.box<Settings>('settings_db').close();
      }
    });

    tearDownAll(() async {
      await Hive.deleteFromDisk();
    });

    test('initial locale is null (system default)', () {
      expect(provider.locale, isNull);
    });

    test('load returns null when no locale is persisted', () async {
      await provider.load();
      expect(provider.locale, isNull);
    });

    test('load reads persisted simple locale', () async {
      // Pre-populate settings with a locale
      final box = Hive.box<Settings>('settings_db');
      await box.put('app_settings', Settings(themeMode: 'system', locale: 'fr'));

      await provider.load();
      expect(provider.locale, equals(const Locale('fr')));
    });

    test('load reads persisted locale with country code', () async {
      final box = Hive.box<Settings>('settings_db');
      await box.put('app_settings', Settings(themeMode: 'system', locale: 'pt_PT'));

      await provider.load();
      expect(provider.locale, equals(const Locale('pt', 'PT')));
    });

    test('setLocale persists and notifies', () async {
      int notifyCount = 0;
      provider.addListener(() => notifyCount++);

      await provider.setLocale(const Locale('de'));

      expect(provider.locale, equals(const Locale('de')));
      expect(notifyCount, 1);

      // Verify persisted
      final box = Hive.box<Settings>('settings_db');
      final settings = box.get('app_settings');
      expect(settings?.locale, equals('de'));
    });

    test('setLocale with country code stores correct tag', () async {
      await provider.setLocale(const Locale('zh', 'TW'));

      expect(provider.locale, equals(const Locale('zh', 'TW')));

      final box = Hive.box<Settings>('settings_db');
      final settings = box.get('app_settings');
      expect(settings?.locale, equals('zh_TW'));
    });

    test('setLocale to null reverts to system default', () async {
      await provider.setLocale(const Locale('ja'));
      expect(provider.locale, isNotNull);

      await provider.setLocale(null);
      expect(provider.locale, isNull);

      final box = Hive.box<Settings>('settings_db');
      final settings = box.get('app_settings');
      expect(settings?.locale, isNull);
    });

    test('load handles empty locale string as null', () async {
      final box = Hive.box<Settings>('settings_db');
      await box.put('app_settings', Settings(themeMode: 'system', locale: ''));

      await provider.load();
      expect(provider.locale, isNull);
    });

    test('load and setLocale round-trip', () async {
      await provider.setLocale(const Locale('es', 'MX'));

      // Create a new provider and load from persistence
      final provider2 = LocaleProvider();
      await provider2.load();
      expect(provider2.locale, equals(const Locale('es', 'MX')));
    });
  });
}
