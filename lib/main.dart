import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:fox/home_page.dart';
import 'package:fox/l10n/app_localizations.dart';
import 'package:fox/providers/locale_provider.dart';
import 'package:fox/providers/theme_provider.dart';
import 'package:fox/services/notes_controller.dart';
import 'package:fox/services/repository_hive.dart';
import 'package:fox/services/settings_service.dart';
import 'package:fox/services/storage_service.dart';
import 'package:fox/theme/app_theme.dart';
import 'package:fox/widgets/startup_failure_screen.dart';
import 'package:provider/provider.dart';

void main() {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  runApp(const FoxBootstrap());

  // Remove splash after the first frame is rendered to avoid a white flash.
  WidgetsBinding.instance.addPostFrameCallback((_) {
    FlutterNativeSplash.remove();
  });
}

/// Opens storage and builds the app, showing [StartupFailureScreen] instead of
/// a dead end when that fails.
class FoxBootstrap extends StatefulWidget {
  const FoxBootstrap({super.key});

  @override
  State<FoxBootstrap> createState() => _FoxBootstrapState();
}

class _FoxBootstrapState extends State<FoxBootstrap> {
  late Future<Widget> _bootstrap = _start();

  Future<Widget> _start() async {
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    await StorageService.init();
    final repository = HiveNoteRepository.create();
    final settingsService = SettingsService();
    final notesController =
        NotesController(repository, settingsRepository: settingsService);
    await notesController.load();

    final themeProvider = ThemeProvider(settingsRepository: settingsService);
    await themeProvider.load();

    final localeProvider = LocaleProvider(settingsRepository: settingsService);
    await localeProvider.load();

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

  Future<void> _retry() async {
    await StorageService.reset();
    setState(() => _bootstrap = _start());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _bootstrap,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return StartupFailureApp(
            error: snapshot.error!,
            onRetry: _retry,
          );
        }
        final app = snapshot.data;
        if (app == null) {
          return const MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }
        return app;
      },
    );
  }
}

/// The minimal app shell used while startup is broken.
class StartupFailureApp extends StatelessWidget {
  const StartupFailureApp({
    required this.error,
    required this.onRetry,
    super.key,
  });

  final Object error;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: StartupFailureScreen(error: error, onRetry: onRetry),
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
