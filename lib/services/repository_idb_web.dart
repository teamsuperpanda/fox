import 'dart:async';
import 'package:idb_shim/idb_browser.dart';

import 'repository.dart';

class WebIdbNoteRepository implements NoteRepository {
  static const _dbName = 'fox_notes_db';
  static const _storeName = 'notes';
  static const _dbVersion = 1;

  Database? _db;

  WebIdbNoteRepository._();

  static Future<WebIdbNoteRepository> create() async {
    final repo = WebIdbNoteRepository._();
    await repo.init();
    return repo;
  }

  @override
  Future<void> init() async {
    if (_db != null) return;
    final factory = getIdbFactory()!;
    _db = await factory.open(_dbName, version: _dbVersion,
        onUpgradeNeeded: (VersionChangeEvent e) {
      final db = e.database;
      if (!db.objectStoreNames.contains(_storeName)) {
        db.createObjectStore(_storeName, keyPath: 'id');
      }
    });
  }

  @override
  Future<List<Note>> getAll() async {
    final db = _ensure();
    final txn = db.transaction(_storeName, idbModeReadOnly);
    final store = txn.objectStore(_storeName);
    final values = await store.getAll() as List<Object?>;
    await txn.completed;

    final notes = values
        .whereType<Map<Object?, Object?>>()
        .map((m) => m.map((k, v) => MapEntry(k as String, v)))
        .map(Note.fromMap)
        .toList();

    notes.sort((a, b) {
      if (a.pinned != b.pinned) return a.pinned ? -1 : 1;
      return b.updatedAt.compareTo(a.updatedAt);
    });
    return notes;
  }

  @override
  Future<Note?> getById(String id) async {
    final db = _ensure();
    final txn = db.transaction(_storeName, idbModeReadOnly);
    final store = txn.objectStore(_storeName);
    final value = await store.getObject(id);
    await txn.completed;
    if (value == null) return null;
    final map = (value as Map).map((k, v) => MapEntry(k.toString(), v));
    return Note.fromMap(map);
  }

  @override
  Future<void> upsert(Note note) async {
    final db = _ensure();
    final txn = db.transaction(_storeName, idbModeReadWrite);
    final store = txn.objectStore(_storeName);
    await store.put(note.toMap());
    await txn.completed;
  }

  @override
  Future<void> delete(String id) async {
    final db = _ensure();
    final txn = db.transaction(_storeName, idbModeReadWrite);
    final store = txn.objectStore(_storeName);
    await store.delete(id);
    await txn.completed;
  }

  @override
  Future<void> clear() async {
    final db = _ensure();
    final txn = db.transaction(_storeName, idbModeReadWrite);
    final store = txn.objectStore(_storeName);
    await store.clear();
    await txn.completed;
  }

  Database _ensure() {
    final db = _db;
    if (db == null) {
      throw StateError('Database not initialized. Call init() first.');
    }
    return db;
  }
}
