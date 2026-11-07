import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fox/app.dart';
import 'package:fox/l10n/app_localizations.dart';
import 'package:fox/providers/locale_provider.dart';
import 'package:fox/providers/theme_provider.dart';
import 'package:fox/services/notes_controller.dart';
import 'package:fox/services/repository_hive.dart';
import 'package:fox/services/settings_service.dart';
import 'package:fox/services/storage_service.dart';
import 'package:fox/widgets/startup_failure_screen.dart';

/// Everything a successful startup produces.
class StartupBundle {
  const StartupBundle({
    required this.notesController,
    required this.settingsService,
    required this.themeProvider,
    required this.localeProvider,
  });

  final NotesController notesController;
  final SettingsService settingsService;
  final ThemeProvider themeProvider;
  final LocaleProvider localeProvider;
}

typedef StartupTask = Future<StartupBundle> Function();

/// The real startup: open storage, load the library and providers.
///
/// [initStorage] is injectable so tests can run Hive against a temp directory
/// without the path_provider plugin.
Future<StartupBundle> defaultStartup({
  Future<void> Function()? initStorage,
}) async {
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await StorageService.init(initFlutter: initStorage);

  final repository = HiveNoteRepository.create();
  final settingsService = SettingsService();
  final notesController =
      NotesController(repository, settingsRepository: settingsService);
  await notesController.load();

  final themeProvider = ThemeProvider(settingsRepository: settingsService);
  await themeProvider.load();

  final localeProvider = LocaleProvider(settingsRepository: settingsService);
  await localeProvider.load();

  return StartupBundle(
    notesController: notesController,
    settingsService: settingsService,
    themeProvider: themeProvider,
    localeProvider: localeProvider,
  );
}

/// Runs [startup] and shows the failure screen with a working Retry.
///
/// Retrying re-runs the whole startup, so fixing the cause (freeing space,
/// closing another process, rotating a corrupt file away) makes the app open
/// without restarting the process.
class FoxRoot extends StatefulWidget {
  const FoxRoot({
    required this.startup,
    this.appBuilder,
    super.key,
  });

  final StartupTask startup;
  final Widget Function(StartupBundle bundle)? appBuilder;

  @override
  State<FoxRoot> createState() => _FoxRootState();
}

class _FoxRootState extends State<FoxRoot> {
  StartupBundle? _bundle;
  Object? _error;

  @override
  void initState() {
    super.initState();
    unawaited(_start());
  }

  Future<void> _start() async {
    if (mounted) {
      setState(() {
        _bundle = null;
        _error = null;
      });
    }
    try {
      final bundle = await widget.startup();
      if (!mounted) return;
      setState(() => _bundle = bundle);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bundle = _bundle;
    if (bundle != null) {
      return widget.appBuilder?.call(bundle) ?? _defaultApp(bundle);
    }

    return MaterialApp(
      title: 'Fox Notes',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: _error == null
          ? const Scaffold(body: SizedBox.shrink())
          : StartupFailureScreen(error: '$_error', onRetry: _start),
    );
  }

  Widget _defaultApp(StartupBundle bundle) {
    return FoxApp(
      notesController: bundle.notesController,
      settingsService: bundle.settingsService,
      themeProvider: bundle.themeProvider,
      localeProvider: bundle.localeProvider,
    );
  }
}
