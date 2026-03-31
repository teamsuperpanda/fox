import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_quill/flutter_quill.dart';

import 'package:fox/services/repository.dart';
import 'package:fox/services/notes_controller.dart';
import 'package:fox/models/note.dart';
import 'package:fox/models/folder.dart';

class MemoryRepo implements NoteRepository {
  final List<Note> _data = [];
  bool _inited = false;

  @override
  Future<void> init() async {
    _inited = true;
  }

  @override
  Future<void> clear() async {
    _data.clear();
  }

  @override
  Future<void> delete(String id) async {
    _data.removeWhere((e) => e.id == id);
  }

  @override
  Future<List<Note>> getAll() async {
    if (!_inited) throw StateError('init not called');
    return List.unmodifiable(_data);
  }

  @override
  Future<Note?> getById(String id) async {
    try {
      return _data.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> upsert(Note note) async {
    _data.removeWhere((e) => e.id == note.id);
    _data.add(note);
  }

  @override
  Future<List<Folder>> getAllFolders() async => [];

  @override
  Future<void> upsertFolder(Folder folder) async {}

  @override
  Future<void> deleteFolder(String id) async {}
}

void main() {
  group('NotesController', () {
    late MemoryRepo repo;
    late NotesController controller;

    setUp(() {
      repo = MemoryRepo();
      controller = NotesController(repo);
    });

    test('initial load -> empty list', () async {
      expect(controller.loading, isFalse);
      await controller.load();
      expect(controller.loading, isFalse);
      expect(controller.notes, isEmpty);
    });

    test('add note -> appears in list', () async {
      await controller.load();
      await controller.addOrUpdate(title: 'A', content: Document.fromJson([{"insert":"content\n"}]));
      expect(controller.notes.length, 1);
      expect(controller.notes.first.title, 'A');
      expect(controller.notes.first.pinned, isFalse);
    });

    test('update note keeps id and changes fields', () async {
      await controller.load();
      await controller.addOrUpdate(title: 'A', content: Document.fromJson([{"insert":"different content\n"}]));
      final first = controller.notes.first;
      await controller.addOrUpdate(
          id: first.id, title: 'B', content: Document.fromJson([{"insert":"c2\n"}]), pinned: true);
      final updated = controller.notes.firstWhere((n) => n.id == first.id);
      expect(updated.title, 'B');
      expect(updated.plainText, 'c2\n');
      expect(updated.pinned, isTrue);
    });

    test('pinning sorts pinned first', () async {
      await controller.load();
      await controller.addOrUpdate(title: 'N1', content: Document());
      await controller.addOrUpdate(title: 'N2', content: Document());
      final n1 = controller.notes.firstWhere((n) => n.title == 'N1');
      await controller.setPinned(n1.id, true);
      expect(controller.notes.first.title, 'N1'); // pinned to top
    });

    test('newest non-pinned appears before older', () async {
      await controller.load();
      await controller.addOrUpdate(title: 'Old', content: Document());
      // Ensure a different updatedAt
      await Future<void>.delayed(const Duration(milliseconds: 5));
      await controller.addOrUpdate(title: 'New', content: Document());
      final titles = controller.notes.map((e) => e.title).toList();
      expect(titles, ['New', 'Old']);
    });

    test('remove deletes note', () async {
      await controller.load();
      await controller.addOrUpdate(title: 'ToDelete', content: Document());
      final id = controller.notes.first.id;
      await controller.remove(id);
      expect(controller.notes.any((n) => n.id == id), isFalse);
    });

    test('find returns note or null', () async {
      await controller.load();
      await controller.addOrUpdate(title: 'A', content: Document());
      final id = controller.notes.first.id;
      expect(controller.find(id)?.title, 'A');
      expect(controller.find('missing'), isNull);
    });

    test('find returns note even when search term filters it from view', () async {
      await controller.load();
      await controller.addOrUpdate(title: 'Alpha', content: Document());
      await controller.addOrUpdate(title: 'Beta', content: Document());

      final alphaId = controller.notes.firstWhere((n) => n.title == 'Alpha').id;

      controller.setSearchTerm('Beta');
      // find() searches _allNotes, so Alpha is still found even though
      // it's filtered out of the visible notes list.
      expect(controller.find(alphaId)?.title, 'Alpha');

      controller.setSearchTerm('');
      expect(controller.find(alphaId)?.title, 'Alpha');
    });

    test('search filters notes by title and content', () async {
      await controller.load();
      await controller.addOrUpdate(title: 'Apple', content: Document.fromJson([{"insert":"fruit\n"}]));
      await controller.addOrUpdate(title: 'Banana', content: Document.fromJson([{"insert":"yellow\n"}]));
      await controller.addOrUpdate(title: 'Car', content: Document.fromJson([{"insert":"vehicle\n"}]));

      controller.setSearchTerm('a');
      expect(controller.notes.length, 3); // Apple, Banana, Car all contain 'a'
      expect(controller.notes.map((n) => n.title), ['Car', 'Banana', 'Apple']); // sorted by date desc

      controller.setSearchTerm('fruit');
      expect(controller.notes.length, 1);
      expect(controller.notes.first.title, 'Apple');

      controller.setSearchTerm('');
      expect(controller.notes.length, 3);
    });

    test('search filters notes by tags', () async {
      await controller.load();
      await controller.addOrUpdate(title: 'Note 1', content: Document(), tags: ['work', 'important']);
      await controller.addOrUpdate(title: 'Note 2', content: Document(), tags: ['personal']);
      await controller.addOrUpdate(title: 'Note 3', content: Document());

      controller.setSearchTerm('work');
      expect(controller.notes.length, 1);
      expect(controller.notes.first.title, 'Note 1');

      controller.setSearchTerm('personal');
      expect(controller.notes.length, 1);
      expect(controller.notes.first.title, 'Note 2');

      controller.setSearchTerm('Note');
      expect(controller.notes.length, 3);
    });

    test('sort by title ascending', () async {
      await controller.load();
      await controller.addOrUpdate(title: 'Zebra', content: Document());
      await controller.addOrUpdate(title: 'Apple', content: Document());
      controller.setSortBy(SortBy.titleAsc);
      expect(controller.notes.map((n) => n.title), ['Apple', 'Zebra']);
    });

    test('sort by title descending', () async {
      await controller.load();
      await controller.addOrUpdate(title: 'Apple', content: Document());
      await controller.addOrUpdate(title: 'Zebra', content: Document());
      controller.setSortBy(SortBy.titleDesc);
      expect(controller.notes.map((n) => n.title), ['Zebra', 'Apple']);
    });

    test('sort by date ascending', () async {
      await controller.load();
      await controller.addOrUpdate(title: 'Old', content: Document());
      await Future<void>.delayed(const Duration(milliseconds: 5));
      await controller.addOrUpdate(title: 'New', content: Document());
      controller.setSortBy(SortBy.dateAsc);
      expect(controller.notes.map((n) => n.title), ['Old', 'New']);
    });

    test('loading state is managed correctly', () async {
      expect(controller.loading, isFalse);
      
      // Start loading
      final loadFuture = controller.load();
      expect(controller.loading, isTrue);
      
      await loadFuture;
      expect(controller.loading, isFalse);
    });

    test('addOrUpdate rejects note with empty title and content', () async {
      await controller.load();
      expect(() => controller.addOrUpdate(title: '', content: Document()), throwsA(isA<ArgumentError>()));
    });

    test('addOrUpdate allows note with title only', () async {
      await controller.load();
      await controller.addOrUpdate(title: 'Title Only', content: Document());
      expect(controller.notes.length, 1);
      expect(controller.notes.first.title, 'Title Only');
    });

    // --- Undo remove ---

    test('undoRemove restores the last deleted note', () async {
      await controller.load();
      await controller.addOrUpdate(title: 'Restore Me', content: Document());
      final id = controller.notes.first.id;

      await controller.remove(id);
      expect(controller.notes, isEmpty);
      expect(controller.lastRemovedNote, isNotNull);

      await controller.undoRemove();
      expect(controller.notes.length, 1);
      expect(controller.notes.first.id, id);
      expect(controller.lastRemovedNote, isNull);
    });

    test('undoRemove does nothing when no note was removed', () async {
      await controller.load();
      await controller.undoRemove();
      expect(controller.notes, isEmpty);
    });

    // --- hasNotes ---

    test('hasNotes is false when empty', () async {
      await controller.load();
      expect(controller.hasNotes, isFalse);
    });

    test('hasNotes is true even when search hides all notes', () async {
      await controller.load();
      await controller.addOrUpdate(title: 'Hidden', content: Document());
      controller.setSearchTerm('zzzzz');
      expect(controller.notes, isEmpty);
      expect(controller.hasNotes, isTrue);
    });

    // --- View option setters ---

    test('setShowTags notifies listeners', () async {
      await controller.load();
      int count = 0;
      controller.addListener(() => count++);
      controller.setShowTags(false);
      expect(controller.showTags, isFalse);
      expect(count, 1);
    });

    test('setShowContent notifies listeners', () async {
      await controller.load();
      int count = 0;
      controller.addListener(() => count++);
      controller.setShowContent(false);
      expect(controller.showContent, isFalse);
      expect(count, 1);
    });

    test('setAlternatingColors notifies listeners', () async {
      await controller.load();
      int count = 0;
      controller.addListener(() => count++);
      controller.setAlternatingColors(true);
      expect(controller.alternatingColors, isTrue);
      expect(count, 1);
    });

    test('setFabAnimation notifies listeners', () async {
      await controller.load();
      int count = 0;
      controller.addListener(() => count++);
      controller.setFabAnimation(false);
      expect(controller.fabAnimation, isFalse);
      expect(count, 1);
    });

    // --- Folder CRUD ---

    test('addFolder creates a folder', () async {
      await controller.load();
      await controller.addFolder('Work');
      expect(controller.folders.length, 1);
      expect(controller.folders.first.name, 'Work');
    });

    test('renameFolder updates the folder name', () async {
      await controller.load();
      await controller.addFolder('Old Name');
      final id = controller.folders.first.id;
      await controller.renameFolder(id, 'New Name');
      expect(controller.folders.first.name, 'New Name');
    });

    test('deleteFolder removes folder and clears notes folderId', () async {
      await controller.load();
      await controller.addFolder('ToDelete');
      final folderId = controller.folders.first.id;

      await controller.addOrUpdate(
        title: 'In Folder',
        content: Document(),
        folderId: folderId,
      );
      expect(controller.notes.first.folderId, folderId);

      await controller.deleteFolder(folderId);
      expect(controller.folders, isEmpty);
      expect(controller.notes.first.folderId, isNull);
    });

    test('deleteFolder clears selectedFolderId when deleting active filter', () async {
      await controller.load();
      await controller.addFolder('Active');
      final folderId = controller.folders.first.id;
      controller.setSelectedFolder(folderId);
      expect(controller.selectedFolderId, folderId);

      await controller.deleteFolder(folderId);
      expect(controller.selectedFolderId, isNull);
    });

    // --- Folder filter ---

    test('setSelectedFolder filters notes by folder', () async {
      await controller.load();
      await controller.addFolder('A');
      final folderId = controller.folders.first.id;

      await controller.addOrUpdate(title: 'InFolder', content: Document(), folderId: folderId);
      await controller.addOrUpdate(title: 'NoFolder', content: Document());

      controller.setSelectedFolder(folderId);
      expect(controller.notes.length, 1);
      expect(controller.notes.first.title, 'InFolder');

      controller.setSelectedFolder(null);
      expect(controller.notes.length, 2);
    });

    test('unfiled filter shows only notes without a folder', () async {
      await controller.load();
      await controller.addFolder('F');
      final folderId = controller.folders.first.id;

      await controller.addOrUpdate(title: 'Filed', content: Document(), folderId: folderId);
      await controller.addOrUpdate(title: 'Unfiled', content: Document());

      controller.setSelectedFolder(NotesController.unfiledFolderId);
      expect(controller.notes.length, 1);
      expect(controller.notes.first.title, 'Unfiled');
    });

    // --- getFolderName ---

    test('getFolderName returns name for valid id', () async {
      await controller.load();
      await controller.addFolder('Named');
      final id = controller.folders.first.id;
      expect(controller.getFolderName(id), 'Named');
    });

    test('getFolderName returns null for unknown id', () async {
      await controller.load();
      expect(controller.getFolderName('non-existent'), isNull);
    });

    test('getFolderName returns null for null id', () async {
      await controller.load();
      expect(controller.getFolderName(null), isNull);
    });

    // --- addOrUpdate with optional fields ---

    test('addOrUpdate stores tags, folderId, and color', () async {
      await controller.load();
      await controller.addOrUpdate(
        title: 'Full',
        content: Document(),
        tags: ['a', 'b'],
        folderId: 'folder-1',
        color: '#FF0000',
      );
      final note = controller.notes.first;
      expect(note.tags, ['a', 'b']);
      expect(note.folderId, 'folder-1');
      expect(note.color, '#FF0000');
    });
  });
}
