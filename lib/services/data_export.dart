import 'dart:convert';

import 'package:fox/models/folder.dart';
import 'package:fox/models/note.dart';
import 'package:fox/models/settings.dart';
import 'package:fox/services/box_names.dart';
import 'package:hive/hive.dart';

/// Builds a best-effort JSON backup of whatever boxes are currently readable.
///
/// Used by the startup failure screen so a user who cannot start the app still
/// has a way to get their notes out. Unreadable or unopened boxes are skipped
/// rather than failing the whole export.
class DataExport {
  DataExport._();

  static String buildBackup() {
    final backup = <String, dynamic>{
      'app': 'fox',
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'notes': _notes(),
      'folders': _folders(),
      'settings': _settings(),
    };
    return const JsonEncoder.withIndent('  ').convert(backup);
  }

  static List<Map<String, Object?>> _notes() {
    if (!Hive.isBoxOpen(BoxNames.notes)) return const [];
    return Hive.box<Note>(BoxNames.notes).values.map((n) => n.toMap()).toList();
  }

  static List<Map<String, Object?>> _folders() {
    if (!Hive.isBoxOpen(BoxNames.folders)) return const [];
    return Hive.box<Folder>(BoxNames.folders)
        .values
        .map(
          (f) => {
            'id': f.id,
            'name': f.name,
            'createdAt': f.createdAt.millisecondsSinceEpoch,
          },
        )
        .toList();
  }

  static Map<String, Object?>? _settings() {
    if (!Hive.isBoxOpen(BoxNames.settings)) return null;
    final box = Hive.box<Settings>(BoxNames.settings);
    if (box.isEmpty) return null;
    final settings = box.values.first;
    return {
      'themeMode': settings.themeMode,
      'locale': settings.locale,
      'showTags': settings.showTags,
      'showContent': settings.showContent,
      'alternatingColors': settings.alternatingColors,
      'fabAnimation': settings.fabAnimation,
      'sortBy': settings.sortBy,
      'accentColor': settings.accentColor,
    };
  }
}
