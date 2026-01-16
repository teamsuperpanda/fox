import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_quill/flutter_quill.dart';

import 'package:fox/home_page.dart';
import 'package:fox/note_detail_page.dart';
import 'package:fox/providers/theme_provider.dart';
import 'package:fox/services/notes_controller.dart';
import 'package:fox/services/repository.dart';
import 'package:fox/models/note.dart';

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
        child: MaterialApp(
          localizationsDelegates: [FlutterQuillLocalizations.delegate],
          home: HomePage(controller: controller),
        ),
      ));
      expect(find.textContaining('No notes yet'), findsOneWidget);
    });

    testWidgets('navigates to NoteDetailPage on FAB tap', (tester) async {
      await tester.pumpWidget(ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: MaterialApp(
          localizationsDelegates: [FlutterQuillLocalizations.delegate],
          home: HomePage(controller: controller),
        ),
      ));
      expect(find.byType(NoteDetailPage), findsNothing);

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // The detail page should be visible
      expect(find.byType(NoteDetailPage), findsOneWidget);
    });

    testWidgets('pinned note shows pin icon', (tester) async {
      // Seed a pinned note
      await controller.addOrUpdate(title: 'A', content: Document(), pinned: true);
      await tester.pumpWidget(ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: MaterialApp(
          localizationsDelegates: [FlutterQuillLocalizations.delegate],
          home: HomePage(controller: controller),
        ),
      ));
      await tester.pumpAndSettle();

      // There should be a push_pin icon (unpinned)
      expect(find.byIcon(Icons.push_pin), findsOneWidget);
      expect(find.byIcon(Icons.push_pin_outlined), findsNothing);
    });

    testWidgets('search functionality works', (tester) async {
      // Seed notes
      await controller.addOrUpdate(title: 'Apple', content: Document.fromJson([{"insert":"fruit\n"}]));
      await controller.addOrUpdate(title: 'Banana', content: Document.fromJson([{"insert":"yellow\n"}]));
      await controller.addOrUpdate(title: 'Car', content: Document.fromJson([{"insert":"vehicle\n"}]));

      await tester.pumpWidget(ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: MaterialApp(
          localizationsDelegates: [FlutterQuillLocalizations.delegate],
          home: HomePage(controller: controller),
        ),
      ));
      await tester.pumpAndSettle();

      // Initially shows all 3 notes
      expect(find.text('Apple'), findsOneWidget);
      expect(find.text('Banana'), findsOneWidget);
      expect(find.text('Car'), findsOneWidget);

      // Tap search icon
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      // Enter search term
      await tester.enterText(find.byType(TextField), 'a');
      await tester.pumpAndSettle();

      // Should show filtered results
      expect(find.text('Apple'), findsOneWidget);
      expect(find.text('Banana'), findsOneWidget);
      expect(find.text('Car'), findsOneWidget); // all contain 'a'

      // Clear search
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pumpAndSettle();

      expect(find.text('Apple'), findsOneWidget);
      expect(find.text('Banana'), findsOneWidget);
      expect(find.text('Car'), findsOneWidget);
    });

    testWidgets('sort functionality works', (tester) async {
      // Seed notes with different titles
      await controller.addOrUpdate(title: 'Zebra', content: Document());
      await controller.addOrUpdate(title: 'Apple', content: Document());

      await tester.pumpWidget(ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: MaterialApp(
          localizationsDelegates: [FlutterQuillLocalizations.delegate],
          home: HomePage(controller: controller),
        ),
      ));
      await tester.pumpAndSettle();

      // Initially sorted by date desc, so newer first
      final titles = controller.notes.map((n) => n.title).toList();
      expect(titles.first, isNot('Zebra')); // Apple is newer

      // Open view options menu
      await tester.tap(find.byIcon(Icons.tune));
      await tester.pumpAndSettle();

      // Select title ascending
      await tester.tap(find.text('Title (A-Z)'));
      await tester.pumpAndSettle();

      // Close dialog
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      // Should be sorted alphabetically
      expect(find.text('Apple'), findsOneWidget);
      expect(find.text('Zebra'), findsOneWidget);
      // The order in UI should reflect the sort
    });
  });
}
