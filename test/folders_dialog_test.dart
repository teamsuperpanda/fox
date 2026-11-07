import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fox/services/constants.dart';
import 'package:fox/services/notes_controller.dart';
import 'package:fox/widgets/folders_dialog.dart';

import 'test_helpers.dart';

void main() {
  group('FoldersDialog', () {
    late NotesController controller;

    setUp(() async {
      controller = NotesController(MemoryRepo());
      await controller.load();
    });

    testWidgets('shows All Notes and Unfiled options', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          Scaffold(
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
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Folders'), findsOneWidget);
      expect(find.text('All Notes'), findsOneWidget);
      expect(find.text('Unfiled'), findsOneWidget);
      expect(find.text('Close'), findsOneWidget);
    });

    testWidgets('can add a folder', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          Scaffold(
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
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Work');
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      expect(find.text('Work'), findsOneWidget);
      expect(controller.folders.length, 1);
      expect(controller.folders.first.name, 'Work');
    });

    testWidgets('Close button dismisses dialog', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          Scaffold(
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
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Folders'), findsOneWidget);

      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      expect(find.text('Folders'), findsNothing);
    });

    testWidgets('tapping All Notes clears folder filter', (tester) async {
      await controller.addFolder('TestFolder');
      controller.setSelectedFolder(controller.folders.first.id);
      expect(controller.selectedFolderId, isNotNull);

      await tester.pumpWidget(
        buildTestApp(
          Scaffold(
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
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('All Notes'));
      await tester.pumpAndSettle();

      expect(controller.selectedFolderId, isNull);
    });

    testWidgets('tapping Unfiled sets unfiled filter', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          Scaffold(
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
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Unfiled'));
      await tester.pumpAndSettle();

      expect(controller.selectedFolderId, equals(AppConstants.unfiledFolderId));
    });

    testWidgets('setFolderAppearance stores an icon and colour',
        (tester) async {
      await controller.addFolder('Work');
      final folder = controller.folders.single;

      await tester.pumpWidget(
        buildTestApp(
          Scaffold(
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
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_vert).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Appearance'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.work_outline));
      await tester.pump();
      await tester.tap(find.byTooltip('#AB47BC'));
      await tester.pump();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      final updated = controller.findFolder(folder.id)!;
      expect(updated.icon, 'work');
      expect(updated.color, '#AB47BC');
      expect(find.byIcon(Icons.work_outline), findsOneWidget);
    });

    testWidgets('appearance dialog can clear an icon and colour',
        (tester) async {
      await controller.addFolder('Decorated', icon: 'work', color: '#AB47BC');
      final folder = controller.folders.single;

      await tester.pumpWidget(
        buildTestApp(
          Scaffold(
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
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_vert).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Appearance'));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('No icon'));
      await tester.pump();
      await tester.tap(find.byTooltip('No colour'));
      await tester.pump();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      final updated = controller.findFolder(folder.id)!;
      expect(updated.icon, isNull);
      expect(updated.color, isNull);
    });
  });
}
