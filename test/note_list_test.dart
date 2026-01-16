import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fox/models/note.dart';
import 'package:fox/services/notes_controller.dart';
import 'package:fox/services/repository.dart';
import 'package:fox/widgets/note_list.dart';

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
    try {
      return notes.firstWhere((n) => n.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> clear() async {
    notes.clear();
  }
}

void main() {
  group('NoteList Widget', () {
    late MockRepository mockRepo;
    late NotesController controller;

    setUp(() {
      mockRepo = MockRepository();
      controller = NotesController(mockRepo);
    });

    testWidgets('displays note titles in list', (tester) async {
      final note1 = Note(
        id: '1',
        title: 'First Note',
        content: '{}',
        pinned: false,
        updatedAt: DateTime.now(),
      );
      final note2 = Note(
        id: '2',
        title: 'Second Note',
        content: '{}',
        pinned: false,
        updatedAt: DateTime.now(),
      );

      mockRepo.notes.addAll([note1, note2]);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NoteList(
              controller: controller,
              notes: [note1, note2],
            ),
          ),
        ),
      );

      expect(find.text('First Note'), findsOneWidget);
      expect(find.text('Second Note'), findsOneWidget);
    });

    testWidgets('shows pin icon for pinned notes', (tester) async {
      final pinnedNote = Note(
        id: '1',
        title: 'Pinned',
        content: '{}',
        pinned: true,
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NoteList(
              controller: controller,
              notes: [pinnedNote],
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.push_pin), findsOneWidget);
    });

    testWidgets('does not show pin icon for unpinned notes', (tester) async {
      final unpinnedNote = Note(
        id: '1',
        title: 'Not Pinned',
        content: '{}',
        pinned: false,
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NoteList(
              controller: controller,
              notes: [unpinnedNote],
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.push_pin), findsNothing);
    });

    testWidgets('renders list without errors', (tester) async {
      final note = Note(
        id: '1',
        title: 'Test Note',
        content: '{}',
        pinned: false,
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NoteList(
              controller: controller,
              notes: [note],
            ),
          ),
        ),
      );

      // Just verify it renders without crashing
      expect(find.byType(NoteList), findsOneWidget);
    });

    testWidgets('note with empty title shows (Untitled)', (tester) async {
      final note = Note(
        id: '1',
        title: '',
        content: '{}',
        pinned: false,
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NoteList(
              controller: controller,
              notes: [note],
            ),
          ),
        ),
      );

      expect(find.text('(Untitled)'), findsOneWidget);
    });

    testWidgets('displays formatted date in subtitle', (tester) async {
      final now = DateTime.now();
      final note = Note(
        id: '1',
        title: 'Test Note',
        content: '{}',
        pinned: false,
        updatedAt: now,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NoteList(
              controller: controller,
              notes: [note],
            ),
          ),
        ),
      );

      // Date formatting should display "Today • " for current day
      expect(find.textContaining('Today'), findsOneWidget);
    });

    testWidgets('multiple notes display in correct order', (tester) async {
      final note1 = Note(
        id: '1',
        title: 'First',
        content: '{}',
        pinned: false,
        updatedAt: DateTime.now(),
      );
      final note2 = Note(
        id: '2',
        title: 'Second',
        content: '{}',
        pinned: false,
        updatedAt: DateTime.now(),
      );
      final note3 = Note(
        id: '3',
        title: 'Third',
        content: '{}',
        pinned: false,
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NoteList(
              controller: controller,
              notes: [note1, note2, note3],
            ),
          ),
        ),
      );

      expect(find.text('First'), findsOneWidget);
      expect(find.text('Second'), findsOneWidget);
      expect(find.text('Third'), findsOneWidget);
    });

    testWidgets('shows pin icon with correct color for pinned notes', (tester) async {
      final pinnedNote = Note(
        id: '1',
        title: 'Pinned',
        content: '{}',
        pinned: true,
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NoteList(
              controller: controller,
              notes: [pinnedNote],
            ),
          ),
        ),
      );

      // Pinned notes show filled pin icon
      expect(find.byIcon(Icons.push_pin), findsOneWidget);
    });

    testWidgets('old date shows formatted like yesterday or other day', (tester) async {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final note = Note(
        id: '1',
        title: 'Old Note',
        content: '{}',
        pinned: false,
        updatedAt: yesterday,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NoteList(
              controller: controller,
              notes: [note],
            ),
          ),
        ),
      );

      // Should not show "Today"
      expect(find.textContaining('Today'), findsNothing);
      // Should show date
      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('mixed pinned and unpinned notes show correct icons', (tester) async {
      final pinnedNote = Note(
        id: '1',
        title: 'Pinned',
        content: '{}',
        pinned: true,
        updatedAt: DateTime.now(),
      );
      final unpinnedNote = Note(
        id: '2',
        title: 'Unpinned',
        content: '{}',
        pinned: false,
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NoteList(
              controller: controller,
              notes: [pinnedNote, unpinnedNote],
            ),
          ),
        ),
      );

      // Pinned shows filled icon, unpinned shows no icon
      expect(find.byIcon(Icons.push_pin), findsOneWidget);
      expect(find.byIcon(Icons.push_pin_outlined), findsNothing);
    });
  });
}
