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

  /// Grapheme limits for user-entered text. The body has no limit by design.
  static const int maxTitleLength = 200;
  static const int maxFolderNameLength = 120;
  static const int maxTagLength = 50;
}
