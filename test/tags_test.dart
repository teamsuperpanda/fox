import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fox/home_page.dart';
import 'package:fox/l10n/app_localizations.dart';
import 'package:fox/note_detail_page.dart';
import 'package:fox/services/notes_controller.dart';
import 'package:fox/services/settings_service.dart';
import 'package:fox/widgets/tags_dialog.dart';

import 'test_helpers.dart';

Widget _buildHome(NotesController controller) => HomePage(
      controller: controller,
      settingsService: SettingsService(),
    );

/// Dialogs need a [Scaffold] ancestor to show a snackbar.
Widget _dialogHost(Widget dialog) => Scaffold(
      body: Center(child: dialog),
    );

void main() {
  group('NotesController tags', () {
    late MemoryRepo repo;
    late NotesController controller;

    setUp(() async {
      repo = MemoryRepo();
      controller = NotesController(repo);
      await controller.load();
    });

    test('tagCounts counts notes per tag, highest first', () async {
      await controller.addOrUpdate(
        title: 'One',
        content: Document(),
        tags: ['work', 'urgent'],
      );
      await controller.addOrUpdate(
        title: 'Two',
        content: Document(),
        tags: ['work'],
      );

      expect(controller.tagCounts, {'work': 2, 'urgent': 1});
      expect(controller.allTags, ['work', 'urgent']);
    });

    test('tagCounts is empty when no note has tags', () async {
      await controller.addOrUpdate(title: 'Plain', content: Document());
      expect(controller.tagCounts, isEmpty);
    });

    test('setSelectedTag filters the list and notifies', () async {
      await controller.addOrUpdate(
        title: 'Work note',
        content: Document(),
        tags: ['work'],
      );
      await controller.addOrUpdate(
        title: 'Home note',
        content: Document(),
        tags: ['home'],
      );
      var notifications = 0;
      controller.addListener(() => notifications++);

      controller.setSelectedTag('WORK');
      expect(controller.selectedTag, 'work');
      expect(controller.notes.map((n) => n.title), ['Work note']);
      expect(notifications, 1);

      controller.setSelectedTag(null);
      expect(controller.notes.length, 2);
      expect(notifications, 2);
    });

    test('tag and folder filters combine', () async {
      await controller.addFolder('Projects');
      final folderId = controller.folders.single.id;
      await controller.addOrUpdate(
        title: 'Filed work',
        content: Document(),
        tags: ['work'],
        folderId: folderId,
      );
      await controller.addOrUpdate(
        title: 'Unfiled work',
        content: Document(),
        tags: ['work'],
      );
      await controller.addOrUpdate(
        title: 'Filed home',
        content: Document(),
        tags: ['home'],
        folderId: folderId,
      );

      controller.setSelectedFolder(folderId);
      controller.setSelectedTag('work');

      expect(controller.notes.map((n) => n.title), ['Filed work']);
    });

    test('suggestTags needs two characters and matches prefixes', () async {
      await controller.addOrUpdate(
        title: 'Tagged',
        content: Document(),
        tags: ['work', 'workshop', 'home'],
      );

      expect(controller.suggestTags('w'), isEmpty);
      expect(controller.suggestTags('wo'), ['work', 'workshop']);
      expect(controller.suggestTags('WO'), ['work', 'workshop']);
      expect(
        controller.suggestTags('wo', exclude: ['work']),
        ['workshop'],
      );
    });

    test('renameTag merges duplicates across notes', () async {
      await controller.addOrUpdate(
        title: 'One',
        content: Document(),
        tags: ['work', 'keep'],
      );
      await controller.addOrUpdate(
        title: 'Two',
        content: Document(),
        tags: ['work', 'wrk'],
      );

      await controller.renameTag('work', 'Wrk');

      final one = controller
          .find(controller.notes.firstWhere((n) => n.title == 'One').id)!;
      final two = controller
          .find(controller.notes.firstWhere((n) => n.title == 'Two').id)!;
      expect(one.tags, ['wrk', 'keep']);
      expect(two.tags, ['wrk']);
      expect(controller.tagCounts, {'wrk': 2, 'keep': 1});
    });

    test('renameTag moves an active tag filter to the new name', () async {
      await controller.addOrUpdate(
        title: 'Note',
        content: Document(),
        tags: ['work'],
      );
      controller.setSelectedTag('work');

      await controller.renameTag('work', 'job');

      expect(controller.selectedTag, 'job');
      expect(controller.notes.single.tags, ['job']);
    });

    test('undoRenameTag restores the previous tags', () async {
      await controller.addOrUpdate(
        title: 'Note',
        content: Document(),
        tags: ['work'],
      );

      await controller.renameTag('work', 'job');
      expect(controller.notes.single.tags, ['job']);

      await controller.undoRenameTag();
      expect(controller.notes.single.tags, ['work']);
      expect(controller.selectedTag, isNull);
    });

    test('renaming to the same name or an empty name is a no-op', () async {
      await controller.addOrUpdate(
        title: 'Note',
        content: Document(),
        tags: ['work'],
      );
      final before = controller.notes.single;

      await controller.renameTag('work', 'WORK');
      await controller.renameTag('work', '   ');
      await controller.renameTag('missing', 'other');

      expect(controller.notes.single.updatedAt, before.updatedAt);
    });

    test('deleteTag removes the tag from every note', () async {
      await controller.addOrUpdate(
        title: 'One',
        content: Document(),
        tags: ['work', 'keep'],
      );
      await controller.addOrUpdate(
        title: 'Two',
        content: Document(),
        tags: ['work'],
      );
      controller.setSelectedTag('work');

      await controller.deleteTag('work');

      expect(
        controller.notes.map((n) => n.tags),
        unorderedEquals([
          <String>[],
          ['keep']
        ]),
      );
      expect(controller.selectedTag, isNull);
      expect(controller.tagCounts, {'keep': 1});
    });
  });

  group('TagsDialog', () {
    late MockRepository repo;
    late NotesController controller;

    setUp(() async {
      repo = MockRepository();
      controller = NotesController(repo);
      await controller.load();
      await controller.addOrUpdate(
        title: 'One',
        content: Document(),
        tags: ['work'],
      );
      await controller.addOrUpdate(
        title: 'Two',
        content: Document(),
        tags: ['work', 'home'],
      );
    });

    testWidgets('lists tags with note counts', (tester) async {
      await tester.pumpWidget(
        buildTestApp(_dialogHost(TagsDialog(controller: controller))),
      );
      await tester.pump();

      expect(find.text('work'), findsOneWidget);
      expect(find.text('home'), findsOneWidget);
      expect(find.text('2 notes'), findsOneWidget);
      expect(find.text('1 note'), findsOneWidget);
    });

    testWidgets('shows an empty state when there are no tags', (tester) async {
      final emptyController = NotesController(MockRepository());
      await emptyController.load();

      await tester.pumpWidget(
        buildTestApp(_dialogHost(TagsDialog(controller: emptyController))),
      );
      await tester.pump();

      final l10n = AppLocalizations.of(tester.element(find.byType(TagsDialog)));
      expect(find.text(l10n.noTags), findsOneWidget);
    });

    testWidgets('tapping a tag applies the filter and closes', (tester) async {
      await tester.pumpWidget(
        buildTestApp(_dialogHost(TagsDialog(controller: controller))),
      );
      await tester.pump();

      await tester.tap(find.text('home'));
      await tester.pumpAndSettle();

      expect(controller.selectedTag, 'home');
      expect(find.byType(TagsDialog), findsNothing);
    });

    testWidgets('rename merges duplicates and can be undone', (tester) async {
      await tester.pumpWidget(
        buildTestApp(_dialogHost(TagsDialog(controller: controller))),
      );
      await tester.pump();
      final l10n = AppLocalizations.of(tester.element(find.byType(TagsDialog)));

      await tester.tap(find.byIcon(Icons.more_vert).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.rename));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).last, 'office');
      await tester.tap(find.widgetWithText(TextButton, l10n.rename));
      await tester.pumpAndSettle();

      expect(controller.tagCounts, {'office': 2, 'home': 1});
      expect(find.text(l10n.tagRenamed('office')), findsOneWidget);

      await tester.tap(find.text(l10n.undo));
      await tester.pumpAndSettle();

      expect(controller.tagCounts, {'work': 2, 'home': 1});
    });

    testWidgets('delete removes the tag from every note', (tester) async {
      await tester.pumpWidget(
        buildTestApp(_dialogHost(TagsDialog(controller: controller))),
      );
      await tester.pump();
      final l10n = AppLocalizations.of(tester.element(find.byType(TagsDialog)));

      await tester.tap(find.byIcon(Icons.more_vert).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.delete));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, l10n.delete));
      await tester.pumpAndSettle();

      expect(controller.tagCounts, {'home': 1});
      expect(repo.notes.every((n) => !n.tags.contains('work')), isTrue);
    });
  });

  group('Tag filtering in the UI', () {
    testWidgets('home chip row filters by tag', (tester) async {
      final repo = MockRepository();
      final controller = NotesController(repo);
      await controller.load();
      await controller.addOrUpdate(
        title: 'Work note',
        content: Document(),
        tags: ['work'],
      );
      await controller.addOrUpdate(
        title: 'Home note',
        content: Document(),
        tags: ['home'],
      );

      await tester.pumpWidget(buildTestApp(_buildHome(controller)));
      await tester.pump();

      expect(find.text('Work note'), findsOneWidget);
      await tester.tap(find.text('work (1)'));
      await tester.pump();

      expect(controller.selectedTag, 'work');
      expect(find.text('Work note'), findsOneWidget);
      expect(find.text('Home note'), findsNothing);
    });

    testWidgets('home app bar opens the tag manager', (tester) async {
      final repo = MockRepository();
      final controller = NotesController(repo);
      await controller.load();
      await controller.addOrUpdate(
        title: 'Note',
        content: Document(),
        tags: ['work'],
      );

      await tester.pumpWidget(buildTestApp(_buildHome(controller)));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.label_outline));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(TagsDialog), findsOneWidget);
      expect(find.text('1 note'), findsOneWidget);
    });

    testWidgets('note dialog suggests existing tags after two characters',
        (tester) async {
      final repo = MockRepository();
      final controller = NotesController(repo);
      await controller.load();
      await controller.addOrUpdate(
        title: 'Existing',
        content: Document(),
        tags: ['work'],
      );

      await tester.pumpWidget(
        buildTestApp(
          NoteDetailPage(controller: controller, showToolbar: false),
        ),
      );
      final l10n = AppLocalizations.of(
        tester.element(find.byType(NoteDetailPage)),
      );

      await tester.tap(find.byIcon(Icons.label_outline));
      await tester.pumpAndSettle();

      final field = find.widgetWithText(TextField, l10n.newTag);
      await tester.enterText(field, 'w');
      await tester.pump();
      expect(find.widgetWithText(ActionChip, 'work'), findsNothing);

      await tester.enterText(field, 'wo');
      await tester.pump();
      expect(find.widgetWithText(ActionChip, 'work'), findsOneWidget);

      await tester.tap(find.widgetWithText(ActionChip, 'work'));
      await tester.pump();
      expect(find.widgetWithText(Chip, 'work'), findsOneWidget);
    });
  });
}
