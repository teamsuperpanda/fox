import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fox/models/note.dart';
import 'package:fox/models/folder.dart';
import 'package:fox/services/notes_controller.dart';
import 'package:fox/services/repository.dart';
import 'package:fox/widgets/dialogs.dart';

import 'test_helpers.dart';

class MemoryRepo implements NoteRepository {
  final List<Note> _data = [];
  @override
  Future<void> init() async {}
  @override
  Future<void> clear() async => _data.clear();
  @override
  Future<void> delete(String id) async =>
      _data.removeWhere((e) => e.id == id);
  @override
  Future<List<Note>> getAll() async => List.unmodifiable(_data);
  @override
  Future<Note?> getById(String id) async =>
      _data.cast<Note?>().firstWhere((e) => e?.id == id, orElse: () => null);
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
  group('showDeleteConfirmDialog', () {
    testWidgets('returns true when user taps Delete', (tester) async {
      bool? result;

      await tester.pumpWidget(buildTestApp(
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              result = await showDeleteConfirmDialog(context);
            },
            child: const Text('Open'),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Dialog should be visible
      expect(find.text('Delete Note?'), findsOneWidget);
      expect(find.text('Are you sure you want to delete this note?'), findsOneWidget);

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(result, isTrue);
    });

    testWidgets('returns false when user taps Cancel', (tester) async {
      bool? result;

      await tester.pumpWidget(buildTestApp(
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              result = await showDeleteConfirmDialog(context);
            },
            child: const Text('Open'),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(result, isFalse);
    });
  });

  group('showUndoDeleteSnackBar', () {
    testWidgets('displays snackbar with Undo action', (tester) async {
      final controller = NotesController(MemoryRepo());
      await controller.load();

      await tester.pumpWidget(buildTestApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () => showUndoDeleteSnackBar(context, controller),
              child: const Text('Show Snackbar'),
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Show Snackbar'));
      await tester.pumpAndSettle();

      expect(find.text('Note deleted'), findsOneWidget);
      expect(find.text('Undo'), findsOneWidget);
    });
  });
}
