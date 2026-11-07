import 'package:flutter_test/flutter_test.dart';
import 'package:fox/services/notes_controller.dart';
import 'package:fox/trash_page.dart';

import 'test_helpers.dart';

void main() {
  group('TrashPage', () {
    late MemoryRepo repo;
    late NotesController controller;

    setUp(() async {
      repo = MemoryRepo();
      controller = NotesController(repo);
    });

    testWidgets('lists a trashed note and restores it', (tester) async {
      await repo.upsert(
        makeNote(
          id: 'trashed',
          title: 'Old note',
          deletedAt: DateTime.now(),
        ),
      );
      await controller.load();

      await tester.pumpWidget(buildTestApp(TrashPage(controller: controller)));

      expect(find.text('Old note'), findsOneWidget);

      await tester.tap(find.byTooltip('Restore'));
      await tester.pumpAndSettle();

      expect(find.text('Old note'), findsNothing);
      expect(find.text('The trash is empty.'), findsOneWidget);
      expect(controller.find('trashed')?.deletedAt, isNull);
    });

    testWidgets('empty state is shown when there is nothing to restore',
        (tester) async {
      await controller.load();

      await tester.pumpWidget(buildTestApp(TrashPage(controller: controller)));

      expect(find.text('The trash is empty.'), findsOneWidget);
      expect(find.byTooltip('Empty trash'), findsOneWidget);
    });
  });
}
