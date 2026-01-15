import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:fox/models/note_adapter.dart';
import 'package:fox/services/repository_hive.dart';
import 'package:fox/models/note.dart';

void main() {
  group('HiveNoteRepository', () {
    late HiveNoteRepository repository;

    setUpAll(() async {
      // Initialize Hive for testing
      Hive.init('./test/hive_notes_test');
      if (!Hive.isAdapterRegistered(3)) {
        Hive.registerAdapter(NoteAdapter());
      }
    });

    setUp(() async {
      // Open the notes box
      await Hive.openBox<Note>('notes_db');
      repository = await HiveNoteRepository.create();
      
      // Clear any existing data
      await repository.clear();
    });

    tearDown(() async {
      // Close the box after each test
      if (Hive.isBoxOpen('notes_db')) {
        final box = Hive.box<Note>('notes_db');
        await box.close();
      }
    });

    tearDownAll(() async {
      // Clean up Hive after all tests
      await Hive.deleteFromDisk();
    });

    test('creates and retrieves a note', () async {
      final note = Note(
        id: 'test-1',
        title: 'Test Note',
        content: 'This is a test note',
        pinned: false,
        updatedAt: DateTime.now(),
      );

      await repository.upsert(note);
      final retrieved = await repository.getById('test-1');

      expect(retrieved, isNotNull);
      expect(retrieved!.id, equals('test-1'));
      expect(retrieved.title, equals('Test Note'));
      expect(retrieved.content, equals('This is a test note'));
      expect(retrieved.pinned, isFalse);
    });

    test('updates an existing note', () async {
      final note = Note(
        id: 'test-1',
        title: 'Original Title',
        content: 'Original content',
        pinned: false,
        updatedAt: DateTime.now(),
      );

      await repository.upsert(note);

      final updatedNote = note.copyWith(
        title: 'Updated Title',
        content: 'Updated content',
        pinned: true,
      );

      await repository.upsert(updatedNote);
      final retrieved = await repository.getById('test-1');

      expect(retrieved!.title, equals('Updated Title'));
      expect(retrieved.content, equals('Updated content'));
      expect(retrieved.pinned, isTrue);
    });

    test('deletes a note', () async {
      final note = Note(
        id: 'test-1',
        title: 'Test Note',
        content: 'This note will be deleted',
        pinned: false,
        updatedAt: DateTime.now(),
      );

      await repository.upsert(note);
      expect(await repository.getById('test-1'), isNotNull);

      await repository.delete('test-1');
      expect(await repository.getById('test-1'), isNull);
    });

    test('returns all notes', () async {
      final now = DateTime.now();
      
      final notes = [
        Note(
          id: 'note-1',
          title: 'Unpinned Old',
          content: 'Content 1',
          pinned: false,
          updatedAt: now.subtract(Duration(hours: 2)),
        ),
        Note(
          id: 'note-2',
          title: 'Pinned New',
          content: 'Content 2',
          pinned: true,
          updatedAt: now.subtract(Duration(hours: 1)),
        ),
        Note(
          id: 'note-3',
          title: 'Unpinned New',
          content: 'Content 3',
          pinned: false,
          updatedAt: now,
        ),
        Note(
          id: 'note-4',
          title: 'Pinned Old',
          content: 'Content 4',
          pinned: true,
          updatedAt: now.subtract(Duration(hours: 3)),
        ),
      ];

      for (final note in notes) {
        await repository.upsert(note);
      }

      final retrieved = await repository.getAll();

      // Repository no longer responsible for sorting. verify all present.
      expect(retrieved.length, equals(4));
      
      final ids = retrieved.map((n) => n.id).toSet();
      expect(ids.contains('note-1'), isTrue);
      expect(ids.contains('note-2'), isTrue);
      expect(ids.contains('note-3'), isTrue);
      expect(ids.contains('note-4'), isTrue);
    });

    test('clears all notes', () async {
      final notes = [
        Note(
          id: 'note-1',
          title: 'Note 1',
          content: 'Content 1',
          pinned: false,
          updatedAt: DateTime.now(),
        ),
        Note(
          id: 'note-2',
          title: 'Note 2',
          content: 'Content 2',
          pinned: true,
          updatedAt: DateTime.now(),
        ),
      ];

      for (final note in notes) {
        await repository.upsert(note);
      }

      expect((await repository.getAll()).length, equals(2));

      await repository.clear();
      expect((await repository.getAll()).length, equals(0));
    });

    test('handles empty repository', () async {
      final notes = await repository.getAll();
      expect(notes, isEmpty);

      final note = await repository.getById('non-existent');
      expect(note, isNull);
    });
  });
}
