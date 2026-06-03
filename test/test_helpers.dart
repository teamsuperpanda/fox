import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:fox/l10n/app_localizations.dart';
import 'package:fox/models/folder.dart';
import 'package:fox/models/note.dart';
import 'package:fox/services/repository.dart';
import 'package:fox/services/umami_service.dart';
import 'package:provider/provider.dart';

/// Creates a [MaterialApp] wrapping the given [home] widget with all
/// localization delegates needed by the app (including FlutterQuill).
///
/// Use this in widget tests instead of bare `MaterialApp(home: ...)`.
Widget buildTestApp({required Widget home, ThemeData? theme}) {
  return Provider.value(
    value: UmamiService(websiteId: 'test', endpoint: 'https://test.com/api/send'),
    child: MaterialApp(
    localizationsDelegates: const [
      ...AppLocalizations.localizationsDelegates,
      FlutterQuillLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    theme: theme,
    home: home,
  ),
  );
}

/// In-memory note repository that stores notes in a list.
/// Used by NotesController unit tests.
class MemoryRepo implements NoteAndFolderRepository {
  final List<Note> _data = [];
  bool _inited = false;

  @override
  Future<void> init() async {
    _inited = true;
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
  Future<void> upsert(Note note) async {
    _data.removeWhere((e) => e.id == note.id);
    _data.add(note);
  }

  @override
  Future<void> upsertAll(List<Note> notes) async {
    for (final note in notes) {
      _data.removeWhere((e) => e.id == note.id);
      _data.add(note);
    }
  }

  @override
  Future<List<Folder>> getAllFolders() async => [];

  @override
  Future<void> upsertFolder(Folder folder) async {}

  @override
  Future<void> deleteFolder(String id) async {}
}

/// In-memory [FolderRepository] for testing folder operations.
/// In-memory [NoteRepository] and [FolderRepository] used by widget tests.
class MockRepository implements NoteAndFolderRepository {
  final List<Note> notes = [];
  final List<Folder> folders = [];

  @override
  Future<void> init() async {}

  @override
  Future<void> upsert(Note note) async {
    final index = notes.indexWhere((n) => n.id == note.id);
    if (index >= 0) {
      notes[index] = note;
    } else {
      notes.add(note);
    }
  }

  @override
  Future<void> upsertAll(List<Note> notes) async {
    for (final note in notes) {
      final index = this.notes.indexWhere((n) => n.id == note.id);
      if (index >= 0) {
        this.notes[index] = note;
      } else {
        this.notes.add(note);
      }
    }
  }

  @override
  Future<void> delete(String id) async {
    notes.removeWhere((n) => n.id == id);
  }

  @override
  Future<List<Note>> getAll() async => notes;

  // FolderRepository
  @override
  Future<List<Folder>> getAllFolders() async => folders;

  @override
  Future<void> upsertFolder(Folder folder) async {
    folders.removeWhere((f) => f.id == folder.id);
    folders.add(folder);
  }

  @override
  Future<void> deleteFolder(String id) async {
    folders.removeWhere((f) => f.id == id);
  }
}
