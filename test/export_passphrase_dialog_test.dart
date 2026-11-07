import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fox/widgets/export_passphrase_dialog.dart';

import 'test_helpers.dart';

void main() {
  Future<String?> openDialog(WidgetTester tester) async {
    String? result;
    await tester.pumpWidget(
      buildTestApp(
        Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async {
                result = await ExportPassphraseDialog.show(context);
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    return result;
  }

  testWidgets('warns that a lost passphrase loses the backup', (tester) async {
    await openDialog(tester);

    expect(find.textContaining('no recovery'), findsOneWidget);
    expect(find.text('Passphrase'), findsOneWidget);
    expect(find.text('Confirm passphrase'), findsOneWidget);
  });

  testWidgets('rejects a short passphrase', (tester) async {
    await openDialog(tester);

    await tester.enterText(find.byType(TextField).at(0), 'short');
    await tester.enterText(find.byType(TextField).at(1), 'short');
    await tester.tap(find.text('Encrypt'));
    await tester.pump();

    expect(find.text('Use at least 8 characters'), findsOneWidget);
    expect(find.byType(ExportPassphraseDialog), findsOneWidget);
  });

  testWidgets('rejects mismatched passphrases', (tester) async {
    await openDialog(tester);

    await tester.enterText(find.byType(TextField).at(0), 'long enough one');
    await tester.enterText(find.byType(TextField).at(1), 'long enough two');
    await tester.tap(find.text('Encrypt'));
    await tester.pump();

    expect(find.text('The passphrases do not match'), findsOneWidget);
  });

  testWidgets('returns the passphrase when it is valid', (tester) async {
    String? result;
    await tester.pumpWidget(
      buildTestApp(
        Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async {
                result = await ExportPassphraseDialog.show(context);
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'my passphrase');
    await tester.enterText(find.byType(TextField).at(1), 'my passphrase');
    await tester.tap(find.text('Encrypt'));
    await tester.pumpAndSettle();

    expect(result, 'my passphrase');
    expect(find.byType(ExportPassphraseDialog), findsNothing);
  });
}
