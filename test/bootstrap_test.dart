import 'package:flutter_test/flutter_test.dart';
import 'package:fox/bootstrap.dart';
import 'package:fox/home_page.dart';
import 'package:fox/services/notes_controller.dart';
import 'package:fox/services/settings_service.dart';

import 'test_helpers.dart';

void main() {
  group('bootstrap', () {
    test('builds the scope from injected storage and repository', () async {
      var inited = false;

      final scope = await bootstrap(
        initStorage: () async => inited = true,
        createRepository: MockRepository.new,
        createSettingsService: SettingsService.new,
      );

      expect(inited, isTrue);
      expect(scope.notesController, isA<NotesController>());
      expect(scope.settingsService, isA<SettingsService>());
    });

    testWidgets('startup failure shows a translated error with retry',
        (tester) async {
      var attempts = 0;
      Future<void> initStorage() async {
        attempts++;
        if (attempts == 1) throw StateError('storage failed');
      }

      await tester.pumpWidget(
        FoxApp(
          initStorage: initStorage,
          createRepository: MockRepository.new,
          createSettingsService: SettingsService.new,
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Something went wrong starting Fox'),
        findsOneWidget,
      );
      expect(find.text('Retry'), findsOneWidget);
      expect(attempts, 1);
      expect(find.byType(HomePage), findsNothing);
    });

    testWidgets('retry starts the app without restarting the process',
        (tester) async {
      var attempts = 0;
      Future<void> initStorage() async {
        attempts++;
        if (attempts == 1) throw StateError('storage failed');
      }

      await tester.pumpWidget(
        FoxApp(
          initStorage: initStorage,
          createRepository: MockRepository.new,
          createSettingsService: SettingsService.new,
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Retry'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(attempts, 2);
      expect(find.byType(HomePage), findsOneWidget);
      expect(find.text('Retry'), findsNothing);
    });
  });
}
