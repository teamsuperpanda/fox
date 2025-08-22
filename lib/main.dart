import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'home_page.dart';
import 'providers/theme_provider.dart';
import 'services/notes_controller.dart';
import 'services/repository.dart';
import 'services/repository_idb_web.dart';
import 'services/repository_sqlite.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Choose repository per platform.
  final NoteRepository repo = kIsWeb
      ? await WebIdbNoteRepository.create()
      : await SqliteNoteRepository.create();

  final notesController = NotesController(repo)..load();

  runApp(ChangeNotifierProvider(
    create: (_) => ThemeProvider(),
    child: MyApp(controller: notesController),
  ));
}

class MyApp extends StatelessWidget {
  final NotesController controller;
  const MyApp({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) => MaterialApp(
        title: 'Fox Notes',
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
      ThemeData.light().textTheme.copyWith(
          bodyMedium: GoogleFonts.inter(
            textStyle: ThemeData.light().textTheme.bodyMedium),
          bodySmall: GoogleFonts.inter(
            textStyle: ThemeData.light().textTheme.bodySmall),
          titleLarge: GoogleFonts.inter(
            textStyle: ThemeData.light()
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.bold)),
          titleMedium: GoogleFonts.inter(
            textStyle: ThemeData.light()
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold)),
          titleSmall: GoogleFonts.inter(
            textStyle: ThemeData.light()
              .textTheme
              .titleSmall
              ?.copyWith(fontWeight: FontWeight.bold)),
        ),
      ),
          colorScheme: ColorScheme.fromSwatch().copyWith(
            primary: const Color(0xFF8B9A6B),
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
      ThemeData.dark().textTheme.copyWith(
          bodyMedium: GoogleFonts.inter(
            textStyle: ThemeData.dark().textTheme.bodyMedium),
          bodySmall: GoogleFonts.inter(
            textStyle: ThemeData.dark()
              .textTheme
              .bodySmall
              ?.copyWith(color: Colors.white70)),
          titleLarge: GoogleFonts.inter(
            textStyle: ThemeData.dark()
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.bold)),
          titleMedium: GoogleFonts.inter(
            textStyle: ThemeData.dark()
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold)),
          titleSmall: GoogleFonts.inter(
            textStyle: ThemeData.dark()
              .textTheme
              .titleSmall
              ?.copyWith(fontWeight: FontWeight.bold)),
        ),
      ),
          colorScheme: ColorScheme.fromSwatch(brightness: Brightness.dark)
        .copyWith(
          primary: const Color(0xFF8B9A6B),
          secondary: const Color(0xFFC7B8A5),
          error: const Color(0xFFD9534F)),
        ),
        home: HomePage(controller: controller),
      ),
    );
  }
}
