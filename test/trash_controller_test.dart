import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fox/services/notes_controller.dart';

import 'test_helpers.dart';

void main() {
  group('Trash', () {
    late MemoryRepo repo;
    late NotesController controller;

    setUp(() async {
      repo = MemoryRepo();
      controller = NotesController(repo);
    });

    Future<void> addNote(String title) async {
      await controller.addOrUpdate(title: title, content: Document());
    }

    test('deleting a note hides it and moves it to the trash', () async {
      await controller.load();
      await addNote('Throw away');
      final id = controller.notes.first.id;

      await controller.remove(id);

      expect(controller.notes, isEmpty);
      expect(controller.trash.length, 1);
      expect(controller.trash.first.id, id);
      expect(controller.trash.first.deletedAt, isNotNull);
      expect(controller.canUndo, isTrue);
    });

    test('restore returns the note to its folder and sort position', () async {
      await controller.load();
      await controller.addFolder('Work');
      final folderId = controller.folders.first.id;
      final older = DateTime.now().subtract(const Duration(hours: 2));
      await repo.upsert(
        makeNote(
          id: 'older',
          title: 'Older',
          folderId: folderId,
          updatedAt: older,
        ),
      );
      await addNote('Newer');
      await controller.load();

      await controller.remove('older');
      expect(controller.notes.map((n) => n.title), ['Newer']);

      await controller.restore('older');

      final restored = controller.find('older');
      expect(restored, isNotNull);
      expect(restored!.folderId, folderId);
      expect(controller.trash, isEmpty);
      expect(controller.notes.map((n) => n.title), ['Newer', 'Older']);
    });

    test('undo works through several deletes in order', () async {
      await controller.load();
      await addNote('A');
      await addNote('B');
      await addNote('C');
      final ids = {
        for (final note in controller.notes) note.title: note.id,
      };

      await controller.remove(ids['A']!);
      await controller.remove(ids['B']!);
      await controller.remove(ids['C']!);
      expect(controller.trash.length, 3);

      await controller.undoRemove();
      expect(controller.notes.map((n) => n.title), contains('C'));
      await controller.undoRemove();
      expect(controller.notes.map((n) => n.title), contains('B'));
      await controller.undoRemove();
      expect(controller.notes.map((n) => n.title), contains('A'));

      expect(controller.trash, isEmpty);
      expect(controller.canUndo, isFalse);
    });

    test('undo still works after an unrelated pin', () async {
      await controller.load();
      await addNote('Pinned later');
      await addNote('Deleted');
      final deletedId =
          controller.notes.firstWhere((n) => n.title == 'Deleted').id;
      final pinnedId =
          controller.notes.firstWhere((n) => n.title == 'Pinned later').id;

      await controller.remove(deletedId);
      await controller.setPinned(pinnedId, true);

      await controller.undoRemove();

      expect(controller.find(deletedId)?.deletedAt, isNull);
      expect(controller.notes.any((n) => n.id == deletedId), isTrue);
    });

    test('the undo stack is bounded and skips permanently deleted notes',
        () async {
      await controller.load();
      for (var i = 0; i < NotesController.undoLimit + 2; i++) {
        await addNote('Note $i');
      }
      final ids = controller.notes.map((n) => n.id).toList();
      for (final id in ids) {
        await controller.remove(id);
      }

      var undone = 0;
      while (controller.canUndo) {
        await controller.undoRemove();
        undone++;
      }

      expect(undone, NotesController.undoLimit);
      expect(controller.trash.length, ids.length - NotesController.undoLimit);
    });

    test('trash survives a restart', () async {
      await controller.load();
      await addNote('Keep in trash');
      final id = controller.notes.first.id;
      await controller.remove(id);

      final restarted = NotesController(repo);
      await restarted.load();

      expect(restarted.trash.map((n) => n.id), [id]);
      expect(restarted.notes, isEmpty);
    });

    test('purges trashed notes older than the retention period on load',
        () async {
      final old = makeNote(
        id: 'old',
        title: 'Old',
        deletedAt: DateTime.now().subtract(const Duration(days: 31)),
      );
      final recent = makeNote(
        id: 'recent',
        title: 'Recent',
        deletedAt: DateTime.now().subtract(const Duration(days: 10)),
      );
      await repo.upsert(old);
      await repo.upsert(recent);

      await controller.load();

      expect(controller.trash.map((n) => n.id), ['recent']);
      final stored = await repo.getAll();
      expect(stored.map((n) => n.id), ['recent']);
    });

    test('delete permanently removes one note and its undo entry', () async {
      await controller.load();
      await addNote('Gone');
      final id = controller.notes.first.id;
      await controller.remove(id);

      await controller.deletePermanently(id);

      expect(controller.trash, isEmpty);
      expect(controller.canUndo, isFalse);
      expect(await repo.getAll(), isEmpty);
    });

    test('empty trash removes every trashed note', () async {
      await controller.load();
      await addNote('One');
      await addNote('Two');
      for (final note in [...controller.notes]) {
        await controller.remove(note.id);
      }

      await controller.emptyTrash();

      expect(controller.trash, isEmpty);
      expect(controller.canUndo, isFalse);
      expect(await repo.getAll(), isEmpty);
    });
  });
}
