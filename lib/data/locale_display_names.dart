class LocaleDisplayNames {
  static const Map<String, String> _names = {
    'ar': 'العربية',
    'bn': 'বাংলা',
    'cs': 'Čeština',
    'da': 'Dansk',
    'de': 'Deutsch',
    'el': 'Ελληνικά',
    'en': 'English',
    'es': 'Español',
    'fi': 'Suomi',
    'fr': 'Français',
    'he': 'עברית',
    'hi': 'हिन्दी',
    'id': 'Bahasa Indonesia',
    'it': 'Italiano',
    'ja': '日本語',
    'ko': '한국어',
    'ms': 'Bahasa Melayu',
    'nl': 'Nederlands',
    'pl': 'Polski',
    'pt': 'Português',
    'pt_BR': 'Português (Brasil)',
    'pt_PT': 'Português (Portugal)',
    'ro': 'Română',
    'ru': 'Русский',
    'sv': 'Svenska',
    'th': 'ไทย',
    'tr': 'Türkçe',
    'uk': 'Українська',
    'vi': 'Tiếng Việt',
    'zh': '中文',
    'zh_TW': '中文 (台灣)',
  };

  static Future<Map<String, String>> load() async {
    return _names;
  }
}
