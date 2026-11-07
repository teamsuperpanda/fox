import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fox/models/note.dart';
import 'package:fox/services/notes_controller.dart';
import 'package:fox/widgets/folder_drop_bar.dart';

import 'test_helpers.dart';

void main() {
  group('FolderDropBar', () {
    late MemoryRepo repo;
    late NotesController controller;
    late List<String?> moves;

    setUp(() async {
      moves = <String?>[];
      repo = MemoryRepo();
      controller = NotesController(repo);
      await controller.load();
      await controller.addFolder('Work');
      await controller.addFolder('Recipes',
          parentId: controller.folders.single.id);
    });

    Widget subject() {
      final note = makeNote(id: 'note-1', title: 'Drag me');
      return buildTestApp(
        Scaffold(
          body: Column(
            children: [
              FolderDropBar(
                controller: controller,
                onMove: (Note note, String? folderId) async {
                  moves.add(folderId);
                },
              ),
              LongPressDraggable<Note>(
                data: note,
                feedback: const Material(child: Text('Drag me')),
                child: const Text('Drag me'),
              ),
            ],
          ),
        ),
      );
    }

    testWidgets('shows a chip per folder with a breadcrumb for children',
        (tester) async {
      await tester.pumpWidget(subject());

      expect(find.text('Unfiled'), findsOneWidget);
      expect(find.text('Work'), findsOneWidget);
      expect(find.text('Work / Recipes'), findsOneWidget);
    });

    testWidgets('long-press dragging a note onto a chip files it',
        (tester) async {
      await tester.pumpWidget(subject());

      final gesture =
          await tester.startGesture(tester.getCenter(find.text('Drag me')));
      await tester.pump(kLongPressTimeout + const Duration(milliseconds: 100));
      await gesture.moveTo(tester.getCenter(find.text('Work / Recipes')));
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();

      expect(moves,
          [controller.childFolders(controller.folders.first.id).single.id]);
    });
  });
}
