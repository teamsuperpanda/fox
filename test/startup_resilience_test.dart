import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fox/models/folder.dart';
import 'package:fox/models/folder_adapter.dart';
import 'package:fox/models/note.dart';
import 'package:fox/models/note_adapter.dart';
import 'package:fox/models/settings.dart';
import 'package:fox/models/settings_adapter.dart';
import 'package:fox/providers/locale_provider.dart';
import 'package:fox/providers/theme_provider.dart';
import 'package:fox/services/box_names.dart';
import 'package:fox/services/notes_controller.dart';
import 'package:fox/services/repository_hive.dart';
import 'package:fox/services/settings_service.dart';
import 'package:fox/services/storage_service.dart';
import 'package:fox/startup.dart';
import 'package:hive/hive.dart';

import 'test_helpers.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('fox_resilience_test');
    StorageService.reset();
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(SettingsAdapter());
    if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(NoteAdapter());
    if (!Hive.isAdapterRegistered(4)) Hive.registerAdapter(FolderAdapter());
  });

  tearDown(() async {
    await Hive.close();
    StorageService.reset();
    if (tempDir.existsSync()) await tempDir.delete(recursive: true);
  });

  Future<void> writeCorrupt(String boxName, Object? value) async {
    final raw = await Hive.openBox<dynamic>(boxName);
    await raw.put('bad', value);
    await raw.close();
  }

  group('HiveNoteRepository resilience', () {
    test('skips a note record that cannot be decoded', () async {
      final raw = await Hive.openBox<dynamic>(BoxNames.notes);
      await raw.put(
        'good',
        makeNote(id: 'good', title: 'Readable', content: '[]'),
      );
      // A Settings object in the notes box has typeId 2, so reading it as a
      // Note throws exactly like a truncated record would.
      await raw.put('bad', Settings(themeMode: 'dark'));
      await raw.close();

      await Hive.openBox<Note>(BoxNames.notes);
      await Hive.openBox<Folder>(BoxNames.folders);
      final repository = HiveNoteRepository.create();

      final notes = await repository.getAll();
      expect(notes.map((n) => n.id), ['good']);
      expect(repository.unreadableRecords, 1);
    });

    test('skips a folder record that cannot be decoded', () async {
      final raw = await Hive.openBox<dynamic>(BoxNames.folders);
      await raw.put(
        'good',
        Folder(id: 'good', name: 'Work', createdAt: DateTime.utc(2026)),
      );
      await raw.put('bad', Settings(themeMode: 'dark'));
      await raw.close();

      await Hive.openBox<Note>(BoxNames.notes);
      await Hive.openBox<Folder>(BoxNames.folders);
      final repository = HiveNoteRepository.create();

      final folders = await repository.getAllFolders();
      expect(folders.map((f) => f.id), ['good']);
      expect(repository.unreadableRecords, 1);
    });

    test('one bad record does not stop the controller loading', () async {
      final raw = await Hive.openBox<dynamic>(BoxNames.notes);
      await raw.put('good', makeNote(id: 'good', title: 'Readable'));
      await raw.put('bad', Settings(themeMode: 'dark'));
      await raw.close();

      await Hive.openBox<Note>(BoxNames.notes);
      await Hive.openBox<Folder>(BoxNames.folders);
      final controller = NotesController(HiveNoteRepository.create());

      await controller.load();

      expect(controller.notes, hasLength(1));
      expect(controller.unreadableNotes, 1);
    });
  });

  group('Settings resilience', () {
    test('a corrupt settings record falls back to defaults', () async {
      await writeCorrupt(
        BoxNames.settings,
        makeNote(id: 'not-settings', title: 'Wrong type'),
      );
      await Hive.openBox<Settings>(BoxNames.settings);

      final service = SettingsService();
      expect(service.getThemeMode(), ThemeMode.system);
      expect(service.getShowTags(), isTrue);
      expect(service.getSortBy(), 'dateDesc');
    });
  });

  group('StorageService', () {
    test('opens the notes box before settings and is re-runnable', () async {
      await StorageService.init(initFlutter: () async {});
      expect(StorageService.isInitialised, isTrue);
      expect(Hive.isBoxOpen(BoxNames.notes), isTrue);
      expect(Hive.isBoxOpen(BoxNames.folders), isTrue);
      expect(Hive.isBoxOpen(BoxNames.settings), isTrue);
    });

    test('a failed init can be retried', () async {
      await expectLater(
        StorageService.init(
          initFlutter: () async => throw StateError('platform unavailable'),
        ),
        throwsA(isA<StateError>()),
      );
      expect(StorageService.isInitialised, isFalse);

      await StorageService.init(initFlutter: () async {});
      expect(StorageService.isInitialised, isTrue);
      expect(Hive.isBoxOpen(BoxNames.notes), isTrue);
    });
  });

  group('FoxRoot', () {
    testWidgets('shows the failure screen and retries into the app', (
      tester,
    ) async {
      final repository = MemoryRepo();
      await repository.init();
      var attempts = 0;

      Future<StartupBundle> startup() async {
        attempts++;
        if (attempts == 1) throw StateError('storage broken');
        final controller = NotesController(repository);
        await controller.load();
        return StartupBundle(
          notesController: controller,
          settingsService: SettingsService(),
          themeProvider: ThemeProvider(),
          localeProvider: LocaleProvider(),
        );
      }

      await tester.pumpWidget(
        FoxRoot(
          startup: startup,
          appBuilder: (bundle) => MaterialApp(
            home: Scaffold(
              body: Text('open with ${bundle.notesController.notes.length}'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('storage broken'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      expect(attempts, 2);
      expect(find.text('open with 0'), findsOneWidget);
      expect(find.text('Retry'), findsNothing);
    });

    testWidgets('the failure screen keeps the error readable', (tester) async {
      await tester.pumpWidget(
        FoxRoot(
          startup: () async => throw StateError('disk is full'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('disk is full'), findsOneWidget);
    });
  });
}
