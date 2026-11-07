import 'package:flutter/material.dart';
import 'package:fox/services/constants.dart';
import 'package:fox/services/settings_service.dart';

/// Manages the app locale: system default (`null`) or a user-chosen override.
class LocaleProvider extends ChangeNotifier {
  LocaleProvider({SettingsService? settingsRepository})
      : _settingsRepository = settingsRepository ?? SettingsService();

  final SettingsService _settingsRepository;
  Locale? _locale; // null → follow system

  Locale? get locale => _locale;

  /// Load persisted locale from settings.
  Future<void> load() async {
    try {
      final tag = _settingsRepository.getLocale();
      _locale = _parseLocale(tag);
    } catch (e) {
      // Loading is best effort: fall back to the system locale.
      debugPrint('LocaleProvider: failed to load locale: $e');
      _locale = null;
    }
  }

  /// Set a new locale override, or `null` to revert to system default.
  ///
  /// Returns false when the write failed; the override still applies for the
  /// rest of the session.
  Future<bool> setLocale(Locale? newLocale) async {
    var saved = true;
    try {
      await _settingsRepository
          .setLocale(newLocale != null ? localeToTag(newLocale) : null);
      _locale = newLocale;
    } catch (e) {
      saved = false;
      // Callers surface the failure; the override still applies this session.
      debugPrint('LocaleProvider: failed to persist locale: $e');
    }
    notifyListeners();
    return saved;
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
