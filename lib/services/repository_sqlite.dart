import 'dart:async';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'repository.dart';

class SqliteNoteRepository implements NoteRepository {
  Database? _db;

  SqliteNoteRepository._();

  static Future<SqliteNoteRepository> create() async {
    final repo = SqliteNoteRepository._();
    await repo.init();
    return repo;
  }

  @override
  Future<void> init() async {
    if (_db != null) return;
    final dir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(dir.path, 'fox_notes.db');
    _db = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE notes(
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            content TEXT NOT NULL,
            pinned INTEGER NOT NULL,
            updatedAt INTEGER NOT NULL
          )
        ''');
        await db.execute('CREATE INDEX idx_notes_pinned ON notes(pinned)');
        await db
            .execute('CREATE INDEX idx_notes_updatedAt ON notes(updatedAt)');
      },
    );
  }

  @override
  Future<List<Note>> getAll() async {
    final db = _ensure();
    final rows = await db.query('notes');
    final notes = rows.map((e) => Note.fromMap(e)).toList();
    notes.sort((a, b) {
      if (a.pinned != b.pinned) return a.pinned ? -1 : 1;
      return b.updatedAt.compareTo(a.updatedAt);
    });
    return notes;
  }

  @override
  Future<Note?> getById(String id) async {
    final db = _ensure();
    final rows =
        await db.query('notes', where: 'id = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return Note.fromMap(rows.first);
  }

  @override
  Future<void> upsert(Note note) async {
    final db = _ensure();
    await db.insert(
      'notes',
      note.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> delete(String id) async {
    final db = _ensure();
    await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<void> clear() async {
    final db = _ensure();
    await db.delete('notes');
  }

  Database _ensure() {
    final db = _db;
    if (db == null) {
      throw StateError('Database not initialized. Call init() first.');
    }
    return db;
  }
}
