import 'package:fox/database/database.dart';
import 'package:fox/models/note.dart';

class NoteService {
  final AppDatabase _db = AppDatabase();

  Future<List<Note>> getNotes() async {
    return await _db.getAllNotes();
  }

  Future<void> addNote(String title, String content) async {
    final note = Note(
      title: title,
      content: content,
      createdAt: DateTime.now(),
    );
    await _db.insertNote(note);
  }

  Future<void> updateNote(Note note) async {
    await _db.updateNote(note);
  }

  Future<void> deleteNote(int id) async {
    await _db.deleteNote(id);
  }
}