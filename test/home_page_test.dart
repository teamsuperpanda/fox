import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:fox/home_page.dart';
import 'package:fox/note_detail_page.dart';
import 'package:fox/providers/theme_provider.dart';
import 'package:fox/services/notes_controller.dart';
import 'package:fox/services/repository.dart';

class MemoryRepo implements NoteRepository {
  final List<Note> _data = [];
  bool _inited = false;

  @override
  Future<void> init() async {
    _inited = true;
  }

  @override
  Future<void> clear() async {
    _data.clear();
  }

  @override
  Future<void> delete(String id) async {
    _data.removeWhere((e) => e.id == id);
  }

  @override
  Future<List<Note>> getAll() async {
    if (!_inited) throw StateError('init not called');
    return List.unmodifiable(_data);
  }

  @override
  Future<Note?> getById(String id) async {
    try {
      return _data.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> upsert(Note note) async {
    _data.removeWhere((e) => e.id == note.id);
    _data.add(note);
  }
}

void main() {
  group('HomePage widget', () {
    late NotesController controller;

    setUp(() async {
      controller = NotesController(MemoryRepo());
      await controller.load();
    });

    testWidgets('shows empty state initially', (tester) async {
      await tester.pumpWidget(ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: MaterialApp(home: HomePage(controller: controller)),
      ));
      expect(find.textContaining('No notes yet'), findsOneWidget);
    });

    testWidgets('navigates to NoteDetailPage on FAB tap', (tester) async {
      await tester.pumpWidget(ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: MaterialApp(home: HomePage(controller: controller)),
      ));
      expect(find.byType(NoteDetailPage), findsNothing);

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // The detail page should be visible
      expect(find.byType(NoteDetailPage), findsOneWidget);
    });

    testWidgets('pin toggle updates list item icon', (tester) async {
      // Seed one note
      await controller.addOrUpdate(title: 'A', content: '');
      await tester.pumpWidget(ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: MaterialApp(home: HomePage(controller: controller)),
      ));
      await tester.pumpAndSettle();

  // Find the list tile for the note titled 'A'
  final tile = find.widgetWithText(ListTile, 'A');
  expect(tile, findsOneWidget);

  // The leading IconButton contains an Icon whose IconData indicates pinned state
  final pinButton = find.descendant(of: tile, matching: find.byType(IconButton));
  expect(pinButton, findsOneWidget);

  IconButton iconButtonWidget = tester.widget<IconButton>(pinButton);
  final leadingIcon = iconButtonWidget.icon as Icon;

  // Initially the icon should be the grey (unpinned) color
  expect(leadingIcon.color, Colors.grey[700]);

  // Toggle pin by tapping the leading IconButton
  await tester.tap(pinButton);
  await tester.pumpAndSettle();

  // After toggling, the controller should show the note as pinned
  expect(controller.notes.isNotEmpty, isTrue);
  expect(controller.notes.first.pinned, isTrue);
    });

    testWidgets('swipe to delete removes a note', (tester) async {
      // Seed one note
      await controller.addOrUpdate(title: 'ToDelete', content: '');
      await tester.pumpWidget(ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: MaterialApp(home: HomePage(controller: controller)),
      ));
      await tester.pumpAndSettle();

      expect(find.text('ToDelete'), findsOneWidget);

      // Perform a swipe from right to left on the Dismissible
      final item = find.text('ToDelete');
      await tester.drag(item, const Offset(-500, 0));
      await tester.pumpAndSettle();

      // Confirm the deletion in the dialog
      await tester.tap(find.widgetWithText(TextButton, 'Delete'));
      await tester.pumpAndSettle();

      expect(find.text('ToDelete'), findsNothing);
    });
  });
}
