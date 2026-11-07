import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fox/main.dart' as app;
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // One test, end to end: the app owns a real Hive database, so the scenario
  // cleans up after itself instead of leaking state into later runs.
  testWidgets('create, save, reopen, pin, delete and undo a note',
      (tester) async {
    const title = 'Integration note';

    app.main();
    await tester.pumpAndSettle();

    expect(find.text('Fox'), findsWidgets);

    // Create.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, title);
    await tester.pump();

    await tester.tap(find.byIcon(Icons.save));
    await tester.pumpAndSettle();

    expect(find.text(title), findsOneWidget);

    // Reopen and pin.
    await tester.tap(find.text(title));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.push_pin_outlined), findsOneWidget);
    await tester.tap(find.byIcon(Icons.push_pin_outlined));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.push_pin), findsOneWidget);

    await tester.tap(find.byIcon(Icons.save));
    await tester.pumpAndSettle();

    // Delete.
    await tester.tap(find.text(title));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.delete));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(find.text(title), findsNothing);
    expect(find.text('Note deleted'), findsOneWidget);

    // Undo restores the note.
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();

    expect(find.text(title), findsOneWidget);

    // Delete again so the device database is left empty for the next run.
    await tester.tap(find.text(title));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.delete));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(find.text(title), findsNothing);
  });
}
