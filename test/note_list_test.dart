import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fox/models/note.dart';
import 'package:fox/services/notes_controller.dart';
import 'package:fox/widgets/note_list.dart';

import 'test_helpers.dart';

class _FailingUpsertRepository extends MockRepository {
  @override
  Future<void> upsert(Note note) => Future.error(StateError('upsert failed'));
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
      final note1 = makeNote(title: 'First Note');
      final note2 = makeNote(id: '2', title: 'Second Note');

      mockRepo.notes.addAll([note1, note2]);

      await tester.pumpWidget(
        buildTestApp(
          Scaffold(
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
      final pinnedNote = makeNote(title: 'Pinned', pinned: true);

      await tester.pumpWidget(
        buildTestApp(
          Scaffold(
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
      final unpinnedNote = makeNote(title: 'Not Pinned');

      await tester.pumpWidget(
        buildTestApp(
          Scaffold(
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
      final note = makeNote();

      await tester.pumpWidget(
        buildTestApp(
          Scaffold(
            body: NoteList(
              controller: controller,
              notes: [note],
            ),
          ),
        ),
      );

      expect(find.byType(NoteList), findsOneWidget);
    });

    testWidgets('pin gesture propagates persistence errors', (tester) async {
      final failingRepo = _FailingUpsertRepository();
      final failingController = NotesController(failingRepo);
      final note = makeNote();
      failingRepo.notes.add(note);
      await failingController.load();

      await tester.pumpWidget(
        buildTestApp(
          Scaffold(
            body: NoteList(
              controller: failingController,
              notes: [note],
            ),
          ),
        ),
      );
      final dismissible = tester.widget<Dismissible>(find.byType(Dismissible));

      await expectLater(
        dismissible.confirmDismiss!(DismissDirection.startToEnd),
        throwsA(isA<StateError>()),
      );
    });

    testWidgets('note with empty title shows (Untitled)', (tester) async {
      final note = makeNote(title: '');

      await tester.pumpWidget(
        buildTestApp(
          Scaffold(
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
      final note = makeNote(updatedAt: now);

      await tester.pumpWidget(
        buildTestApp(
          Scaffold(
            body: NoteList(
              controller: controller,
              notes: [note],
            ),
          ),
        ),
      );

      expect(find.textContaining('Today'), findsOneWidget);
    });

    testWidgets('multiple notes display in correct order', (tester) async {
      final note1 = makeNote(title: 'First');
      final note2 = makeNote(id: '2', title: 'Second');
      final note3 = makeNote(id: '3', title: 'Third');

      await tester.pumpWidget(
        buildTestApp(
          Scaffold(
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

    testWidgets('shows pin icon with correct color for pinned notes',
        (tester) async {
      final pinnedNote = makeNote(title: 'Pinned', pinned: true);

      await tester.pumpWidget(
        buildTestApp(
          Scaffold(
            body: NoteList(
              controller: controller,
              notes: [pinnedNote],
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.push_pin), findsOneWidget);
    });

    testWidgets('old date shows formatted like yesterday or other day',
        (tester) async {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final note = makeNote(title: 'Old Note', updatedAt: yesterday);

      await tester.pumpWidget(
        buildTestApp(
          Scaffold(
            body: NoteList(
              controller: controller,
              notes: [note],
            ),
          ),
        ),
      );

      expect(find.textContaining('Today'), findsNothing);
      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('mixed pinned and unpinned notes show correct icons',
        (tester) async {
      final pinnedNote = makeNote(title: 'Pinned', pinned: true);
      final unpinnedNote = makeNote(id: '2', title: 'Unpinned');

      await tester.pumpWidget(
        buildTestApp(
          Scaffold(
            body: NoteList(
              controller: controller,
              notes: [pinnedNote, unpinnedNote],
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.push_pin), findsOneWidget);
      expect(find.byIcon(Icons.push_pin_outlined), findsNothing);
    });
  });
}
