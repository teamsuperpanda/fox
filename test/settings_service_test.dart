import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fox/models/settings.dart';
import 'package:fox/models/settings_adapter.dart';
import 'package:fox/services/settings_service.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() {
  group('SettingsService', () {
    late SettingsService settingsService;

    setUpAll(() async {
      Hive.init('./test/hive_settings_test');
      if (!Hive.isAdapterRegistered(2)) {
        Hive.registerAdapter(SettingsAdapter());
      }
    });

    setUp(() async {
      await Hive.openBox<Settings>('settings_db');
      settingsService = SettingsService();

      final box = Hive.box<Settings>('settings_db');
      await box.clear();
    });

    tearDown(() async {
      if (Hive.isBoxOpen('settings_db')) {
        final box = Hive.box<Settings>('settings_db');
        await box.close();
      }
    });

    tearDownAll(() async {
      await Hive.deleteFromDisk();
    });

    test('defaults are correct', () {
      expect(settingsService.getThemeMode(), equals(ThemeMode.system));
      expect(settingsService.getLocale(), isNull);
      expect(settingsService.getShowTags(), isTrue);
      expect(settingsService.getShowContent(), isTrue);
      expect(settingsService.getAlternatingColors(), isFalse);
      expect(settingsService.getFabAnimation(), isTrue);
      expect(settingsService.getSortBy(), 'dateDesc');
    });

    test('getThemeMode returns system by default', () {
      final themeMode = settingsService.getThemeMode();
      expect(themeMode, equals(ThemeMode.system));
    });

    test('setThemeMode stores and retrieves light theme', () async {
      await settingsService.setThemeMode(ThemeMode.light);

      final themeMode = settingsService.getThemeMode();
      expect(themeMode, equals(ThemeMode.light));
    });

    test('setThemeMode stores and retrieves dark theme', () async {
      await settingsService.setThemeMode(ThemeMode.dark);

      final themeMode = settingsService.getThemeMode();
      expect(themeMode, equals(ThemeMode.dark));
    });

    test('setThemeMode stores and retrieves system theme', () async {
      await settingsService.setThemeMode(ThemeMode.system);

      final themeMode = settingsService.getThemeMode();
      expect(themeMode, equals(ThemeMode.system));
    });

    test('setThemeMode preserves existing locale', () async {
      final box = Hive.box<Settings>('settings_db');
      final initialSettings = Settings(themeMode: 'system', locale: 'en_US');
      await box.put('app_settings', initialSettings);

      await settingsService.setThemeMode(ThemeMode.dark);

      expect(settingsService.getThemeMode(), ThemeMode.dark);
      expect(settingsService.getLocale(), 'en_US');
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

    test('getLocale returns null by default', () {
      expect(settingsService.getLocale(), isNull);
    });

    test('setLocale stores and retrieves a locale tag', () async {
      await settingsService.setLocale('fr');
      expect(settingsService.getLocale(), 'fr');
    });

    test('setLocale with country code stores full tag', () async {
      await settingsService.setLocale('pt_PT');
      expect(settingsService.getLocale(), 'pt_PT');
    });

    test('setLocale null clears persisted locale', () async {
      await settingsService.setLocale('de');
      expect(settingsService.getLocale(), 'de');

      await settingsService.setLocale(null);
      expect(settingsService.getLocale(), isNull);
    });

    test('setLocale preserves theme mode', () async {
      await settingsService.setThemeMode(ThemeMode.dark);
      await settingsService.setLocale('ja');

      expect(settingsService.getThemeMode(), ThemeMode.dark);
      expect(settingsService.getLocale(), 'ja');
    });

    test('getShowContent returns true by default', () {
      expect(settingsService.getShowContent(), isTrue);
    });

    test('setShowContent persists false', () async {
      await settingsService.setShowContent(false);
      expect(settingsService.getShowContent(), isFalse);
    });

    test('getAlternatingColors returns false by default', () {
      expect(settingsService.getAlternatingColors(), isFalse);
    });

    test('setAlternatingColors persists true', () async {
      await settingsService.setAlternatingColors(true);
      expect(settingsService.getAlternatingColors(), isTrue);
    });

    test('getFabAnimation returns true by default', () {
      expect(settingsService.getFabAnimation(), isTrue);
    });

    test('setFabAnimation persists false', () async {
      await settingsService.setFabAnimation(false);
      expect(settingsService.getFabAnimation(), isFalse);
    });

    test('getSortBy returns dateDesc by default', () {
      expect(settingsService.getSortBy(), 'dateDesc');
    });

    test('setSortBy persists value', () async {
      await settingsService.setSortBy('titleAsc');
      expect(settingsService.getSortBy(), 'titleAsc');
    });

    test('getShowTags returns true by default', () {
      expect(settingsService.getShowTags(), isTrue);
    });

    test('setShowTags persists false', () async {
      await settingsService.setShowTags(false);
      expect(settingsService.getShowTags(), isFalse);
    });

    test('Settings.copyWith preserves all fields when no args', () {
      final s = Settings(
        themeMode: 'dark',
        locale: 'ko',
        showTags: false,
        showContent: false,
        alternatingColors: true,
        fabAnimation: false,
        sortBy: 'titleDesc',
      );
      final copy = s.copyWith();
      expect(copy.themeMode, s.themeMode);
      expect(copy.locale, s.locale);
      expect(copy.showTags, s.showTags);
      expect(copy.showContent, s.showContent);
      expect(copy.alternatingColors, s.alternatingColors);
      expect(copy.fabAnimation, s.fabAnimation);
      expect(copy.sortBy, s.sortBy);
    });

    test('Settings.copyWith clearLocale sets locale to null', () {
      final s = Settings(themeMode: 'system', locale: 'en');
      final cleared = s.copyWith(clearLocale: true);
      expect(cleared.locale, isNull);
      expect(cleared.themeMode, 'system');
    });
  });
}
