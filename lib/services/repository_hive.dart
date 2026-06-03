import 'package:fox/models/folder.dart';
import 'package:fox/models/note.dart';
import 'package:fox/services/box_names.dart';
import 'package:fox/services/repository.dart';
import 'package:hive/hive.dart';

class HiveNoteRepository implements NoteAndFolderRepository {
  HiveNoteRepository._();
  Box<Note> get _box => Hive.box<Note>(BoxNames.notes);
  Box<Folder> get _foldersBox => Hive.box<Folder>(BoxNames.folders);

  static HiveNoteRepository create() {
    return HiveNoteRepository._();
  }

  @override
  Future<void> init() async {
    // Box should already be opened by StorageService
    if (!Hive.isBoxOpen(BoxNames.notes)) {
      throw StateError(
          'Notes box not initialized. Ensure StorageService.init() was called.');
    }
  }

  @override
  Future<List<Note>> getAll() async {
    return _box.values.toList();
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

  // Not on the interface but useful for direct testing
  Future<Note?> getById(String id) async {
    return _box.get(id);
  }

  Future<void> clear() async {
    await _box.clear();
  }

  // Folder operations

  @override
  Future<List<Folder>> getAllFolders() async {
    return _foldersBox.values.toList();
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
