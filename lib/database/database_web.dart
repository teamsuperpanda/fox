import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:fox/models/note.dart';

class AppDatabase {
  static final AppDatabase _instance = AppDatabase._internal();
  static SharedPreferences? _prefs;

  factory AppDatabase() {
    return _instance;
  }

  AppDatabase._internal();

  Future<SharedPreferences> get database async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<void> insertNote(Note note) async {
    final prefs = await database;
    List<String> notesJson = prefs.getStringList('notes') ?? [];
    note.id ??= notesJson.isNotEmpty ? (jsonDecode(notesJson.last)['id'] ?? 0) + 1 : 1;
    notesJson.add(jsonEncode(note.toMap()));
    await prefs.setStringList('notes', notesJson);
  }

  Future<List<Note>> getAllNotes() async {
    final prefs = await database;
    List<String> notesJson = prefs.getStringList('notes') ?? [];
    return notesJson.map((json) => Note.fromMap(jsonDecode(json))).toList();
  }

  Future<void> updateNote(Note note) async {
    final prefs = await database;
    List<String> notesJson = prefs.getStringList('notes') ?? [];
    int index = notesJson.indexWhere((json) => jsonDecode(json)['id'] == note.id);
    if (index != -1) {
      notesJson[index] = jsonEncode(note.toMap());
      await prefs.setStringList('notes', notesJson);
    }
  }

  Future<void> deleteNote(int id) async {
    final prefs = await database;
    List<String> notesJson = prefs.getStringList('notes') ?? [];
    notesJson.removeWhere((json) => jsonDecode(json)['id'] == id);
    await prefs.setStringList('notes', notesJson);
  }
}