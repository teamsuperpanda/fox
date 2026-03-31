import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:provider/provider.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'home_page.dart';
import 'l10n/app_localizations.dart';
import 'providers/locale_provider.dart';
import 'providers/theme_provider.dart';
import 'services/notes_controller.dart';
import 'services/repository_hive.dart';
import 'services/storage_service.dart';
import 'theme/app_theme.dart';

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await StorageService.init();

  final repository = await HiveNoteRepository.create();
  final notesController = NotesController(repository);
  await notesController.load();
  notesController.loadSettings();

  final themeProvider = ThemeProvider();
  await themeProvider.load();

  final localeProvider = LocaleProvider();
  await localeProvider.load();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider.value(value: localeProvider),
        ChangeNotifierProvider.value(value: notesController),
      ],
      child: const MyApp(),
    ),
  );

  // Remove splash after the first frame is rendered to avoid a white flash.
  WidgetsBinding.instance.addPostFrameCallback((_) {
    FlutterNativeSplash.remove();
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final localeProvider = context.watch<LocaleProvider>();

    return MaterialApp(
      title: 'Fox Notes',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        ...AppLocalizations.localizationsDelegates,
        FlutterQuillLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: localeProvider.locale,
      themeMode: themeProvider.themeMode,
      theme: AppTheme.light(themeProvider.accentColor),
      darkTheme: AppTheme.dark(themeProvider.accentColor),
      home: Consumer<NotesController>(
        builder: (context, controller, child) =>
            HomePage(controller: controller),
      ),
    );
  }
}
