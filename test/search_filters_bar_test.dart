import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fox/models/search_filters.dart';
import 'package:fox/services/notes_controller.dart';
import 'package:fox/widgets/search_filters_bar.dart';

import 'test_helpers.dart';

void main() {
  group('SearchFiltersBar', () {
    late MockRepository repo;
    late NotesController controller;

    setUp(() async {
      repo = MockRepository();
      controller = NotesController(repo);
      await controller.load();
    });

    Future<void> pumpBar(WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestApp(
          Scaffold(body: SearchFiltersBar(controller: controller)),
        ),
      );
      await tester.pump();
    }

    testWidgets('shows the result count and filter chips', (tester) async {
      await controller.addOrUpdate(title: 'One', content: Document());
      await controller.addOrUpdate(title: 'Two', content: Document());

      await pumpBar(tester);

      expect(find.text('2 results'), findsOneWidget);
      expect(find.widgetWithText(FilterChip, 'Pinned'), findsOneWidget);
      expect(find.widgetWithText(Chip, 'Tag'), findsOneWidget);
      expect(find.widgetWithText(ActionChip, 'Colour'), findsOneWidget);
      expect(find.text('Date range'), findsOneWidget);
    });

    testWidgets('result count follows the query', (tester) async {
      await controller.addOrUpdate(title: 'One', content: Document());
      await controller.addOrUpdate(title: 'Two', content: Document());

      await pumpBar(tester);
      expect(find.text('2 results'), findsOneWidget);

      controller.setSearchTerm('one');
      await tester.pump();
      expect(find.text('1 result'), findsOneWidget);

      controller.setSearchTerm('nothing matches');
      await tester.pump();
      expect(find.text('No results'), findsOneWidget);
    });

    testWidgets('tapping the pinned chip filters the list', (tester) async {
      await controller.addOrUpdate(title: 'Pinned', content: Document());
      await controller.addOrUpdate(title: 'Loose', content: Document());
      final pinned = controller.notes.firstWhere((n) => n.title == 'Pinned');
      await controller.setPinned(pinned.id, true);

      await pumpBar(tester);
      await tester.tap(find.widgetWithText(FilterChip, 'Pinned'));
      await tester.pump();

      expect(controller.filters.pinnedOnly, isTrue);
      expect(find.text('1 result'), findsOneWidget);
    });

    testWidgets('active filters are removable one by one', (tester) async {
      await controller.addOrUpdate(
        title: 'Tagged',
        content: Document(),
        tags: ['work'],
      );

      controller.setFilters(
        const SearchFilters(tag: 'work', pinnedOnly: true),
      );
      await pumpBar(tester);

      expect(find.widgetWithText(InputChip, 'work'), findsOneWidget);
      expect(find.text('Clear filters'), findsOneWidget);

      final tagChip =
          tester.widget<InputChip>(find.widgetWithText(InputChip, 'work'));
      tagChip.onDeleted!();
      await tester.pump();

      expect(controller.filters.tag, isNull);
      expect(controller.filters.pinnedOnly, isTrue);
    });

    testWidgets('clear filters chip removes every filter', (tester) async {
      await controller.addOrUpdate(title: 'One', content: Document());
      controller.setFilters(const SearchFilters(pinnedOnly: true));
      await pumpBar(tester);

      await tester.tap(find.text('Clear filters'));
      await tester.pump();

      expect(controller.filters.isActive, isFalse);
    });

    testWidgets('scope chip turns folder scoped search on and off',
        (tester) async {
      expect(controller.folders, isEmpty);
      await controller.addFolder('Work');
      expect(controller.folders, hasLength(1));
      controller.setSelectedFolder(controller.folders.single.id);
      await pumpBar(tester);

      expect(find.text('All notes'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilterChip, 'All notes'));
      await tester.pump();
      expect(controller.searchScope, SearchScope.folder);
      expect(find.text('This folder'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilterChip, 'This folder'));
      await tester.pump();
      expect(controller.searchScope, SearchScope.all);
    });

    testWidgets('scope chip is hidden without a folder filter', (tester) async {
      await controller.addOrUpdate(title: 'One', content: Document());
      await pumpBar(tester);

      expect(find.text('All notes'), findsNothing);
    });
  });
}
