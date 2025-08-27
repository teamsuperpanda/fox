import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:fox/models/note_adapter.dart';
import 'package:fox/services/repository.dart';
import 'package:fox/services/repository_hive.dart';

// Helper function to simulate migration
Future<void> migrateNotes(
  NoteRepository oldRepo,
  NoteRepository newRepo,
  Box<bool> migrationBox,
) async {
  // Check if migration already completed
  if (migrationBox.get('notes_migrated') == true) return;

  try {
    // Get all existing notes from old repository
    final existingNotes = await oldRepo.getAll();
    
    // Migrate each note to new repository
    for (final note in existingNotes) {
      await newRepo.upsert(note);
    }
    
    // Mark migration as completed
    await migrationBox.put('notes_migrated', true);
  } catch (e) {
    // In tests, we can use print for debugging
    // ignore: avoid_print
    print('Error during notes migration: $e');
    rethrow;
  }
}

// Mock repository to simulate old data
class MockOldRepository implements NoteRepository {
  final List<Note> _notes = [];

  @override
  Future<void> init() async {
    // Mock implementation - no initialization needed
  }

  @override
  Future<List<Note>> getAll() async => List.from(_notes);

  @override
  Future<Note?> getById(String id) async {
    try {
      return _notes.firstWhere((note) => note.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> upsert(Note note) async {
    final index = _notes.indexWhere((n) => n.id == note.id);
    if (index >= 0) {
      _notes[index] = note;
    } else {
      _notes.add(note);
    }
  }

  @override
  Future<void> delete(String id) async {
    _notes.removeWhere((note) => note.id == id);
  }

  @override
  Future<void> clear() async {
    _notes.clear();
  }

  // Add some test data
  void addTestData() {
    _notes.addAll([
      Note(
        id: 'old-1',
        title: 'Old Note 1',
        content: 'This is from the old system',
        pinned: false,
        updatedAt: DateTime.now().subtract(Duration(days: 1)),
      ),
      Note(
        id: 'old-2',
        title: 'Important Old Note',
        content: 'This was pinned in the old system',
        pinned: true,
        updatedAt: DateTime.now().subtract(Duration(hours: 12)),
      ),
    ]);
  }
}

void main() {
  group('Notes Migration', () {
    late Box<bool> migrationBox;

    setUpAll(() async {
      // Initialize Hive for testing
      Hive.init('./test/hive_migration_test');
      if (!Hive.isAdapterRegistered(3)) {
        Hive.registerAdapter(NoteAdapter());
      }
    });

    setUp(() async {
      // Open migration flags box
      migrationBox = await Hive.openBox<bool>('migration_flags');
      await migrationBox.clear();
      
      // Open and clear notes box
      final notesBox = await Hive.openBox<Note>('notes_db');
      await notesBox.clear();
    });

    tearDown(() async {
      if (Hive.isBoxOpen('migration_flags')) {
        await migrationBox.close();
      }
      if (Hive.isBoxOpen('notes_db')) {
        final notesBox = Hive.box<Note>('notes_db');
        await notesBox.close();
      }
    });

    tearDownAll(() async {
      await Hive.deleteFromDisk();
    });

    test('migrates notes from old repository to Hive', () async {
      // Set up old repository with test data
      final oldRepo = MockOldRepository();
      oldRepo.addTestData();
      
      // Verify old data exists
      final oldNotes = await oldRepo.getAll();
      expect(oldNotes.length, equals(2));

      // Create new Hive repository
      final newRepo = await HiveNoteRepository.create();
      
      // Verify new repository is empty
      final newNotesEmpty = await newRepo.getAll();
      expect(newNotesEmpty.length, equals(0));

      // Run migration
      await migrateNotes(oldRepo, newRepo, migrationBox);

      // Verify migration completed
      expect(migrationBox.get('notes_migrated'), isTrue);

      // Verify data was migrated
      final migratedNotes = await newRepo.getAll();
      expect(migratedNotes.length, equals(2));

      // Verify specific notes were migrated correctly
      final note1 = migratedNotes.firstWhere((n) => n.id == 'old-1');
      expect(note1.title, equals('Old Note 1'));
      expect(note1.content, equals('This is from the old system'));
      expect(note1.pinned, isFalse);

      final note2 = migratedNotes.firstWhere((n) => n.id == 'old-2');
      expect(note2.title, equals('Important Old Note'));
      expect(note2.content, equals('This was pinned in the old system'));
      expect(note2.pinned, isTrue);
    });

    test('skips migration if already completed', () async {
      // Mark migration as already completed
      await migrationBox.put('notes_migrated', true);

      // Set up repositories
      final oldRepo = MockOldRepository();
      oldRepo.addTestData();
      final newRepo = await HiveNoteRepository.create();

      // Run migration
      await migrateNotes(oldRepo, newRepo, migrationBox);

      // Verify no data was migrated (since it was already marked complete)
      final migratedNotes = await newRepo.getAll();
      expect(migratedNotes.length, equals(0));
    });

    test('handles empty old repository', () async {
      // Set up empty old repository
      final oldRepo = MockOldRepository();
      final newRepo = await HiveNoteRepository.create();

      // Run migration
      await migrateNotes(oldRepo, newRepo, migrationBox);

      // Verify migration completed without errors
      expect(migrationBox.get('notes_migrated'), isTrue);
      
      // Verify new repository is still empty
      final migratedNotes = await newRepo.getAll();
      expect(migratedNotes.length, equals(0));
    });

    test('handles existing data in new repository', () async {
      // Set up old repository with test data
      final oldRepo = MockOldRepository();
      oldRepo.addTestData();

      // Set up new repository with some existing data
      final newRepo = await HiveNoteRepository.create();
      await newRepo.upsert(Note(
        id: 'existing-1',
        title: 'Existing Note',
        content: 'This was already in Hive',
        pinned: false,
        updatedAt: DateTime.now(),
      ));

      // Verify initial state
      final initialNotes = await newRepo.getAll();
      expect(initialNotes.length, equals(1));

      // Run migration
      await migrateNotes(oldRepo, newRepo, migrationBox);

      // Verify all notes are present (existing + migrated)
      final allNotes = await newRepo.getAll();
      expect(allNotes.length, equals(3));

      // Verify existing note is still there
      final existingNote = allNotes.firstWhere((n) => n.id == 'existing-1');
      expect(existingNote.title, equals('Existing Note'));

      // Verify migrated notes are there
      final migratedNote1 = allNotes.firstWhere((n) => n.id == 'old-1');
      expect(migratedNote1.title, equals('Old Note 1'));

      final migratedNote2 = allNotes.firstWhere((n) => n.id == 'old-2');
      expect(migratedNote2.title, equals('Important Old Note'));
    });
  });
}
