import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fox/models/note.dart';
import 'package:fox/models/folder.dart';
import 'package:fox/services/notes_controller.dart';
import 'package:fox/services/repository.dart';
import 'package:fox/widgets/folders_dialog.dart';

import 'test_helpers.dart';

class MemoryRepo implements NoteRepository {
  final List<Note> _data = [];
  final List<Folder> _folders = [];

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
  Future<List<Folder>> getAllFolders() async => List.unmodifiable(_folders);
  @override
  Future<void> upsertFolder(Folder folder) async {
    _folders.removeWhere((f) => f.id == folder.id);
    _folders.add(folder);
  }
  @override
  Future<void> deleteFolder(String id) async =>
      _folders.removeWhere((f) => f.id == id);
}

void main() {
  group('FoldersDialog', () {
    late NotesController controller;

    setUp(() async {
      controller = NotesController(MemoryRepo());
      await controller.load();
    });

    testWidgets('shows All Notes and Unfiled options', (tester) async {
      await tester.pumpWidget(buildTestApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => FoldersDialog(controller: controller),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Folders'), findsOneWidget);
      expect(find.text('All Notes'), findsOneWidget);
      expect(find.text('Unfiled'), findsOneWidget);
      expect(find.text('Close'), findsOneWidget);
    });

    testWidgets('can add a folder', (tester) async {
      await tester.pumpWidget(buildTestApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => FoldersDialog(controller: controller),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Type a folder name
      await tester.enterText(find.byType(TextField), 'Work');
      // Tap the add icon
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Folder should appear in the dialog
      expect(find.text('Work'), findsOneWidget);
      // And in the controller
      expect(controller.folders.length, 1);
      expect(controller.folders.first.name, 'Work');
    });

    testWidgets('Close button dismisses dialog', (tester) async {
      await tester.pumpWidget(buildTestApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => FoldersDialog(controller: controller),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Folders'), findsOneWidget);

      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      expect(find.text('Folders'), findsNothing);
    });

    testWidgets('tapping All Notes clears folder filter', (tester) async {
      // Pre-set a folder filter
      await controller.addFolder('TestFolder');
      controller.setSelectedFolder(controller.folders.first.id);
      expect(controller.selectedFolderId, isNotNull);

      await tester.pumpWidget(buildTestApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => FoldersDialog(controller: controller),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('All Notes'));
      await tester.pumpAndSettle();

      expect(controller.selectedFolderId, isNull);
    });

    testWidgets('tapping Unfiled sets unfiled filter', (tester) async {
      await tester.pumpWidget(buildTestApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => FoldersDialog(controller: controller),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Unfiled'));
      await tester.pumpAndSettle();

      expect(controller.selectedFolderId, equals(NotesController.unfiledFolderId));
    });
  });
}
