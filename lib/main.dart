import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:fox/home_page.dart';
import 'package:fox/l10n/app_localizations.dart';
import 'package:fox/providers/locale_provider.dart';
import 'package:fox/providers/theme_provider.dart';
import 'package:fox/services/constants.dart';
import 'package:fox/services/notes_controller.dart';
import 'package:fox/services/repository_hive.dart';
import 'package:fox/services/settings_service.dart';
import 'package:fox/services/storage_service.dart';
import 'package:fox/services/umami_service.dart';
import 'package:fox/theme/app_theme.dart';
import 'package:provider/provider.dart';

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  late final HiveNoteRepository repository;
  try {
    await StorageService.init();
    repository = HiveNoteRepository.create();
  } catch (e) {
    runApp(MaterialApp(
        home: Scaffold(body: Center(child: Text('Startup failed: $e')))));
    return;
  }

  final settingsService = SettingsService();
  final notesController =
      NotesController(repository, settingsRepository: settingsService);
  await notesController.load();

  final themeProvider = ThemeProvider(settingsRepository: settingsService);
  await themeProvider.load();

  final localeProvider =
      LocaleProvider(settingsRepository: settingsService);
  await localeProvider.load();

  final umamiService = UmamiService(
    websiteId: AppConstants.umamiWebsiteId,
    endpoint: AppConstants.umamiEndpoint,
  );

  try {
    umamiService.enabled = settingsService.getAnalyticsEnabled();
  } catch (e) {
    debugPrint('Failed to load analytics setting: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider.value(value: localeProvider),
        ChangeNotifierProvider.value(value: notesController),
        Provider.value(value: umamiService),
      ],
      child: MyApp(
        umamiService: umamiService,
        notesController: notesController,
        settingsService: settingsService,
      ),
    ),
  );

  // Remove splash after the first frame is rendered to avoid a white flash.
  WidgetsBinding.instance.addPostFrameCallback((_) {
    FlutterNativeSplash.remove();
    umamiService.track('app_launch');
    umamiService
        .track('note_count', data: {'count': notesController.notes.length});
  });
}

class MyApp extends StatelessWidget {
  const MyApp({
    required this.umamiService,
    required this.notesController,
    required this.settingsService,
    super.key,
  });
  final UmamiService umamiService;
  final NotesController notesController;
  final SettingsService settingsService;

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final localeProvider = context.watch<LocaleProvider>();

    return MaterialApp(
      title: 'Fox Notes',
      debugShowCheckedModeBanner: false,
      navigatorObservers: [umamiService],
      localizationsDelegates: const [
        ...AppLocalizations.localizationsDelegates,
        FlutterQuillLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: localeProvider.locale,
      themeMode: themeProvider.themeMode,
      theme: AppTheme.light(themeProvider.accentColor),
      darkTheme: AppTheme.dark(themeProvider.accentColor),
      home: HomePage(controller: notesController, settingsService: settingsService),
    );
  }
}
