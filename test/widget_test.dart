// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:fox/home_page.dart';
import 'package:fox/providers/theme_provider.dart';
import 'package:fox/services/notes_controller.dart';
import 'package:fox/services/repository.dart';
import 'package:fox/models/note.dart';

class MemoryRepo implements NoteRepository {
  final List<Note> _data = [];
  @override
  Future<void> init() async {}

  @override
  Future<void> clear() async => _data.clear();

  @override
  Future<void> delete(String id) async {
    _data.removeWhere((e) => e.id == id);
  }

  @override
  Future<List<Note>> getAll() async => List.unmodifiable(_data);

  @override
  Future<Note?> getById(String id) async =>
      _data.cast<Note?>().firstWhere((e) => e?.id == id, orElse: () => null);

  @override
  Future<void> upsert(Note note) async {
    _data.removeWhere((e) => e.id == note.id);
    _data.add(note);
  }
}

void main() {
  testWidgets('App builds and shows empty state', (WidgetTester tester) async {
    final controller = NotesController(MemoryRepo());
    await controller.load();

    await tester.pumpWidget(ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: MaterialApp(home: HomePage(controller: controller)),
    ));

    expect(find.textContaining('No notes yet'), findsOneWidget);
  });
}
