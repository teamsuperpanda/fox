import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:fox/l10n/app_localizations.dart';
import 'package:fox/models/folder.dart';
import 'package:fox/models/note.dart';
import 'package:fox/services/repository_hive.dart';

Widget buildTestApp({required Widget home, ThemeData? theme}) {
  return MaterialApp(
    localizationsDelegates: const [
      ...AppLocalizations.localizationsDelegates,
      FlutterQuillLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    theme: theme,
    home: home,
  );
}

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
