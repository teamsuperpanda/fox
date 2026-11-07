import 'package:flutter/foundation.dart';
import 'package:fox/models/folder.dart';
import 'package:fox/models/folder_adapter.dart';
import 'package:fox/models/note.dart';
import 'package:fox/models/note_adapter.dart';
import 'package:fox/models/settings.dart';
import 'package:fox/models/settings_adapter.dart';
import 'package:fox/services/box_names.dart';
import 'package:hive_flutter/hive_flutter.dart';

class StorageService {
  static bool _inited = false;

  /// Whether [init] has completed successfully.
  static bool get isInitialised => _inited;

  /// Initialize Hive, register adapters, and open core boxes.
  ///
  /// Notes and folders are opened first because they hold the user's data;
  /// a failure to open settings falls back to in-memory defaults instead of
  /// blocking startup. A failure anywhere leaves the service uninitialised so
  /// [init] can be retried without restarting the process.
  ///
  /// [initFlutter] exists so tests can point Hive at a temporary directory
  /// without the path_provider platform plugin.
  static Future<void> init({Future<void> Function()? initFlutter}) async {
    if (_inited) return;
    try {
      await (initFlutter ?? Hive.initFlutter)();

      if (!Hive.isAdapterRegistered(2)) {
        Hive.registerAdapter(SettingsAdapter());
      }
      if (!Hive.isAdapterRegistered(3)) {
        Hive.registerAdapter(NoteAdapter());
      }
      if (!Hive.isAdapterRegistered(4)) {
        Hive.registerAdapter(FolderAdapter());
      }

      await Hive.openBox<Note>(BoxNames.notes);
      await Hive.openBox<Folder>(BoxNames.folders);

      // Settings are not user data: a broken settings box must not stop the
      // app from opening. SettingsService falls back to defaults when the box
      // is unavailable.
      try {
        await Hive.openBox<Settings>(BoxNames.settings);
      } catch (e) {
        debugPrint(
            'StorageService: settings box unavailable, using defaults: $e');
      }

      _inited = true;
    } catch (e) {
      _inited = false;
      rethrow;
    }
  }

  /// Allows a retry after a failed [init] or a fresh start in tests.
  @visibleForTesting
  static void reset() {
    _inited = false;
  }
}
