import 'package:flutter/foundation.dart';
import 'package:fox/models/folder.dart';
import 'package:fox/models/folder_adapter.dart';
import 'package:fox/models/note.dart';
import 'package:fox/models/note_adapter.dart';
import 'package:fox/models/settings.dart';
import 'package:fox/models/settings_adapter.dart';
import 'package:fox/services/box_names.dart';
import 'package:fox/services/schema_migrations.dart';
import 'package:hive_flutter/hive_flutter.dart';

class StorageService {
  static bool _inited = false;

  /// Initialize Hive, register adapters, open the boxes and run migrations.
  ///
  /// Throws [SchemaMigrationException] when the boxes cannot be brought up to
  /// [currentSchemaVersion]; the caller shows the recovery screen in that case.
  static Future<void> init() async {
    if (_inited) return;
    await Hive.initFlutter();
    await openBoxes();
    _inited = true;
  }

  /// Registers the adapters and opens every box, running ordered migrations.
  ///
  /// Exposed so tests can drive it against a fixture directory without
  /// `Hive.initFlutter`, which needs platform plugins.
  @visibleForTesting
  static Future<void> openBoxes({
    int targetVersion = currentSchemaVersion,
    Map<int, SchemaStep>? migrations,
  }) async {
    registerAdapters();

    final schemaBox = await Hive.openBox<int>(BoxNames.schema);
    final notesBox = await Hive.openBox<Note>(BoxNames.notes);
    final foldersBox = await Hive.openBox<Folder>(BoxNames.folders);
    final settingsBox = await Hive.openBox<Settings>(BoxNames.settings);

    final storedVersion =
        schemaBox.get(schemaVersionKey) ?? legacySchemaVersion;
    await runSchemaMigrations(
      from: storedVersion,
      to: targetVersion,
      boxes: SchemaBoxes(
        notes: notesBox,
        folders: foldersBox,
        settings: settingsBox,
      ),
      migrations: migrations,
    );
    await schemaBox.put(schemaVersionKey, targetVersion);
  }

  static void registerAdapters() {
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(SettingsAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(NoteAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(FolderAdapter());
    }
  }

  /// Closes Hive so a failed startup can be retried from a clean slate.
  static Future<void> reset() async {
    _inited = false;
    await Hive.close();
  }
}
