import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fox/l10n/app_localizations.dart';
import 'package:fox/services/notes_controller.dart';
import 'package:fox/widgets/dialogs.dart';

import 'test_helpers.dart';

void main() {
  group('showDeleteConfirmDialog', () {
    testWidgets('returns true when user taps Delete', (tester) async {
      bool? result;

      await tester.pumpWidget(
        buildTestApp(
          Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await showDeleteConfirmDialog(context);
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Delete Note?'), findsOneWidget);
      expect(find.text('Are you sure you want to delete this note?'),
          findsOneWidget);

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(result, isTrue);
    });

    testWidgets('returns false when user taps Cancel', (tester) async {
      bool? result;

      await tester.pumpWidget(
        buildTestApp(
          Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await showDeleteConfirmDialog(context);
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );
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

      await tester.pumpWidget(
        buildTestApp(
          Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () => showUndoDeleteSnackBar(context, controller),
                child: const Text('Show Snackbar'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final l10n = AppLocalizations.of(
        tester.element(find.byType(Scaffold)),
      );

      await tester.tap(find.text('Show Snackbar'));
      await tester.pumpAndSettle();

      expect(find.text(l10n.noteDeleted), findsOneWidget);
      expect(find.text('Undo'), findsOneWidget);
    });
  });
}
