import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:fox/models/adapter_utils.dart';
import 'package:fox/models/folder.dart';
import 'package:fox/models/note.dart';
import 'package:fox/models/settings.dart';
import 'package:fox/services/box_names.dart';
import 'package:fox/services/schema_migrations.dart';
import 'package:fox/services/storage_service.dart';
import 'package:hive/hive.dart';

Future<Directory> _copyFixture() async {
  final dir = await Directory.systemTemp.createTemp('fox_schema_v1');
  final source = Directory('test/fixtures/v1');
  for (final file in source.listSync().whereType<File>()) {
    await file.copy('${dir.path}/${file.uri.pathSegments.last}');
  }
  return dir;
}

Future<SchemaBoxes> _boxes() async {
  return SchemaBoxes(
    notes: await Hive.openBox<Note>(BoxNames.notes),
    folders: await Hive.openBox<Folder>(BoxNames.folders),
    settings: await Hive.openBox<Settings>(BoxNames.settings),
  );
}

void main() {
  group('v1 fixture', () {
    late Directory dir;

    setUp(() async {
      dir = await _copyFixture();
      Hive.init(dir.path);
    });

    tearDown(() async {
      await Hive.close();
      await Hive.deleteFromDisk();
      await dir.delete(recursive: true);
    });

    test('opens a v1 box and preserves every note, folder and setting',
        () async {
      await StorageService.openBoxes();

      final notes = Hive.box<Note>(BoxNames.notes);
      expect(notes.length, 2);

      final first = notes.get('note-1');
      expect(first, isNotNull);
      expect(first!.title, 'First note');
      expect(first.content, r'{"ops":[{"insert":"Hello from v1\n"}]}');
      expect(first.pinned, isTrue);
      expect(
        first.updatedAt.millisecondsSinceEpoch,
        DateTime.utc(2024, 3, 4, 10, 30).millisecondsSinceEpoch,
      );
      expect(first.tags, ['work', 'important']);
      expect(first.folderId, 'folder-1');
      expect(first.color, '#FF5252');

      final second = notes.get('note-2');
      expect(second, isNotNull);
      expect(second!.folderId, isNull);
      expect(second.color, isNull);

      final folder = Hive.box<Folder>(BoxNames.folders).get('folder-1');
      expect(folder, isNotNull);
      expect(folder!.name, 'Work');

      final settings =
          Hive.box<Settings>(BoxNames.settings).get('app_settings');
      expect(settings, isNotNull);
      expect(settings!.themeMode, 'dark');
      expect(settings.locale, 'fr');
      expect(settings.sortBy, 'titleAsc');
    });

    test('records the schema version after a successful open', () async {
      await StorageService.openBoxes();

      final schema = Hive.box<int>(BoxNames.schema);
      expect(schema.get(schemaVersionKey), currentSchemaVersion);
    });

    test('a migration that adds a nullable field does not throw', () async {
      final visited = <String>[];

      await StorageService.openBoxes(
        targetVersion: currentSchemaVersion + 1,
        migrations: {
          currentSchemaVersion: (boxes) async {
            for (final key in boxes.notes.keys.toList()) {
              final note = boxes.notes.get(key);
              if (note == null) continue;
              visited.add(note.id);
              // Stand-in for adding a nullable field: every note is rewritten
              // through the adapter with its defaults, which must not throw.
              await boxes.notes.put(key, note.copyWith());
            }
          },
        },
      );

      expect(visited, containsAll(['note-1', 'note-2']));
      expect(
        Hive.box<int>(BoxNames.schema).get(schemaVersionKey),
        currentSchemaVersion + 1,
      );
      expect(Hive.box<Note>(BoxNames.notes).get('note-1')!.tags,
          ['work', 'important']);
    });
  });

  group('runSchemaMigrations', () {
    late Directory dir;

    setUp(() async {
      dir = await Directory.systemTemp.createTemp('fox_schema_runner');
      Hive.init(dir.path);
      StorageService.registerAdapters();
    });

    tearDown(() async {
      await Hive.close();
      await Hive.deleteFromDisk();
      await dir.delete(recursive: true);
    });

    test('refuses to open a box written by a newer app version', () async {
      final boxes = await _boxes();
      await expectLater(
        runSchemaMigrations(from: 2, to: 1, boxes: boxes),
        throwsA(isA<SchemaMigrationException>()),
      );
    });

    test('fails loudly when a step is missing', () async {
      final boxes = await _boxes();
      await expectLater(
        runSchemaMigrations(from: 1, to: 2, boxes: boxes, migrations: const {}),
        throwsA(isA<SchemaMigrationException>()),
      );
    });

    test('runs steps in order', () async {
      final boxes = await _boxes();
      final order = <int>[];
      await runSchemaMigrations(
        from: 1,
        to: 3,
        boxes: boxes,
        migrations: {
          1: (_) async => order.add(1),
          2: (_) async => order.add(2),
        },
      );
      expect(order, [1, 2]);
    });
  });

  group('tolerant readers', () {
    test('return defaults for missing or unexpected values', () {
      expect(readString('x'), 'x');
      expect(readString(42), isNull);
      expect(readBool(true), isTrue);
      expect(readBool('true'), isNull);
      expect(readInt(7), 7);
      expect(readInt(7.9), 7);
      expect(readInt('7'), isNull);
      expect(readDate(null), isNull);
      expect(readDate(1000), DateTime.fromMillisecondsSinceEpoch(1000));
      expect(readStringList(42), isEmpty);
      expect(readStringList([1, 'a']), ['1', 'a']);
    });
  });
}
