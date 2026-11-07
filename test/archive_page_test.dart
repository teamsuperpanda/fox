import 'package:flutter_test/flutter_test.dart';
import 'package:fox/archive_page.dart';
import 'package:fox/services/notes_controller.dart';

import 'test_helpers.dart';

void main() {
  group('ArchivePage', () {
    late MemoryRepo repo;
    late NotesController controller;

    setUp(() async {
      repo = MemoryRepo();
      controller = NotesController(repo);
    });

    testWidgets('lists an archived note and restores it', (tester) async {
      await repo.upsert(
        makeNote(
          id: 'archived',
          title: 'Reference',
          archivedAt: DateTime.now(),
        ),
      );
      await controller.load();

      await tester
          .pumpWidget(buildTestApp(ArchivePage(controller: controller)));

      expect(find.text('Reference'), findsOneWidget);

      await tester.tap(find.byTooltip('Restore'));
      await tester.pumpAndSettle();

      expect(find.text('Reference'), findsNothing);
      expect(find.text('Nothing is archived.'), findsOneWidget);
      expect(controller.find('archived')?.archivedAt, isNull);
    });

    testWidgets('empty state is shown when nothing is archived',
        (tester) async {
      await controller.load();

      await tester
          .pumpWidget(buildTestApp(ArchivePage(controller: controller)));

      expect(find.text('Nothing is archived.'), findsOneWidget);
    });
  });
}
