import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fox/services/feedback_service.dart';

import 'test_helpers.dart';

Widget _trigger(void Function(BuildContext context) action) {
  return buildTestApp(
    Scaffold(
      body: Builder(
        builder: (context) => ElevatedButton(
          onPressed: () => action(context),
          child: const Text('Go'),
        ),
      ),
    ),
  );
}

void main() {
  group('FeedbackService', () {
    testWidgets('success shows the message', (tester) async {
      await tester.pumpWidget(
        _trigger((context) {
          const FeedbackService().success(context, 'Saved');
        }),
      );

      await tester.tap(find.text('Go'));
      await tester.pumpAndSettle();

      expect(find.text('Saved'), findsOneWidget);
    });

    testWidgets('error shows the message and offers retry', (tester) async {
      var retried = 0;
      await tester.pumpWidget(
        _trigger((context) {
          const FeedbackService().error(
            context,
            'Save failed',
            retryLabel: 'Retry',
            onRetry: () => retried++,
          );
        }),
      );

      await tester.tap(find.text('Go'));
      await tester.pumpAndSettle();

      expect(find.text('Save failed'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      expect(retried, 1);
    });

    testWidgets('error without a retry callback has no action', (tester) async {
      await tester.pumpWidget(
        _trigger((context) {
          const FeedbackService().error(context, 'Save failed');
        }),
      );

      await tester.tap(find.text('Go'));
      await tester.pumpAndSettle();

      expect(find.text('Save failed'), findsOneWidget);
      expect(find.text('Retry'), findsNothing);
    });

    testWidgets('undo action runs and hides the snackbar', (tester) async {
      var undone = false;
      await tester.pumpWidget(
        _trigger((context) {
          const FeedbackService().undo(
            context,
            message: 'Deleted',
            actionLabel: 'Undo',
            onUndo: () async {
              undone = true;
              return true;
            },
          );
        }),
      );

      await tester.tap(find.text('Go'));
      await tester.pumpAndSettle();

      expect(find.text('Deleted'), findsOneWidget);
      expect(find.text('Undo'), findsOneWidget);

      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();

      expect(undone, isTrue);
      expect(find.text('Deleted'), findsNothing);
      expect(find.text('Undo'), findsNothing);
    });

    testWidgets('expired undo hides the snackbar without restoring',
        (tester) async {
      var undoRan = false;
      await tester.pumpWidget(
        _trigger((context) {
          const FeedbackService().undo(
            context,
            message: 'Deleted',
            actionLabel: 'Undo',
            onUndo: () async {
              undoRan = true;
              return false;
            },
          );
        }),
      );

      await tester.tap(find.text('Go'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();

      expect(undoRan, isTrue);
      expect(find.text('Deleted'), findsNothing);
    });
  });
}
