import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fox/models/note.dart';
import 'package:fox/services/notes_controller.dart';
import 'package:fox/services/repository.dart';
import 'package:fox/note_detail_page.dart';

class MockRepository implements NoteRepository {
  final List<Note> notes = [];

  @override
  Future<void> init() async {}

  @override
  Future<void> upsert(Note note) async {
    final index = notes.indexWhere((n) => n.id == note.id);
    if (index >= 0) {
      notes[index] = note;
    } else {
      notes.add(note);
    }
  }

  @override
  Future<void> delete(String id) async {
    notes.removeWhere((n) => n.id == id);
  }

  @override
  Future<List<Note>> getAll() async => notes;

  @override
  Future<Note?> getById(String id) async {
    return notes.firstWhere((n) => n.id == id, orElse: () => throw Exception());
  }

  @override
  Future<void> clear() async {
    notes.clear();
  }
}

void main() {
  group('NoteDetailPage - Basic Tests', () {
    test('Note copyWith updates pinned state', () {
      final original = Note(
        id: 'test',
        title: 'Title',
        content: '{}',
        pinned: false,
        updatedAt: DateTime.now(),
      );
      
      final updated = original.copyWith(pinned: true);
      expect(updated.pinned, isTrue);
      expect(updated.id, equals('test'));
    });

    test('Note copyWith preserves other fields', () {
      final now = DateTime.now();
      final original = Note(
        id: 'test',
        title: 'Title',
        content: '{}',
        pinned: false,
        updatedAt: now,
      );

      final updated = original.copyWith(pinned: true);
      expect(updated.title, equals('Title'));
      expect(updated.updatedAt, equals(now));
    });
  });

  group('NoteDetailPage - Controller Tests', () {
    late MockRepository mockRepo;
    late NotesController controller;

    setUp(() {
      mockRepo = MockRepository();
      controller = NotesController(mockRepo);
    });

    test('controller adds new note', () async {
      final doc = Document();
      await controller.addOrUpdate(
        title: 'New Note',
        content: doc,
        pinned: false,
      );

      expect(mockRepo.notes.length, equals(1));
      expect(mockRepo.notes.first.title, equals('New Note'));
    });

    test('controller updates existing note', () async {
      final originalNote = Note(
        id: 'test-id',
        title: 'Original',
        content: '{}',
        pinned: false,
        updatedAt: DateTime.now(),
      );

      mockRepo.notes.add(originalNote);

      await controller.addOrUpdate(
        id: 'test-id',
        title: 'Updated',
        content: Document(),
        pinned: true,
      );

      expect(mockRepo.notes.length, equals(1));
      expect(mockRepo.notes.first.title, equals('Updated'));
      expect(mockRepo.notes.first.pinned, isTrue);
    });

    test('controller saves pinned state', () async {
      await controller.addOrUpdate(
        title: 'Pinned Note',
        content: Document(),
        pinned: true,
      );

      final saved = mockRepo.notes.first;
      expect(saved.pinned, isTrue);
      expect(saved.title, equals('Pinned Note'));
    });

    test('controller allows title-only notes', () async {
      await controller.addOrUpdate(
        title: 'Title Only',
        content: Document(),
        pinned: false,
      );

      expect(mockRepo.notes.length, equals(1));
      expect(mockRepo.notes.first.title, equals('Title Only'));
    });
  });

  group('NoteDetailPage - Widget Tests', () {
    late MockRepository mockRepo;
    late NotesController controller;

    setUp(() {
      mockRepo = MockRepository();
      controller = NotesController(mockRepo);
    });

    testWidgets('creates note with title', (tester) async {
      await tester.pumpWidget(MaterialApp(
        localizationsDelegates: [FlutterQuillLocalizations.delegate],
        home: NoteDetailPage(controller: controller),
      ));

      await tester.enterText(find.byType(TextField).first, 'New Note');
      await tester.pump();
      await tester.tap(find.byIcon(Icons.save));
      await tester.pumpAndSettle();

      expect(find.byType(NoteDetailPage), findsNothing);
      expect(mockRepo.notes.length, 1);
      expect(mockRepo.notes.first.title, 'New Note');
    });

    testWidgets('discards empty note on back', (tester) async {
      await tester.pumpWidget(MaterialApp(
        localizationsDelegates: [FlutterQuillLocalizations.delegate],
        home: NoteDetailPage(controller: controller),
      ));

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.byType(NoteDetailPage), findsNothing);
      expect(mockRepo.notes.length, 0);
    });

    testWidgets('shows error for empty title save', (tester) async {
      final existingNote = Note(
        id: 'existing',
        title: 'Existing',
        content: '{}',
        pinned: false,
        updatedAt: DateTime.now(),
      );
      mockRepo.notes.add(existingNote);

      await tester.pumpWidget(MaterialApp(
        localizationsDelegates: [FlutterQuillLocalizations.delegate],
        home: NoteDetailPage(existing: existingNote, controller: controller),
      ));

      final titleField = find.byType(TextField).first;
      await tester.enterText(titleField, '');
      await tester.pump();
      await tester.tap(find.byIcon(Icons.save));
      await tester.pump();

      expect(find.text('Note cannot be empty'), findsOneWidget);
      expect(mockRepo.notes.length, 1);
    });

    testWidgets('pin button shows correct state', (tester) async {
      final note = Note(
        id: '1',
        title: '', // keep empty to avoid autoFocus from Quill in tests
        content: '{}',
        pinned: false,
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(MaterialApp(
        localizationsDelegates: [FlutterQuillLocalizations.delegate],
        home: NoteDetailPage(existing: note, controller: controller, showToolbar: false),
      ));

      expect(find.byIcon(Icons.push_pin_outlined), findsOneWidget);
    });

    testWidgets('pin button shows pinned state', (tester) async {
      final note = Note(
        id: '1',
        title: '', // keep empty to avoid autoFocus from Quill in tests
        content: '{}',
        pinned: true,
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(MaterialApp(
        localizationsDelegates: [FlutterQuillLocalizations.delegate],
        home: NoteDetailPage(existing: note, controller: controller, showToolbar: false),
      ));

      expect(find.byIcon(Icons.push_pin), findsOneWidget);
    });
  });
}
