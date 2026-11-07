import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:fox/models/folder.dart';
import 'package:fox/models/note.dart';
import 'package:fox/models/settings.dart';
import 'package:fox/services/box_names.dart';
import 'package:fox/services/data_export.dart';
import 'package:fox/services/storage_service.dart';
import 'package:hive/hive.dart';

import 'test_helpers.dart';

void main() {
  group('DataExport', () {
    setUp(() async {
      await hiveTestSetup('./test/hive_data_export_test');
      StorageService.registerAdapters();
      await Hive.openBox<Note>(BoxNames.notes);
      await Hive.openBox<Folder>(BoxNames.folders);
    });

    tearDown(() async {
      await hiveTestTeardown();
    });

    test('includes every readable note, folder and setting', () async {
      await Hive.box<Note>(BoxNames.notes).put(
        'note-1',
        makeNote(
          id: 'note-1',
          title: 'Backup me',
          tags: ['a'],
          folderId: 'folder-1',
        ),
      );
      await Hive.box<Folder>(BoxNames.folders).put(
        'folder-1',
        Folder(id: 'folder-1', name: 'Work', createdAt: DateTime.utc(2024)),
      );
      await Hive.box<Settings>(BoxNames.settings).put(
        'app_settings',
        Settings(themeMode: 'dark', locale: 'de'),
      );

      final decoded =
          jsonDecode(DataExport.buildBackup()) as Map<String, dynamic>;

      final notes = decoded['notes'] as List;
      final folders = decoded['folders'] as List;
      final settings = decoded['settings'] as Map<String, dynamic>;

      expect(decoded['app'], 'fox');
      expect(notes.length, 1);
      expect((notes.first as Map<String, dynamic>)['title'], 'Backup me');
      expect((folders.first as Map<String, dynamic>)['name'], 'Work');
      expect(settings['themeMode'], 'dark');
    });

    test('skips boxes that are not open instead of throwing', () async {
      await Hive.box<Note>(BoxNames.notes).close();
      await Hive.box<Folder>(BoxNames.folders).close();

      final decoded =
          jsonDecode(DataExport.buildBackup()) as Map<String, dynamic>;

      expect(decoded['notes'], isEmpty);
      expect(decoded['folders'], isEmpty);
    });
  });
}
