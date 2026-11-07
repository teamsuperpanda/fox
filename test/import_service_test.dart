import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fox/models/folder.dart';
import 'package:fox/models/note.dart';
import 'package:fox/models/settings.dart';
import 'package:fox/services/export/export_codec.dart';
import 'package:fox/services/export/export_service.dart';
import 'package:fox/services/import/import_service.dart';
import 'package:fox/services/notes_controller.dart';

import 'test_helpers.dart';

class _ThrowingRepo extends MemoryRepo {
  bool failWrites = false;

  @override
  Future<void> upsertAll(List<Note> notes) {
    if (failWrites) throw StateError('disk full');
    return super.upsertAll(notes);
  }
}

void main() {
  late Directory tempDir;
  late FoxImporter importer;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('fox_import_test');
    importer = FoxImporter(clock: () => DateTime.utc(2026, 6, 1, 12));
  });

  tearDown(() async {
    if (tempDir.existsSync()) await tempDir.delete(recursive: true);
  });

  Future<Uint8List> exportBytes({
    required List<Note> notes,
    required List<Folder> folders,
    Settings? settings,
  }) async {
    final result = await FoxExporter(
      clock: () => DateTime.utc(2026, 5, 1, 10),
    ).export(
      notes: notes,
      folders: folders,
      settings: settings ?? Settings(themeMode: 'dark'),
      outputDirectory: tempDir,
    );
    return result.bytes;
  }

  test('round-trips an export into an empty library', () async {
    final folder = Folder(
      id: 'folder-1',
      name: 'Work',
      createdAt: DateTime.utc(2026),
    );
    final notes = [
      makeNote(
        id: 'note-1',
        title: 'Plan',
        content: r'[{"insert":"ship it\n"}]',
        pinned: true,
        updatedAt: DateTime.utc(2026, 4, 4, 4, 4),
        tags: ['work', 'q2'],
        folderId: 'folder-1',
        color: '#FF5252',
      ),
      makeNote(id: 'note-2', title: 'Loose', content: '[]'),
    ];
    final bytes = await exportBytes(notes: notes, folders: [folder]);

    final repository = MemoryRepo();
    await repository.init();
    final plan = importer.previewBytes(
      source: 'fox-export.zip',
      bytes: bytes,
      existingNotes: await repository.getAll(),
      existingFolders: await repository.getAllFolders(),
    );
    expect(plan.addedCount, 2);
    expect(plan.foldersToAdd.single.id, 'folder-1');

    final result = await importer.apply(
      plan: plan,
      repository: repository,
      backupDirectory: tempDir,
      settings: Settings(themeMode: 'system'),
    );
    expect(result.added, 2);
    expect(result.foldersAdded, 1);
    expect(result.backupPath, isNotNull);
    expect(File(result.backupPath!).existsSync(), isTrue);

    final stored = (await repository.getAll()).toList();
    stored.sort((a, b) => a.id.compareTo(b.id));
    expect(stored, hasLength(2));
    final restored = stored.first;
    expect(restored.id, 'note-1');
    expect(restored.title, 'Plan');
    expect(restored.content, r'[{"insert":"ship it\n"}]');
    expect(restored.pinned, isTrue);
    expect(restored.updatedAt, DateTime.utc(2026, 4, 4, 4, 4));
    expect(restored.tags, ['work', 'q2']);
    expect(restored.folderId, 'folder-1');
    expect(restored.color, '#FF5252');
    expect((await repository.getAllFolders()).single.name, 'Work');
  });

  test('importing the same archive twice does not duplicate notes', () async {
    final bytes = await exportBytes(
      notes: [
        makeNote(id: 'a', title: 'A'),
        makeNote(id: 'b', title: 'B'),
      ],
      folders: const [],
    );
    final repository = MemoryRepo();
    await repository.init();
    final settings = Settings(themeMode: 'system');

    final first = await importer.apply(
      plan: importer.previewBytes(
        source: 'backup.json',
        bytes: bytes,
        existingNotes: const [],
        existingFolders: const [],
      ),
      repository: repository,
      backupDirectory: tempDir,
      settings: settings,
    );
    expect(first.added, 2);

    final second = await importer.apply(
      plan: importer.previewBytes(
        source: 'backup.json',
        bytes: bytes,
        existingNotes: await repository.getAll(),
        existingFolders: await repository.getAllFolders(),
      ),
      repository: repository,
      backupDirectory: tempDir,
      settings: settings,
    );

    expect(second.added, 0);
    expect(second.updated, 0);
    expect(second.skipped, 2);
    expect(await repository.getAll(), hasLength(2));
  });

  test('newer imported notes update, older ones are skipped', () async {
    final existing = [
      makeNote(
        id: 'older-local',
        title: 'Local old',
        updatedAt: DateTime.utc(2026),
      ),
      makeNote(
        id: 'newer-local',
        title: 'Local new',
        updatedAt: DateTime.utc(2026, 12, 31),
      ),
    ];
    final plan = importer.previewBytes(
      source: 'fox-backup.json',
      bytes: Uint8List.fromList(
        utf8.encode(
          FoxExportArchive(
            exportedAt: DateTime.utc(2026),
            appVersion: 'test',
            notes: [
              makeNote(
                id: 'older-local',
                title: 'Imported new',
                updatedAt: DateTime.utc(2026, 2),
              ),
              makeNote(
                id: 'newer-local',
                title: 'Imported old',
                updatedAt: DateTime.utc(2026, 2),
              ),
            ],
            folders: const [],
            settings: Settings(themeMode: 'system'),
          ).encode(),
        ),
      ),
      existingNotes: existing,
      existingFolders: const [],
    );

    expect(plan.notesToAdd, isEmpty);
    expect(plan.notesToUpdate.single.id, 'older-local');
    expect(plan.notesToUpdate.single.title, 'Imported new');
    expect(plan.skippedNotes, 1);
  });

  test('matches folders by name case-insensitively', () async {
    final existingFolder = Folder(
      id: 'local-folder',
      name: 'Work',
      createdAt: DateTime.utc(2026),
    );
    final envelope = FoxExportArchive(
      exportedAt: DateTime.utc(2026),
      appVersion: 'test',
      notes: [
        makeNote(
          id: 'n1',
          title: 'In folder',
          folderId: 'imported-folder',
        ),
      ],
      folders: [
        Folder(
          id: 'imported-folder',
          name: ' work ',
          createdAt: DateTime.utc(2026),
        ),
      ],
      settings: Settings(themeMode: 'system'),
    );

    final plan = importer.previewBytes(
      source: 'backup.json',
      bytes: Uint8List.fromList(utf8.encode(envelope.encode())),
      existingNotes: const [],
      existingFolders: [existingFolder],
    );

    expect(plan.foldersToAdd, isEmpty);
    expect(plan.notesToAdd.single.folderId, 'local-folder');
  });

  test('rejects a newer schema version without writing anything', () async {
    final json = jsonDecode(
      FoxExportArchive(
        exportedAt: DateTime.utc(2026),
        appVersion: 'test',
        notes: const [],
        folders: const [],
        settings: Settings(themeMode: 'system'),
      ).encode(),
    ) as Map<String, dynamic>;
    json['schemaVersion'] = FoxExportArchive.currentSchemaVersion + 1;

    expect(
      () => importer.previewBytes(
        source: 'future.json',
        bytes: Uint8List.fromList(utf8.encode(jsonEncode(json))),
        existingNotes: const [],
        existingFolders: const [],
      ),
      throwsA(
        isA<ImportException>().having(
          (e) => e.message,
          'message',
          contains('Update Fox'),
        ),
      ),
    );
  });

  test('rejects a truncated archive', () async {
    final json = jsonDecode(
      FoxExportArchive(
        exportedAt: DateTime.utc(2026),
        appVersion: 'test',
        notes: [makeNote(id: 'a', title: 'A')],
        folders: const [],
        settings: Settings(themeMode: 'system'),
      ).encode(),
    ) as Map<String, dynamic>;
    (json['notes'] as List<dynamic>).clear();

    expect(
      () => importer.previewBytes(
        source: 'broken.json',
        bytes: Uint8List.fromList(utf8.encode(jsonEncode(json))),
        existingNotes: const [],
        existingFolders: const [],
      ),
      throwsA(isA<ImportException>()),
    );
  });

  test('writes the backup before mutating and aborts if the write fails',
      () async {
    final bytes = await exportBytes(
      notes: [makeNote(id: 'a', title: 'A')],
      folders: const [],
    );
    final repository = _ThrowingRepo();
    await repository.init();
    final plan = importer.previewBytes(
      source: 'backup.json',
      bytes: bytes,
      existingNotes: const [],
      existingFolders: const [],
    );

    repository.failWrites = true;
    await expectLater(
      importer.apply(
        plan: plan,
        repository: repository,
        backupDirectory: tempDir,
        settings: Settings(themeMode: 'system'),
      ),
      throwsA(isA<StateError>()),
    );

    final backups = tempDir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.contains('pre-import-'))
        .toList();
    expect(backups, hasLength(1));
    expect(await repository.getAll(), isEmpty);
  });

  test('surfaces an unreadable zip cleanly', () async {
    expect(
      () => importer.previewBytes(
        source: 'broken.zip',
        bytes: Uint8List.fromList([0x50, 0x4B, 0x03, 0x04, 0x00, 0x00]),
        existingNotes: const [],
        existingFolders: const [],
      ),
      throwsA(isA<ImportException>()),
    );
  });

  group('Markdown and text', () {
    test('imports a Markdown file with front matter', () async {
      const markdown = '''
---
id: "meeting-1"
title: "Weekly sync"
updatedAt: "2026-03-01T09:00:00.000Z"
pinned: true
tags: ["work", "meeting"]
folder: "Work"
---

# Weekly sync

- ship the export
''';
      final plan = importer.previewBytes(
        source: 'weekly.md',
        bytes: Uint8List.fromList(utf8.encode(markdown)),
        existingNotes: const [],
        existingFolders: const [],
      );

      expect(plan.addedCount, 1);
      final note = plan.notesToAdd.single;
      expect(note.id, 'meeting-1');
      expect(note.title, 'Weekly sync');
      expect(note.pinned, isTrue);
      expect(note.tags, ['work', 'meeting']);
      expect(note.updatedAt, DateTime.utc(2026, 3, 1, 9));
      expect(note.content, contains('ship the export'));
      expect(plan.foldersToAdd.single.name, 'Work');
      expect(note.folderId, plan.foldersToAdd.single.id);
    });

    test('uses the first line as the title for plain text', () async {
      final plan = importer.previewBytes(
        source: 'shopping.txt',
        bytes: Uint8List.fromList(utf8.encode('Shopping\nmilk\neggs')),
        existingNotes: const [],
        existingFolders: const [],
      );

      expect(plan.notesToAdd.single.title, 'Shopping');
      expect(plan.notesToAdd.single.content, contains('milk'));
    });

    test('skips empty files with a warning', () async {
      final plan = importer.previewFiles(
        files: [
          ImportFile(
            name: 'empty.txt',
            bytes: Uint8List.fromList(utf8.encode('   \n')),
          ),
          ImportFile(
            name: 'note.txt',
            bytes: Uint8List.fromList(utf8.encode('Hello')),
          ),
        ],
        existingNotes: const [],
        existingFolders: const [],
      );

      expect(plan.addedCount, 1);
      expect(plan.skippedNotes, 1);
      expect(plan.warnings.single, contains('empty.txt'));
    });

    test('imports Markdown files out of a zip without a backup JSON', () async {
      final archive = Archive()
        ..add(
          ArchiveFile.string(
            'markdown/Unfiled/Hello.md',
            '---\ntitle: "Hello from zip"\n---\n\nbody text',
          ),
        );
      final zipBytes = ZipEncoder().encodeBytes(archive);

      final plan = importer.previewBytes(
        source: 'markdown.zip',
        bytes: zipBytes,
        existingNotes: const [],
        existingFolders: const [],
      );

      expect(plan.addedCount, 1);
      expect(plan.notesToAdd.single.title, 'Hello from zip');
    });
  });

  test('controller import refreshes the visible library', () async {
    final controller = NotesController(MemoryRepo());
    await controller.load();
    final bytes = await exportBytes(
      notes: [
        makeNote(
          id: 'imported',
          title: 'From backup',
          content: r'[{"insert":"hi\n"}]',
        ),
      ],
      folders: const [],
    );

    final result = await controller.importFromFiles(
      files: [ImportFile(name: 'backup.zip', bytes: bytes)],
      backupDirectory: tempDir,
    );

    expect(result.added, 1);
    expect(controller.allNotes, hasLength(1));
    expect(controller.notes.single.title, 'From backup');
  });
}
