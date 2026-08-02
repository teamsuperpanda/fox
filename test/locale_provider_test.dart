import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fox/models/settings.dart';
import 'package:fox/providers/locale_provider.dart';
import 'package:fox/services/box_names.dart';
import 'package:fox/services/settings_service.dart';
import 'package:hive/hive.dart';

import 'test_helpers.dart';

void main() {
  group('LocaleProvider', () {
    late LocaleProvider provider;

    setUp(() async {
      await hiveTestSetup('./test/hive_locale_provider_test');
      provider = LocaleProvider(settingsRepository: SettingsService());
    });

    tearDown(() async {
      await hiveTestTeardown();
    });

    test('initial locale is null (system default)', () {
      expect(provider.locale, isNull);
    });

    test('load returns null when no locale is persisted', () async {
      await provider.load();
      expect(provider.locale, isNull);
    });

    test('load reads persisted simple locale', () async {
      final box = Hive.box<Settings>(BoxNames.settings);
      await box.put(
          'app_settings', Settings(themeMode: 'system', locale: 'fr'));

      await provider.load();
      expect(provider.locale, equals(const Locale('fr')));
    });

    test('load reads persisted locale with country code', () async {
      final box = Hive.box<Settings>(BoxNames.settings);
      await box.put(
          'app_settings', Settings(themeMode: 'system', locale: 'pt_PT'));

      await provider.load();
      expect(provider.locale, equals(const Locale('pt', 'PT')));
    });

    test('setLocale persists and notifies', () async {
      var notifyCount = 0;
      provider.addListener(() => notifyCount++);

      await provider.setLocale(const Locale('de'));

      expect(provider.locale, equals(const Locale('de')));
      expect(notifyCount, 1);

      final box = Hive.box<Settings>(BoxNames.settings);
      final settings = box.get('app_settings');
      expect(settings?.locale, equals('de'));
    });

    test('setLocale with country code stores correct tag', () async {
      await provider.setLocale(const Locale('zh', 'TW'));

      expect(provider.locale, equals(const Locale('zh', 'TW')));

      final box = Hive.box<Settings>(BoxNames.settings);
      final settings = box.get('app_settings');
      expect(settings?.locale, equals('zh_TW'));
    });

    test('setLocale to null reverts to system default', () async {
      await provider.setLocale(const Locale('ja'));
      expect(provider.locale, isNotNull);

      await provider.setLocale(null);
      expect(provider.locale, isNull);

      final box = Hive.box<Settings>(BoxNames.settings);
      final settings = box.get('app_settings');
      expect(settings?.locale, isNull);
    });

    test('load handles empty locale string as null', () async {
      final box = Hive.box<Settings>(BoxNames.settings);
      await box.put('app_settings', Settings(themeMode: 'system', locale: ''));

      await provider.load();
      expect(provider.locale, isNull);
    });

    test('load and setLocale round-trip', () async {
      await provider.setLocale(const Locale('es', 'MX'));

      final provider2 = LocaleProvider(settingsRepository: SettingsService());
      await provider2.load();
      expect(provider2.locale, equals(const Locale('es', 'MX')));
    });
  });
}
