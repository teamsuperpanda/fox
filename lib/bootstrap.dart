import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fox/app.dart';
import 'package:fox/l10n/app_localizations.dart';
import 'package:fox/providers/locale_provider.dart';
import 'package:fox/providers/theme_provider.dart';
import 'package:fox/services/notes_controller.dart';
import 'package:fox/services/repository_hive.dart';
import 'package:fox/services/settings_service.dart';
import 'package:fox/services/storage_service.dart';
import 'package:provider/provider.dart';

typedef StorageInitializer = Future<void> Function();
typedef RepositoryFactory = NoteAndFolderRepository Function();
typedef SettingsServiceFactory = SettingsService Function();

/// Everything the app needs once startup succeeded.
class AppScope {
  const AppScope({
    required this.notesController,
    required this.themeProvider,
    required this.localeProvider,
    required this.settingsService,
  });

  final NotesController notesController;
  final ThemeProvider themeProvider;
  final LocaleProvider localeProvider;
  final SettingsService settingsService;
}

NoteAndFolderRepository _defaultRepository() => HiveNoteRepository.create();

SettingsService _defaultSettingsService() => SettingsService();

/// Builds the app scope from injectable storage, repository and settings
/// factories. Throws if storage initialization fails; [FoxApp] retries.
Future<AppScope> bootstrap({
  StorageInitializer initStorage = StorageService.init,
  RepositoryFactory createRepository = _defaultRepository,
  SettingsServiceFactory createSettingsService = _defaultSettingsService,
}) async {
  await initStorage();

  final settingsService = createSettingsService();
  final notesController = NotesController(
    createRepository(),
    settingsRepository: settingsService,
  );
  await notesController.load();

  final themeProvider = ThemeProvider(settingsRepository: settingsService);
  await themeProvider.load();

  final localeProvider = LocaleProvider(settingsRepository: settingsService);
  await localeProvider.load();

  return AppScope(
    notesController: notesController,
    themeProvider: themeProvider,
    localeProvider: localeProvider,
    settingsService: settingsService,
  );
}

/// Starts the app, showing a translated error screen with Retry if startup
/// fails and retrying in place without restarting the process.
class FoxApp extends StatefulWidget {
  const FoxApp({
    super.key,
    this.initStorage = StorageService.init,
    this.createRepository = _defaultRepository,
    this.createSettingsService = _defaultSettingsService,
  });

  final StorageInitializer initStorage;
  final RepositoryFactory createRepository;
  final SettingsServiceFactory createSettingsService;

  @override
  State<FoxApp> createState() => _FoxAppState();
}

class _FoxAppState extends State<FoxApp> {
  AppScope? _scope;
  Object? _error;

  @override
  void initState() {
    super.initState();
    unawaited(_start());
  }

  Future<void> _start() async {
    try {
      final scope = await bootstrap(
        initStorage: widget.initStorage,
        createRepository: widget.createRepository,
        createSettingsService: widget.createSettingsService,
      );
      if (!mounted) return;
      setState(() => _scope = scope);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e);
    }
  }

  void _retry() {
    setState(() => _error = null);
    unawaited(_start());
  }

  @override
  Widget build(BuildContext context) {
    final error = _error;
    if (error != null) {
      return _StartupErrorScreen(error: error, onRetry: _retry);
    }

    final scope = _scope;
    if (scope == null) {
      return const SizedBox.shrink();
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: scope.themeProvider),
        ChangeNotifierProvider.value(value: scope.localeProvider),
        ChangeNotifierProvider.value(value: scope.notesController),
      ],
      child: MyApp(
        notesController: scope.notesController,
        settingsService: scope.settingsService,
      ),
    );
  }
}

class _StartupErrorScreen extends StatelessWidget {
  const _StartupErrorScreen({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) {
          final l10n = AppLocalizations.of(context);
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.startupError('$error'),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: onRetry,
                      icon: const Icon(Icons.refresh),
                      label: Text(l10n.retry),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
