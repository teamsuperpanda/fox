import 'package:fox/models/folder.dart';
import 'package:fox/models/note.dart';

abstract class NoteRepository {
  Future<void> init();
  Future<List<Note>> getAll();
  Future<void> upsert(Note note);
  Future<void> delete(String id);
  Future<void> upsertAll(List<Note> notes);
}

abstract class FolderRepository {
  Future<List<Folder>> getAllFolders();
  Future<void> upsertFolder(Folder folder);
  Future<void> deleteFolder(String id);
}

abstract class NoteAndFolderRepository implements NoteRepository, FolderRepository {}
