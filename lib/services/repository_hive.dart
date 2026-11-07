import 'package:flutter/foundation.dart';
import 'package:fox/models/folder.dart';
import 'package:fox/models/note.dart';
import 'package:fox/services/box_names.dart';
import 'package:hive/hive.dart';

abstract class NoteAndFolderRepository {
  Future<void> init();
  Future<List<Note>> getAll();
  Future<void> upsert(Note note);
  Future<void> delete(String id);
  Future<void> upsertAll(List<Note> notes);
  Future<List<Folder>> getAllFolders();
  Future<void> upsertFolder(Folder folder);
  Future<void> deleteFolder(String id);

  /// Records that could not be decoded and were skipped by the last read.
  /// Always zero for in-memory repositories.
  int get unreadableRecords => 0;
}

class HiveNoteRepository implements NoteAndFolderRepository {
  HiveNoteRepository._();
  Box<Note> get _box => Hive.box<Note>(BoxNames.notes);
  Box<Folder> get _foldersBox => Hive.box<Folder>(BoxNames.folders);

  int _unreadable = 0;

  @override
  int get unreadableRecords => _unreadable;

  static HiveNoteRepository create() {
    return HiveNoteRepository._();
  }

  @override
  Future<void> init() async {
    if (!Hive.isBoxOpen(BoxNames.notes)) {
      throw StateError(
          'Notes box not initialized. Ensure StorageService.init() was called.');
    }
  }

  /// Reads every record individually. One truncated or wrong-typed record is
  /// skipped and counted instead of aborting the whole load.
  @override
  Future<List<Note>> getAll() async {
    _unreadable = 0;
    final notes = <Note>[];
    for (final key in _box.keys) {
      try {
        final note = _box.get(key);
        if (note != null) notes.add(note);
      } catch (e) {
        _unreadable++;
        debugPrint('HiveNoteRepository: unreadable note "$key": $e');
      }
    }
    return notes;
  }

  @override
  Future<void> upsert(Note note) async {
    await _box.put(note.id, note);
  }

  @override
  Future<void> upsertAll(List<Note> notes) async {
    final map = <String, Note>{};
    for (final note in notes) {
      map[note.id] = note;
    }
    await _box.putAll(map);
  }

  @override
  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  Future<Note?> getById(String id) async {
    try {
      return _box.get(id);
    } catch (e) {
      debugPrint('HiveNoteRepository: unreadable note "$id": $e');
      return null;
    }
  }

  Future<void> clear() async {
    await _box.clear();
  }

  @override
  Future<List<Folder>> getAllFolders() async {
    final folders = <Folder>[];
    for (final key in _foldersBox.keys) {
      try {
        final folder = _foldersBox.get(key);
        if (folder != null) folders.add(folder);
      } catch (e) {
        _unreadable++;
        debugPrint('HiveNoteRepository: unreadable folder "$key": $e');
      }
    }
    return folders;
  }

  @override
  Future<void> upsertFolder(Folder folder) async {
    await _foldersBox.put(folder.id, folder);
  }

  @override
  Future<void> deleteFolder(String id) async {
    await _foldersBox.delete(id);
  }
}
