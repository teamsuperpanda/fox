import '../models/note.dart';
import '../models/folder.dart';

abstract class NoteRepository {
  Future<void> init();
  Future<List<Note>> getAll();
  Future<Note?> getById(String id);
  Future<void> upsert(Note note);
  Future<void> delete(String id);
  Future<void> clear(); // not used in app, but handy for tests

  // Folder operations
  Future<List<Folder>> getAllFolders();
  Future<void> upsertFolder(Folder folder);
  Future<void> deleteFolder(String id);
}
