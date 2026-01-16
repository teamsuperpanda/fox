import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_quill/flutter_quill.dart';

import 'package:fox/services/repository.dart';
import 'package:fox/services/notes_controller.dart';
import 'package:fox/models/note.dart';

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

    test('search filters notes by title and content', () async {
      await controller.load();
      await controller.addOrUpdate(title: 'Apple', content: Document.fromJson([{"insert":"fruit\n"}]));
      await controller.addOrUpdate(title: 'Banana', content: Document.fromJson([{"insert":"yellow\n"}]));
      await controller.addOrUpdate(title: 'Car', content: Document.fromJson([{"insert":"vehicle\n"}]));

      await controller.setSearchTerm('a');
      expect(controller.notes.length, 3); // Apple, Banana, Car all contain 'a'
      expect(controller.notes.map((n) => n.title), ['Car', 'Banana', 'Apple']); // sorted by date desc

      await controller.setSearchTerm('fruit');
      expect(controller.notes.length, 1);
      expect(controller.notes.first.title, 'Apple');

      await controller.setSearchTerm('');
      expect(controller.notes.length, 3);
    });

    test('search filters notes by tags', () async {
      await controller.load();
      await controller.addOrUpdate(title: 'Note 1', content: Document(), tags: ['work', 'important']);
      await controller.addOrUpdate(title: 'Note 2', content: Document(), tags: ['personal']);
      await controller.addOrUpdate(title: 'Note 3', content: Document());

      await controller.setSearchTerm('work');
      expect(controller.notes.length, 1);
      expect(controller.notes.first.title, 'Note 1');

      await controller.setSearchTerm('personal');
      expect(controller.notes.length, 1);
      expect(controller.notes.first.title, 'Note 2');

      await controller.setSearchTerm('Note');
      expect(controller.notes.length, 3);
    });

    test('sort by title ascending', () async {
      await controller.load();
      await controller.addOrUpdate(title: 'Zebra', content: Document());
      await controller.addOrUpdate(title: 'Apple', content: Document());
      await controller.setSortBy(SortBy.titleAsc);
      expect(controller.notes.map((n) => n.title), ['Apple', 'Zebra']);
    });

    test('sort by title descending', () async {
      await controller.load();
      await controller.addOrUpdate(title: 'Apple', content: Document());
      await controller.addOrUpdate(title: 'Zebra', content: Document());
      await controller.setSortBy(SortBy.titleDesc);
      expect(controller.notes.map((n) => n.title), ['Zebra', 'Apple']);
    });

    test('sort by date ascending', () async {
      await controller.load();
      await controller.addOrUpdate(title: 'Old', content: Document());
      await Future<void>.delayed(const Duration(milliseconds: 5));
      await controller.addOrUpdate(title: 'New', content: Document());
      await controller.setSortBy(SortBy.dateAsc);
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
  });
}
