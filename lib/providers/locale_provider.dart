import 'package:flutter/material.dart';
import 'package:fox/services/constants.dart';
import 'package:fox/services/settings_service.dart';

/// Manages the app locale: system default (`null`) or a user-chosen override.
class LocaleProvider extends ChangeNotifier {
  LocaleProvider({SettingsService? settingsService})
      : _settingsService = settingsService ?? SettingsService();

  final SettingsService _settingsService;
  Locale? _locale; // null → follow system

  Locale? get locale => _locale;

  /// Load persisted locale from settings.
  Future<void> load() async {
    try {
      final tag = _settingsService.getLocale();
      _locale = _parseLocale(tag);
    } catch (e) {
      debugPrint('LocaleProvider: failed to load locale: $e');
      _locale = null;
    }
  }

  /// Set a new locale override, or `null` to revert to system default.
  Future<void> setLocale(Locale? newLocale) async {
    try {
      await _settingsService
          .setLocale(newLocale != null ? localeToTag(newLocale) : null);
      _locale = newLocale;
    } catch (e) {
      debugPrint('LocaleProvider: failed to persist locale: $e');
    }
    notifyListeners();
  }

  /// Converts a stored tag like 'pt_PT' or 'zh_TW' into a [Locale].
  static Locale? _parseLocale(String? tag) {
    if (tag == null || tag.isEmpty) return null;
    final parts = tag.split('_');
    if (parts.length == 2) {
      return Locale(parts[0], parts[1]);
    }
    return Locale(parts[0]);
  }
}
