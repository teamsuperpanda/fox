import 'dart:convert';

import 'package:fox/models/folder.dart';
import 'package:fox/models/note.dart';
import 'package:fox/models/settings.dart';

/// Thrown when an export envelope is unreadable, incomplete or from a newer
/// schema than this build understands.
class ExportFormatException implements Exception {
  const ExportFormatException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Versioned JSON envelope shared by export and import.
///
/// The envelope is deliberately dependency free: only `dart:convert` and the
/// data models, so it can be parsed on any platform and unit tested without
/// Flutter plugins.
class FoxExportArchive {
  const FoxExportArchive({
    required this.exportedAt,
    required this.appVersion,
    required this.notes,
    required this.folders,
    required this.settings,
    this.schemaVersion = currentSchemaVersion,
  });

  /// Bump when the on-disk shape changes in a way older builds cannot read.
  static const int currentSchemaVersion = 1;

  /// Identifies the envelope so a random JSON file is rejected clearly.
  static const String formatId = 'fox-backup';

  /// Name of the JSON file inside an export archive.
  static const String jsonFileName = 'fox-backup.json';

  final DateTime exportedAt;
  final String appVersion;
  final List<Note> notes;
  final List<Folder> folders;
  final Settings settings;
  final int schemaVersion;

  Map<String, Object?> toJson() {
    return {
      'format': formatId,
      'schemaVersion': schemaVersion,
      'exportedAt': exportedAt.toUtc().toIso8601String(),
      'appVersion': appVersion,
      'manifest': {
        'notes': notes.length,
        'folders': folders.length,
        'settings': 1,
      },
      'notes': notes.map(noteToJson).toList(growable: false),
      'folders': folders.map(folderToJson).toList(growable: false),
      'settings': settingsToJson(settings),
    };
  }

  String encode() => const JsonEncoder.withIndent('  ').convert(toJson());

  /// Parses and validates an envelope. Throws [ExportFormatException] with a
  /// readable message instead of returning partial data.
  static FoxExportArchive decode(String source) {
    Object? decoded;
    try {
      decoded = jsonDecode(source);
    } on FormatException catch (e) {
      throw ExportFormatException('Not a valid JSON file: ${e.message}');
    }
    if (decoded is! Map<String, dynamic>) {
      throw const ExportFormatException('Backup is not a JSON object.');
    }
    return fromJson(decoded);
  }

  static FoxExportArchive fromJson(Map<String, dynamic> json) {
    final format = json['format'];
    if (format != formatId) {
      throw const ExportFormatException(
        'This file is not a Fox backup (missing "format": "fox-backup").',
      );
    }

    final version = json['schemaVersion'];
    if (version is! int) {
      throw const ExportFormatException('Backup has no numeric schemaVersion.');
    }
    if (version > currentSchemaVersion) {
      throw ExportFormatException(
        'Backup uses schema version $version but this version of Fox only '
        'reads up to $currentSchemaVersion. Update Fox and try again.',
      );
    }
    if (version < 1) {
      throw ExportFormatException(
          'Unsupported backup schema version $version.');
    }

    final exportedAt = _parseDate(json['exportedAt'], 'exportedAt');
    final appVersion = _stringOr(json['appVersion'], 'unknown');

    final rawNotes = json['notes'];
    if (rawNotes is! List) {
      throw const ExportFormatException('Backup has no notes list.');
    }
    final notes = <Note>[
      for (var i = 0; i < rawNotes.length; i++)
        _noteFromJson(rawNotes[i], 'notes[$i]'),
    ];

    final rawFolders = json['folders'];
    if (rawFolders is! List) {
      throw const ExportFormatException('Backup has no folders list.');
    }
    final folders = <Folder>[
      for (var i = 0; i < rawFolders.length; i++)
        _folderFromJson(rawFolders[i], 'folders[$i]'),
    ];

    final rawSettings = json['settings'];
    final settings = rawSettings is Map<String, dynamic>
        ? _settingsFromJson(rawSettings)
        : Settings(themeMode: 'system');

    // A manifest that disagrees with the payload means a truncated export.
    final manifest = json['manifest'];
    if (manifest is Map) {
      final expectedNotes = manifest['notes'];
      final expectedFolders = manifest['folders'];
      if (expectedNotes is int && expectedNotes != notes.length) {
        throw ExportFormatException(
          'Backup is incomplete: manifest lists $expectedNotes notes but '
          '${notes.length} were found.',
        );
      }
      if (expectedFolders is int && expectedFolders != folders.length) {
        throw ExportFormatException(
          'Backup is incomplete: manifest lists $expectedFolders folders but '
          '${folders.length} were found.',
        );
      }
    }

    return FoxExportArchive(
      exportedAt: exportedAt,
      appVersion: appVersion,
      notes: notes,
      folders: folders,
      settings: settings,
      schemaVersion: version,
    );
  }

  static Map<String, Object?> noteToJson(Note note) {
    return {
      'id': note.id,
      'title': note.title,
      'content': note.content,
      'pinned': note.pinned,
      'updatedAt': note.updatedAt.toUtc().toIso8601String(),
      'tags': note.tags,
      'folderId': note.folderId,
      'color': note.color,
    };
  }

  static Map<String, Object?> folderToJson(Folder folder) {
    return {
      'id': folder.id,
      'name': folder.name,
      'createdAt': folder.createdAt.toUtc().toIso8601String(),
    };
  }

  static Map<String, Object?> settingsToJson(Settings settings) {
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

  static Note _noteFromJson(Object? value, String path) {
    if (value is! Map<String, dynamic>) {
      throw ExportFormatException('$path is not an object.');
    }
    final id = value['id'];
    if (id is! String || id.isEmpty) {
      throw ExportFormatException('$path has no id.');
    }
    final tags = value['tags'];
    return Note(
      id: id,
      title: _stringOr(value['title'], ''),
      content: _stringOr(value['content'], ''),
      pinned: value['pinned'] == true,
      updatedAt: _parseDate(value['updatedAt'], '$path.updatedAt'),
      tags: tags is List
          ? tags.whereType<String>().toList(growable: false)
          : const [],
      folderId:
          value['folderId'] is String ? value['folderId'] as String : null,
      color: value['color'] is String ? value['color'] as String : null,
    );
  }

  static Folder _folderFromJson(Object? value, String path) {
    if (value is! Map<String, dynamic>) {
      throw ExportFormatException('$path is not an object.');
    }
    final id = value['id'];
    final name = value['name'];
    if (id is! String || id.isEmpty) {
      throw ExportFormatException('$path has no id.');
    }
    if (name is! String || name.trim().isEmpty) {
      throw ExportFormatException('$path has no name.');
    }
    return Folder(
      id: id,
      name: name,
      createdAt: _parseDate(value['createdAt'], '$path.createdAt'),
    );
  }

  static Settings _settingsFromJson(Map<String, dynamic> value) {
    final themeMode = value['themeMode'];
    return Settings(
      themeMode: themeMode is String ? themeMode : 'system',
      locale: value['locale'] is String ? value['locale'] as String : null,
      showTags: value['showTags'] != false,
      showContent: value['showContent'] != false,
      alternatingColors: value['alternatingColors'] == true,
      fabAnimation: value['fabAnimation'] != false,
      sortBy:
          value['sortBy'] is String ? value['sortBy'] as String : 'dateDesc',
      accentColor: value['accentColor'] is String
          ? value['accentColor'] as String
          : null,
    );
  }

  static String _stringOr(Object? value, String fallback) =>
      value is String ? value : fallback;

  static DateTime _parseDate(Object? value, String path) {
    if (value is! String) {
      throw ExportFormatException('$path is not an ISO-8601 date string.');
    }
    final parsed = DateTime.tryParse(value);
    if (parsed == null) {
      throw ExportFormatException('$path is not a valid date: "$value".');
    }
    return parsed;
  }
}
