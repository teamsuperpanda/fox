import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fox/widgets/startup_failure_screen.dart';

import 'test_helpers.dart';

void main() {
  group('StartupFailureScreen', () {
    testWidgets('offers retry and calls it', (tester) async {
      var retries = 0;
      await tester.pumpWidget(
        buildTestApp(
          StartupFailureScreen(
            error: 'migration failed',
            onRetry: () async => retries++,
          ),
        ),
      );

      expect(find.textContaining('migration failed'), findsOneWidget);
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      expect(retries, 1);
    });

    testWidgets('copies a JSON backup to the clipboard', (tester) async {
      final calls = <MethodCall>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          calls.add(call);
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );

      await tester.pumpWidget(
        buildTestApp(
          StartupFailureScreen(
            error: 'migration failed',
            onRetry: () async {},
          ),
        ),
      );

      await tester.tap(find.text('Copy backup to clipboard'));
      await tester.pumpAndSettle();

      final clipboardCall =
          calls.where((call) => call.method == 'Clipboard.setData');
      expect(clipboardCall, isNotEmpty);
      expect(
        find.text('Backup copied to the clipboard'),
        findsOneWidget,
      );
    });
  });
}
