import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:fox/models/folder.dart';
import 'package:fox/models/folder_adapter.dart';
import 'package:fox/models/note.dart';
import 'package:fox/models/note_adapter.dart';
import 'package:fox/models/settings.dart';
import 'package:fox/models/settings_adapter.dart';
import 'package:fox/services/box_names.dart';
import 'package:hive_ce/hive.dart';

Future<Directory> _copyFixture() async {
  final dir = await Directory.systemTemp.createTemp('fox_hive_ce_v2');
  final source = Directory('test/fixtures/v2');
  for (final file in source.listSync().whereType<File>()) {
    await file.copy('${dir.path}/${file.uri.pathSegments.last}');
  }
  return dir;
}

void main() {
  group('hive_ce migration', () {
    late Directory dir;

    setUp(() async {
      dir = await _copyFixture();
      Hive.init(dir.path);
      if (!Hive.isAdapterRegistered(2)) {
        Hive.registerAdapter(SettingsAdapter());
      }
      if (!Hive.isAdapterRegistered(3)) {
        Hive.registerAdapter(NoteAdapter());
      }
      if (!Hive.isAdapterRegistered(4)) {
        Hive.registerAdapter(FolderAdapter());
      }
    });

    tearDown(() async {
      await Hive.close();
      await Hive.deleteFromDisk();
      await dir.delete(recursive: true);
    });

    test('opens a box written by Hive 2 and reads every note', () async {
      final notes = await Hive.openBox<Note>(BoxNames.notes);
      final folders = await Hive.openBox<Folder>(BoxNames.folders);
      final settings = await Hive.openBox<Settings>(BoxNames.settings);

      expect(notes.length, 2);
      final first = notes.get('note-1');
      expect(first, isNotNull);
      expect(first!.title, 'First note');
      expect(first.pinned, isTrue);
      expect(first.tags, ['work', 'important']);
      expect(first.folderId, 'folder-1');
      expect(first.color, '#FF5252');
      expect(
        first.updatedAt.millisecondsSinceEpoch,
        DateTime.utc(2024, 3, 4, 10, 30).millisecondsSinceEpoch,
      );

      final second = notes.get('note-2');
      expect(second, isNotNull);
      expect(second!.title, 'Second note');

      expect(folders.get('folder-1')?.name, 'Work');
      final storedSettings = settings.get('app_settings');
      expect(storedSettings, isNotNull);
      expect(storedSettings!.themeMode, 'dark');
      expect(storedSettings.locale, 'fr');
      expect(storedSettings.sortBy, 'titleAsc');
    });

    test('no Hive 2 package remains in the lockfile', () {
      final lock = File('pubspec.lock').readAsStringSync();
      expect(lock.contains('\n  hive:\n'), isFalse);
      expect(lock.contains('\n  hive_flutter:\n'), isFalse);
      expect(lock.contains('\n  hive_ce:\n'), isTrue);
      expect(lock.contains('\n  hive_ce_flutter:\n'), isTrue);
    });
  });
}
