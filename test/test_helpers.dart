import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:fox/l10n/app_localizations.dart';

/// Creates a [MaterialApp] wrapping the given [home] widget with all
/// localization delegates needed by the app (including FlutterQuill).
///
/// Use this in widget tests instead of bare `MaterialApp(home: ...)`.
Widget buildTestApp({required Widget home, ThemeData? theme}) {
  return MaterialApp(
    localizationsDelegates: const [
      ...AppLocalizations.localizationsDelegates,
      FlutterQuillLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    theme: theme,
    home: home,
  );
}
