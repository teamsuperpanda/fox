import 'package:flutter/material.dart';
import '../services/settings_service.dart';

/// Manages the app locale: system default (`null`) or a user-chosen override.
class LocaleProvider extends ChangeNotifier {
  Locale? _locale; // null → follow system

  Locale? get locale => _locale;

  /// Load persisted locale from settings.
  Future<void> load() async {
    try {
      final service = SettingsService();
      final tag = service.getLocale();
      _locale = _parseLocale(tag);
    } catch (_) {
      _locale = null;
    }
  }

  /// Set a new locale override, or `null` to revert to system default.
  Future<void> setLocale(Locale? newLocale) async {
    _locale = newLocale;
    try {
      final service = SettingsService();
      await service.setLocale(newLocale != null ? _localeToTag(newLocale) : null);
    } catch (_) {}
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

  /// Converts a [Locale] into a storable string tag.
  static String _localeToTag(Locale locale) {
    if (locale.countryCode != null && locale.countryCode!.isNotEmpty) {
      return '${locale.languageCode}_${locale.countryCode}';
    }
    return locale.languageCode;
  }
}
