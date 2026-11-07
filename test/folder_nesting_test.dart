import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fox/services/notes_controller.dart';

import 'test_helpers.dart';

void main() {
  group('Folder nesting', () {
    late MemoryRepo repo;
    late NotesController controller;

    setUp(() async {
      repo = MemoryRepo();
      controller = NotesController(repo);
    });

    test('a folder can have one level of children', () async {
      await controller.load();
      await controller.addFolder('Work');
      final work = controller.rootFolders.single;

      await controller.addFolder('Recipes', parentId: work.id);

      expect(controller.childFolders(work.id).single.name, 'Recipes');
      expect(controller.folderPath(work.id), 'Work');
      expect(
        controller.folderPath(controller.childFolders(work.id).single.id),
        'Work / Recipes',
      );
    });

    test('a third level is rejected', () async {
      await controller.load();
      await controller.addFolder('Work');
      final work = controller.rootFolders.single;
      await controller.addFolder('Recipes', parentId: work.id);
      final recipes = controller.childFolders(work.id).single;

      expect(
        () => controller.addFolder('Cakes', parentId: recipes.id),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('an unknown parent is rejected', () async {
      await controller.load();
      expect(
        () => controller.addFolder('Orphan', parentId: 'missing'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('moving a note files it and undo restores the old folder', () async {
      await controller.load();
      await controller.addFolder('Work');
      await controller.addFolder('Personal');
      final work = controller.folders.firstWhere((f) => f.name == 'Work');
      final personal =
          controller.folders.firstWhere((f) => f.name == 'Personal');
      await controller.addOrUpdate(
        title: 'File me',
        content: Document(),
        folderId: work.id,
      );
      final note = controller.notes.single;
      final previousUpdatedAt = note.updatedAt;

      await controller.moveToFolder(note.id, personal.id);

      expect(controller.find(note.id)?.folderId, personal.id);
      expect(controller.canUndoMove, isTrue);

      await controller.undoMove();

      final restored = controller.find(note.id);
      expect(restored?.folderId, work.id);
      expect(restored?.updatedAt, previousUpdatedAt);
      expect(controller.canUndoMove, isFalse);
    });

    test('moving a note to unfiled clears its folder', () async {
      await controller.load();
      await controller.addFolder('Work');
      final work = controller.folders.single;
      await controller.addOrUpdate(
        title: 'File me',
        content: Document(),
        folderId: work.id,
      );
      final note = controller.notes.single;

      await controller.moveToFolder(note.id, null);

      expect(controller.find(note.id)?.folderId, isNull);
    });

    test('deleting a parent reparents children and unfiles their notes',
        () async {
      await controller.load();
      await controller.addFolder('Work');
      final work = controller.rootFolders.single;
      await controller.addFolder('Recipes', parentId: work.id);
      final recipes = controller.childFolders(work.id).single;

      await repo.upsert(
        makeNote(id: 'in-parent', title: 'In parent', folderId: work.id),
      );
      await repo.upsert(
        makeNote(id: 'in-child', title: 'In child', folderId: recipes.id),
      );
      await controller.load();

      await controller.deleteFolder(work.id);

      expect(controller.folders.map((f) => f.id), [recipes.id]);
      expect(controller.childFolders(work.id), isEmpty);
      expect(controller.folders.single.parentId, isNull);
      expect(controller.find('in-parent')?.folderId, isNull);
      expect(controller.find('in-child')?.folderId, isNull);
    });

    test('deleting a child folder unfiles only its notes', () async {
      await controller.load();
      await controller.addFolder('Work');
      final work = controller.rootFolders.single;
      await controller.addFolder('Recipes', parentId: work.id);
      final recipes = controller.childFolders(work.id).single;
      await repo.upsert(
        makeNote(id: 'in-parent', title: 'In parent', folderId: work.id),
      );
      await repo.upsert(
        makeNote(id: 'in-child', title: 'In child', folderId: recipes.id),
      );
      await controller.load();

      await controller.deleteFolder(recipes.id);

      expect(controller.folders.single.id, work.id);
      expect(controller.find('in-child')?.folderId, isNull);
      expect(controller.find('in-parent')?.folderId, work.id);
    });
  });
}
