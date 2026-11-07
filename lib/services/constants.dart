import 'package:flutter/widgets.dart';

/// Convert a [Locale] to a storable string tag (e.g. Locale('pt', 'BR') → 'pt_BR').
String localeToTag(Locale locale) {
  if (locale.countryCode != null && locale.countryCode!.isNotEmpty) {
    return '${locale.languageCode}_${locale.countryCode}';
  }
  return locale.languageCode;
}

class AppConstants {
  AppConstants._();
  static const String unfiledFolderId = '__unfiled__';
}

/// Locale Flutter should use for the app.
///
/// An exact match wins, then a language-only match (so `pt_BR` falls back to
/// `pt`), and anything unsupported resolves to English rather than to the
/// first supported locale (which is Arabic in the generated list).
Locale resolveAppLocale(Locale? requested, Iterable<Locale> supported) {
  if (requested != null) {
    for (final candidate in supported) {
      if (candidate == requested) return candidate;
    }
    for (final candidate in supported) {
      if (candidate.languageCode == requested.languageCode) return candidate;
    }
  }
  return const Locale('en');
}
