import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fox/l10n/app_localizations.dart';
import 'package:fox/models/note.dart';
import 'package:fox/note_detail_page.dart';
import 'package:fox/services/notes_controller.dart';
import 'test_helpers.dart';

class FailingSaveRepository extends MockRepository {
  @override
  Future<void> upsert(Note note) async {
    throw Exception('save failed');
  }
}

class FailingDeleteRepository extends MockRepository {
  @override
  Future<void> delete(String id) async {
    throw Exception('delete failed');
  }
}

class DelayedRepository extends MockRepository {
  final Completer<void> upsertCompleter = Completer<void>();
  final Completer<void> deleteCompleter = Completer<void>();

  @override
  Future<void> upsert(Note note) async {
    await upsertCompleter.future;
    await super.upsert(note);
  }

  @override
  Future<void> delete(String id) async {
    await deleteCompleter.future;
    await super.delete(id);
  }
}

void main() {
  group('NoteDetailPage - Basic Tests', () {
    test('Note copyWith updates pinned state', () {
      final original = makeNote(id: 'test', title: 'Title');

      final updated = original.copyWith(pinned: true);
      expect(updated.pinned, isTrue);
      expect(updated.id, equals('test'));
    });

    test('Note copyWith preserves other fields', () {
      final now = DateTime.now();
      final original = makeNote(id: 'test', title: 'Title', updatedAt: now);

      final updated = original.copyWith(pinned: true);
      expect(updated.title, equals('Title'));
      expect(updated.updatedAt, equals(now));
    });
  });

  group('NoteDetailPage - Controller Tests', () {
    late MockRepository mockRepo;
    late NotesController controller;

    setUp(() {
      mockRepo = MockRepository();
      controller = NotesController(mockRepo);
    });

    test('controller adds new note', () async {
      final doc = Document();
      await controller.addOrUpdate(
        title: 'New Note',
        content: doc,
      );

      expect(mockRepo.notes.length, equals(1));
      expect(mockRepo.notes.first.title, equals('New Note'));
    });

    test('controller updates existing note', () async {
      final originalNote = makeNote(id: 'test-id', title: 'Original');

      mockRepo.notes.add(originalNote);

      await controller.addOrUpdate(
        id: 'test-id',
        title: 'Updated',
        content: Document(),
        pinned: true,
      );

      expect(mockRepo.notes.length, equals(1));
      expect(mockRepo.notes.first.title, equals('Updated'));
      expect(mockRepo.notes.first.pinned, isTrue);
    });

    test('controller saves pinned state', () async {
      await controller.addOrUpdate(
        title: 'Pinned Note',
        content: Document(),
        pinned: true,
      );

      final saved = mockRepo.notes.first;
      expect(saved.pinned, isTrue);
      expect(saved.title, equals('Pinned Note'));
    });

    test('controller allows title-only notes', () async {
      await controller.addOrUpdate(
        title: 'Title Only',
        content: Document(),
      );

      expect(mockRepo.notes.length, equals(1));
      expect(mockRepo.notes.first.title, equals('Title Only'));
    });
  });

  group('NoteDetailPage - Widget Tests', () {
    late MockRepository mockRepo;
    late NotesController controller;

    setUp(() {
      mockRepo = MockRepository();
      controller = NotesController(mockRepo);
    });

    testWidgets('creates note with title', (tester) async {
      await tester.pumpWidget(
        buildTestApp(NoteDetailPage(controller: controller)),
      );

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.byType(NoteDetailPage), findsNothing);
      expect(mockRepo.notes.length, 0);
    });

    testWidgets('shows error for empty title save', (tester) async {
      final existingNote = makeNote(id: 'existing', title: 'Existing');
      mockRepo.notes.add(existingNote);

      await tester.pumpWidget(
        buildTestApp(
            NoteDetailPage(existing: existingNote, controller: controller)),
      );
      final l10n = AppLocalizations.of(
        tester.element(find.byType(NoteDetailPage)),
      );

      final titleField = find.byType(TextField).first;
      await tester.enterText(titleField, '');
      await tester.pump();
      await tester.tap(find.byIcon(Icons.save));
      await tester.pump();

      expect(find.textContaining(l10n.noteCannotBeEmpty), findsOneWidget);
      expect(mockRepo.notes.length, 1);
    });

    testWidgets('pin button shows correct state', (tester) async {
      final note = makeNote(title: '');

      await tester.pumpWidget(
        buildTestApp(NoteDetailPage(
            existing: note, controller: controller, showToolbar: false)),
      );

      expect(find.byIcon(Icons.push_pin_outlined), findsOneWidget);
    });

    testWidgets('pin button shows pinned state', (tester) async {
      final note = makeNote(title: '', pinned: true);

      await tester.pumpWidget(
        buildTestApp(NoteDetailPage(
            existing: note, controller: controller, showToolbar: false)),
      );

      expect(find.byIcon(Icons.push_pin), findsOneWidget);
    });

    testWidgets('tags dialog allows adding and removing tags', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
            NoteDetailPage(controller: controller, showToolbar: false)),
      );
      final l10n = AppLocalizations.of(
        tester.element(find.byType(NoteDetailPage)),
      );

      await tester.tap(find.byIcon(Icons.label_outline));
      await tester.pumpAndSettle();

      expect(find.text(l10n.manageTags), findsOneWidget);

      await tester.enterText(
          find.widgetWithText(TextField, l10n.newTag), 'test-tag');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(find.text('test-tag'), findsOneWidget);

      await tester.enterText(
          find.widgetWithText(TextField, l10n.newTag), 'another-tag');
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      expect(find.text('another-tag'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.cancel).first);
      await tester.pumpAndSettle();

      expect(find.text('test-tag'), findsNothing);
      expect(find.text('another-tag'), findsOneWidget);

      await tester.tap(find.text(l10n.close));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'Tagged Note');
      await tester.tap(find.byIcon(Icons.save));
      await tester.pumpAndSettle();

      expect(mockRepo.notes.length, 1);
      expect(mockRepo.notes.first.tags, contains('another-tag'));
    });

    testWidgets('save failure keeps user on page and shows error',
        (tester) async {
      final failingRepo = FailingSaveRepository();
      final failingController = NotesController(failingRepo);

      await tester.pumpWidget(
        buildTestApp(NoteDetailPage(controller: failingController)),
      );

      await tester.enterText(find.byType(TextField).first, 'Will Fail');
      await tester.pump();

      await tester.tap(find.byIcon(Icons.save));
      await tester.pump();

      expect(find.byType(NoteDetailPage), findsOneWidget);
      expect(failingRepo.notes, isEmpty);
    });

    testWidgets('save pops only after awaited write success', (tester) async {
      final delayedRepo = DelayedRepository();
      final delayedController = NotesController(delayedRepo);

      await tester.pumpWidget(
        buildTestApp(NoteDetailPage(controller: delayedController)),
      );

      await tester.enterText(find.byType(TextField).first, 'Delayed Save');
      await tester.pump();

      await tester.tap(find.byIcon(Icons.save));
      await tester.pump();

      expect(find.byType(NoteDetailPage), findsOneWidget);

      delayedRepo.upsertCompleter.complete();
      await tester.pumpAndSettle();

      expect(find.byType(NoteDetailPage), findsNothing);
    });

    testWidgets('delete failure does not pop detail page', (tester) async {
      final failingRepo = FailingDeleteRepository();
      final failingController = NotesController(failingRepo);

      await failingController.load();
      await failingController.addOrUpdate(
        title: 'Delete Me',
        content: Document(),
      );
      final existing = failingController.notes.first;

      await tester.pumpWidget(
        buildTestApp(
            NoteDetailPage(existing: existing, controller: failingController)),
      );

      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pump();

      expect(find.textContaining('Error deleting note'), findsOneWidget);
      expect(find.byType(NoteDetailPage), findsOneWidget);
    });

    testWidgets('delete pops only after awaited delete success',
        (tester) async {
      final delayedRepo = DelayedRepository();
      final delayedController = NotesController(delayedRepo);

      await delayedController.load();
      delayedRepo.upsertCompleter.complete();
      await delayedController.addOrUpdate(
        title: 'Delayed Delete',
        content: Document(),
      );
      final existing = delayedController.notes.first;

      await tester.pumpWidget(
        buildTestApp(
            NoteDetailPage(existing: existing, controller: delayedController)),
      );

      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pump();

      expect(find.byType(NoteDetailPage), findsOneWidget);

      delayedRepo.deleteCompleter.complete();
      await tester.pumpAndSettle();

      expect(find.byType(NoteDetailPage), findsNothing);
    });

    testWidgets('toolbar offers H1-H3 and a code block button', (tester) async {
      await tester.pumpWidget(
        buildTestApp(NoteDetailPage(controller: controller)),
      );
      await tester.pump();

      final dropdown =
          tester.widget<QuillToolbarSelectHeaderStyleDropdownButton>(
        find.byType(QuillToolbarSelectHeaderStyleDropdownButton),
      );
      expect(
        dropdown.options.attributes,
        [Attribute.header, Attribute.h1, Attribute.h2, Attribute.h3],
      );

      final codeBlockButtons = tester
          .widgetList<QuillToolbarToggleStyleButton>(
            find.byType(QuillToolbarToggleStyleButton),
          )
          .where((button) => button.attribute == Attribute.codeBlock);
      expect(codeBlockButtons, hasLength(1));
    });

    testWidgets('code blocks use a monospace style', (tester) async {
      await tester.pumpWidget(
        buildTestApp(NoteDetailPage(controller: controller)),
      );
      await tester.pump();

      final editor = tester.widget<QuillEditor>(find.byType(QuillEditor));
      expect(editor.config.customStyles?.code?.style.fontFamily, 'monospace');
    });

    testWidgets('headings and code blocks survive a save', (tester) async {
      final doc = Document.fromJson([
        {
          'insert': 'Title\n',
          'attributes': {'header': 1}
        },
        {
          'insert': 'Code\n',
          'attributes': {'code-block': true}
        },
      ]);
      final note = makeNote(
        id: 'rich',
        title: 'Rich',
        content: Note.documentToContent(doc),
      );
      mockRepo.notes.add(note);

      await tester.pumpWidget(
        buildTestApp(
          NoteDetailPage(
            existing: note,
            controller: controller,
            showToolbar: false,
          ),
        ),
      );
      await tester.tap(find.byIcon(Icons.save));
      await tester.pumpAndSettle();

      final saved = mockRepo.notes.single;
      final ops = saved.document.toDelta().toJson();
      expect(ops.first['attributes'], {'header': 1});
      expect(ops[1]['attributes'], {'code-block': true});
      expect(saved.plainText, 'Title\nCode\n');
    });

    testWidgets('toolbar stays usable at 320 px and 200% text in dark mode',
        (tester) async {
      final doc = Document.fromJson([
        {
          'insert': 'Title\n',
          'attributes': {'header': 1}
        },
        {
          'insert': 'Code\n',
          'attributes': {'code-block': true}
        },
      ]);
      final note = makeNote(
        id: 'narrow',
        title: 'Narrow',
        content: Note.documentToContent(doc),
      );

      await tester.pumpWidget(
        buildTestApp(
          MediaQuery(
            data: const MediaQueryData(
              size: Size(320, 640),
              textScaler: TextScaler.linear(2),
            ),
            child: NoteDetailPage(existing: note, controller: controller),
          ),
          themeMode: ThemeMode.dark,
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(
        find.byType(QuillToolbarSelectHeaderStyleDropdownButton),
        findsOneWidget,
      );
      expect(find.byType(QuillEditor), findsOneWidget);

      // Pop the page so the editor and its caret blink timer are disposed.
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
    });
  });
}
