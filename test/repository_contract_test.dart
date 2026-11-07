import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:fox/models/folder.dart';
import 'package:fox/models/folder_adapter.dart';
import 'package:fox/models/note.dart';
import 'package:fox/models/note_adapter.dart';
import 'package:fox/services/box_names.dart';
import 'package:fox/services/repository_hive.dart';
import 'package:hive/hive.dart';

import 'test_helpers.dart';

/// The same behaviour must hold for every [NoteAndFolderRepository].
void runRepositoryContract(
  String name,
  Future<NoteAndFolderRepository> Function() createRepository,
) {
  group('$name contract', () {
    late NoteAndFolderRepository repository;

    setUp(() async {
      repository = await createRepository();
      await repository.init();
    });

    test('starts empty', () async {
      expect(await repository.getAll(), isEmpty);
      expect(await repository.getAllFolders(), isEmpty);
      expect(repository.unreadableRecords, 0);
    });

    test('upsert stores a note and getAll returns it', () async {
      final note = makeNote(
        id: 'note-1',
        title: 'Groceries',
        content: r'[{"insert":"milk\n"}]',
        pinned: true,
        tags: ['home'],
        folderId: 'folder-1',
        color: '#FF5252',
        updatedAt: DateTime.utc(2026, 3, 4),
      );

      await repository.upsert(note);
      final notes = await repository.getAll();

      expect(notes, hasLength(1));
      final stored = notes.single;
      expect(stored.id, 'note-1');
      expect(stored.title, 'Groceries');
      expect(stored.content, r'[{"insert":"milk\n"}]');
      expect(stored.pinned, isTrue);
      expect(stored.tags, ['home']);
      expect(stored.folderId, 'folder-1');
      expect(stored.color, '#FF5252');
      expect(stored.updatedAt, DateTime.utc(2026, 3, 4));
    });

    test('upsert with the same id replaces the note', () async {
      final note = makeNote(id: 'note-1', title: 'First');
      await repository.upsert(note);
      await repository.upsert(note.copyWith(title: 'Second'));

      final notes = await repository.getAll();
      expect(notes, hasLength(1));
      expect(notes.single.title, 'Second');
    });

    test('upsertAll stores every note', () async {
      await repository.upsertAll([
        makeNote(id: 'a', title: 'A'),
        makeNote(id: 'b', title: 'B'),
        makeNote(id: 'c', title: 'C'),
      ]);

      final ids = (await repository.getAll()).map((n) => n.id).toSet();
      expect(ids, {'a', 'b', 'c'});
    });

    test('delete removes only the requested note', () async {
      await repository.upsertAll([
        makeNote(id: 'keep', title: 'Keep'),
        makeNote(id: 'drop', title: 'Drop'),
      ]);

      await repository.delete('drop');

      final notes = await repository.getAll();
      expect(notes.map((n) => n.id), ['keep']);
    });

    test('deleting an unknown id is a no-op', () async {
      await repository.upsert(makeNote(id: 'keep', title: 'Keep'));
      await repository.delete('missing');

      expect(await repository.getAll(), hasLength(1));
    });

    test('folders round-trip and delete', () async {
      final folder = Folder(
        id: 'folder-1',
        name: 'Work',
        createdAt: DateTime.utc(2026),
      );
      await repository.upsertFolder(folder);

      expect(
        (await repository.getAllFolders()).single.name,
        'Work',
      );

      await repository.upsertFolder(folder.copyWith(name: 'Office'));
      expect(
        (await repository.getAllFolders()).single.name,
        'Office',
      );

      await repository.deleteFolder('folder-1');
      expect(await repository.getAllFolders(), isEmpty);
    });

    test('deleting an unknown folder is a no-op', () async {
      await repository.deleteFolder('missing');
      expect(await repository.getAllFolders(), isEmpty);
    });
  });
}

void main() {
  runRepositoryContract(
    'MemoryRepo',
    () async => MemoryRepo(),
  );

  group('HiveNoteRepository (contract harness)', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('fox_contract_test');
      Hive.init(tempDir.path);
      if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(NoteAdapter());
      if (!Hive.isAdapterRegistered(4)) Hive.registerAdapter(FolderAdapter());
    });

    tearDown(() async {
      await Hive.close();
      if (tempDir.existsSync()) await tempDir.delete(recursive: true);
    });

    runRepositoryContract('HiveNoteRepository', () async {
      final repository = HiveNoteRepository.create();
      await Hive.openBox<Note>(BoxNames.notes);
      await Hive.openBox<Folder>(BoxNames.folders);
      await repository.clear();
      return repository;
    });
  });
}
