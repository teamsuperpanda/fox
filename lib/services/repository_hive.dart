import 'dart:async';
import 'package:hive/hive.dart';

import 'repository.dart';
import '../models/note.dart';

class HiveNoteRepository implements NoteRepository {
  static const _boxName = 'notes_db';
  
  Box<Note> get _box => Hive.box<Note>(_boxName);

  HiveNoteRepository._();

  static Future<HiveNoteRepository> create() async {
    final repo = HiveNoteRepository._();
    await repo.init();
    return repo;
  }

  @override
  Future<void> init() async {
    // Box should already be opened by StorageService
    if (!Hive.isBoxOpen(_boxName)) {
      throw StateError('Notes box not initialized. Ensure StorageService.init() was called.');
    }
  }

  @override
  Future<List<Note>> getAll() async {
    return _box.values.toList();
  }

  @override
  Future<Note?> getById(String id) async {
    return _box.get(id);
  }

  @override
  Future<void> upsert(Note note) async {
    await _box.put(note.id, note);
  }

  @override
  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  @override
  Future<void> clear() async {
    await _box.clear();
  }
}
