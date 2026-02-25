import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'home_page.dart';
import 'providers/theme_provider.dart';
import 'services/storage_service.dart';
import 'services/notes_controller.dart';
import 'services/repository.dart';
import 'services/repository_hive.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Preserve the splash screen
  FlutterNativeSplash.preserve(widgetsBinding: WidgetsBinding.instance);

  try {
    // Initialize Hive storage
    await StorageService.init();

    // Use Hive repository for all platforms
    final NoteRepository repo = await HiveNoteRepository.create();
    final notesController = NotesController(repo);
    await notesController.load();

    // Create theme provider and load persisted preference before building the app.
    final themeProvider = ThemeProvider();
    await themeProvider.load();

    runApp(ChangeNotifierProvider.value(
      value: themeProvider,
      child: MyApp(controller: notesController),
    ));
  } catch (e) {
    // Show a fallback error screen instead of a white screen on startup failure
    FlutterNativeSplash.remove();
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Text(
              'Something went wrong starting Fox.\n\nPlease try clearing app data or reinstalling.\n\nError: $e',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
      ),
    ));
  }
}

class MyApp extends StatefulWidget {
  final NotesController controller;
  const MyApp({super.key, required this.controller});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    unawaited(_removeSplashScreen());
  }

  Future<void> _removeSplashScreen() async {
    // Wait for 1 second before removing the splash screen
    await Future.delayed(const Duration(seconds: 1));
    FlutterNativeSplash.remove();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) => MaterialApp(
        title: 'Fox',
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          FlutterQuillLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'),
        ],
        themeMode: themeProvider.themeMode,
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFF8F5F1),
          appBarTheme: AppBarTheme(
            backgroundColor: const Color(0xFFF8F5F1),
            foregroundColor: const Color(0xFF333333),
            elevation: 0,
            titleTextStyle: GoogleFonts.inter(
              textStyle: const TextStyle(
                color: Color(0xFF333333),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Color(0xFF8B9A6B),
            foregroundColor: Color(0xFFF8F5F1),
          ),
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.light().textTheme,
      ),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF8B9A6B),
            brightness: Brightness.light,
          ).copyWith(
            secondary: const Color(0xFFC7B8A5),
            error: const Color(0xFFD9534F),
          ),
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFF202124),
          appBarTheme: AppBarTheme(
            backgroundColor: const Color(0xFF202124),
            foregroundColor: const Color(0xFFF8F5F1),
            elevation: 0,
            titleTextStyle: GoogleFonts.inter(
              textStyle: const TextStyle(
                color: Color(0xFFF8F5F1),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Color(0xFF8B9A6B),
            foregroundColor: Color(0xFF202124),
          ),
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.dark().textTheme,
      ),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF8B9A6B),
            brightness: Brightness.dark,
          ).copyWith(
            secondary: const Color(0xFFC7B8A5),
            error: const Color(0xFFD9534F),
          ),
        ),
        home: HomePage(controller: widget.controller),
      ),
    );
  }
}
