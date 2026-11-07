import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fox/services/notes_controller.dart';

import 'test_helpers.dart';

void main() {
  group('Archive', () {
    late MemoryRepo repo;
    late NotesController controller;

    setUp(() async {
      repo = MemoryRepo();
      controller = NotesController(repo);
    });

    test('archiving hides a note from the main list and search', () async {
      await controller.load();
      await controller.addOrUpdate(title: 'Reference', content: Document());
      final id = controller.notes.first.id;

      await controller.archive(id);

      expect(controller.notes, isEmpty);
      expect(controller.archivedNotes.map((n) => n.id), [id]);
      controller.setSearchTerm('Reference');
      expect(controller.notes, isEmpty);
    });

    test('include archived puts archived notes back in the list and search',
        () async {
      await controller.load();
      await controller.addOrUpdate(title: 'Reference', content: Document());
      final id = controller.notes.first.id;
      await controller.archive(id);

      await controller.setIncludeArchived(true);

      expect(controller.includeArchived, isTrue);
      expect(controller.notes.map((n) => n.id), [id]);
      controller.setSearchTerm('Reference');
      expect(controller.notes.map((n) => n.id), [id]);
    });

    test('restore returns the note to its folder and position', () async {
      await controller.load();
      await controller.addFolder('Work');
      final folderId = controller.folders.first.id;
      await repo.upsert(
        makeNote(
          id: 'older',
          title: 'Older',
          folderId: folderId,
          updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
      );
      await controller.addOrUpdate(title: 'Newer', content: Document());
      await controller.load();

      await controller.archive('older');
      expect(controller.notes.map((n) => n.title), ['Newer']);

      await controller.unarchive('older');

      expect(controller.archivedNotes, isEmpty);
      expect(controller.find('older')?.folderId, folderId);
      expect(controller.notes.map((n) => n.title), ['Newer', 'Older']);
    });

    test('archived notes survive a restart', () async {
      await controller.load();
      await controller.addOrUpdate(title: 'Keep', content: Document());
      final id = controller.notes.first.id;
      await controller.archive(id);

      final restarted = NotesController(repo);
      await restarted.load();

      expect(restarted.archivedNotes.map((n) => n.id), [id]);
      expect(restarted.notes, isEmpty);
    });

    test('editing an archived note moves it back to the main list', () async {
      await controller.load();
      await controller.addOrUpdate(title: 'Keep', content: Document());
      final id = controller.notes.first.id;
      await controller.archive(id);

      await controller.addOrUpdate(
        id: id,
        title: 'Keep edited',
        content: Document(),
      );

      expect(controller.archivedNotes, isEmpty);
      expect(controller.notes.single.title, 'Keep edited');
    });

    test('deleting an archived note removes it from the archive', () async {
      await controller.load();
      await controller.addOrUpdate(title: 'Keep', content: Document());
      final id = controller.notes.first.id;
      await controller.archive(id);

      await controller.remove(id);

      expect(controller.archivedNotes, isEmpty);
      expect(await repo.getAll(), isEmpty);
    });
  });
}
