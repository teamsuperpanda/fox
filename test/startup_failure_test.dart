import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fox/providers/locale_provider.dart';
import 'package:fox/providers/theme_provider.dart';
import 'package:fox/services/notes_controller.dart';
import 'package:fox/services/settings_service.dart';
import 'package:fox/startup.dart';
import 'package:fox/widgets/startup_failure_screen.dart';

import 'test_helpers.dart';

void main() {
  group('StartupFailureScreen', () {
    testWidgets('renders the error and a Retry button', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          StartupFailureScreen(error: 'box is locked', onRetry: () {}),
        ),
      );

      expect(find.textContaining('box is locked'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('Retry invokes the callback', (tester) async {
      var retries = 0;
      await tester.pumpWidget(
        buildTestApp(
          StartupFailureScreen(error: 'boom', onRetry: () => retries++),
        ),
      );

      await tester.tap(find.text('Retry'));
      await tester.pump();

      expect(retries, 1);
    });
  });

  group('FoxRoot failure path', () {
    testWidgets('a failing startup renders the failure screen', (tester) async {
      await tester.pumpWidget(
        FoxRoot(
          startup: () async => throw StateError('notes box corrupt'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(StartupFailureScreen), findsOneWidget);
      expect(find.textContaining('notes box corrupt'), findsOneWidget);
    });

    testWidgets('Retry recovers when the cause is fixed', (tester) async {
      var attempts = 0;
      final repository = MemoryRepo();
      await repository.init();
      await tester.pumpWidget(
        FoxRoot(
          startup: () async {
            attempts++;
            if (attempts == 1) throw StateError('transient failure');
            final controller = NotesController(repository);
            await controller.load();
            return StartupBundle(
              notesController: controller,
              settingsService: SettingsService(),
              themeProvider: ThemeProvider(),
              localeProvider: LocaleProvider(),
            );
          },
          appBuilder: (_) => const MaterialApp(
            home: Scaffold(body: Text('recovered')),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('transient failure'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      expect(attempts, 2);
      expect(find.text('recovered'), findsOneWidget);
      expect(find.byType(StartupFailureScreen), findsNothing);
    });
  });
}
