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

/// The running app once startup has succeeded.
class FoxApp extends StatelessWidget {
  const FoxApp({
    required this.notesController,
    required this.settingsService,
    required this.themeProvider,
    required this.localeProvider,
    super.key,
  });

  final NotesController notesController;
  final SettingsService settingsService;
  final ThemeProvider themeProvider;
  final LocaleProvider localeProvider;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider.value(value: localeProvider),
        ChangeNotifierProvider.value(value: notesController),
      ],
      child: MyApp(
        notesController: notesController,
        settingsService: settingsService,
      ),
    );
  }
}

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
          controller: notesController, settingsService: settingsService),
    );
  }
}
