import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:fox/l10n/app_localizations.dart';
import 'package:fox/models/folder.dart';
import 'package:fox/models/note.dart';
import 'package:fox/models/settings.dart';
import 'package:fox/models/settings_adapter.dart';
import 'package:fox/providers/locale_provider.dart';
import 'package:fox/providers/theme_provider.dart';
import 'package:fox/services/box_names.dart';
import 'package:fox/services/repository_hive.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

Widget buildTestApp(
  Widget child, {
  ThemeMode themeMode = ThemeMode.system,
  Locale? locale,
  ThemeData? theme,
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: ThemeProvider()),
      ChangeNotifierProvider.value(value: LocaleProvider()),
    ],
    child: MaterialApp(
      localizationsDelegates: const [
        ...AppLocalizations.localizationsDelegates,
        FlutterQuillLocalizations.delegate,
      ],
      supportedLocales: [
        ...AppLocalizations.supportedLocales,
        ...FlutterQuillLocalizations.supportedLocales,
      ],
      locale: locale,
      themeMode: themeMode,
      theme: theme,
      home: child,
    ),
  );
}

Future<void> hiveTestSetup(String dir) async {
  Hive.init(dir);
  if (!Hive.isAdapterRegistered(2)) {
    Hive.registerAdapter(SettingsAdapter());
  }
  await Hive.openBox<Settings>(BoxNames.settings);
  await Hive.box<Settings>(BoxNames.settings).clear();
}

Future<void> hiveTestTeardown() async {
  await Hive.close();
  await Hive.deleteFromDisk();
}

Note makeNote({
  String id = '1',
  String title = 'Test Note',
  String content = '{}',
  bool pinned = false,
  DateTime? updatedAt,
  List<String> tags = const [],
  String? folderId,
  String? color,
}) {
  return Note(
    id: id,
    title: title,
    content: content,
    pinned: pinned,
    updatedAt: updatedAt ?? DateTime.now(),
    tags: tags,
    folderId: folderId,
    color: color,
  );
}

class MemoryRepo implements NoteAndFolderRepository {
  final List<Note> _data = [];
  final List<Folder> _folders = [];
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
  Future<List<Folder>> getAllFolders() async => List.unmodifiable(_folders);

  @override
  Future<void> upsertFolder(Folder folder) async {
    _folders.removeWhere((f) => f.id == folder.id);
    _folders.add(folder);
  }

  @override
  Future<void> deleteFolder(String id) async {
    _folders.removeWhere((f) => f.id == id);
  }

  Future<void> addFolder(String name) async {
    await upsertFolder(Folder(
      id: 'folder-${_folders.length + 1}',
      name: name,
      createdAt: DateTime.now(),
    ));
  }

  Future<void> renameFolder(String id, String newName) async {
    for (final folder in _folders) {
      if (folder.id == id) {
        await upsertFolder(folder.copyWith(name: newName));
        return;
      }
    }
  }
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
