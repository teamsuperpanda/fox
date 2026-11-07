import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:fox/home_page.dart';
import 'package:fox/l10n/app_localizations.dart';
import 'package:fox/providers/locale_provider.dart';
import 'package:fox/providers/theme_provider.dart';
import 'package:fox/services/notes_controller.dart';
import 'package:fox/services/settings_service.dart';
import 'package:fox/theme/app_theme.dart';
import 'package:provider/provider.dart';

/// Root widget: reads providers and wires the home page and themes.
class MyApp extends StatelessWidget {
  const MyApp({
    required this.notesController,
    required this.settingsService,
    super.key,
  });
  final NotesController notesController;
  final SettingsService settingsService;

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final localeProvider = context.watch<LocaleProvider>();

    return MaterialApp(
      title: 'Fox Notes',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        ...AppLocalizations.localizationsDelegates,
        FlutterQuillLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: localeProvider.locale,
      themeMode: themeProvider.themeMode,
      theme: AppTheme.light(themeProvider.accentColor),
      darkTheme: AppTheme.dark(themeProvider.accentColor),
      home: HomePage(
        controller: notesController,
        settingsService: settingsService,
      ),
    );
  }
}
