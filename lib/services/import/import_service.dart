import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:collection/collection.dart';
import 'package:fox/models/folder.dart';
import 'package:fox/models/note.dart';
import 'package:fox/models/settings.dart';
import 'package:fox/services/export/export_codec.dart';
import 'package:fox/services/export/export_service.dart';
import 'package:fox/services/export/markdown_codec.dart';
import 'package:fox/services/repository_hive.dart';
import 'package:uuid/uuid.dart';

/// Thrown when an import cannot be parsed or validated. Nothing is written
/// when this is thrown: validation always completes before [FoxImporter.apply].
class ImportException implements Exception {
  const ImportException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// One file selected for import. Decoupled from the file picker so the
/// service can be tested with in-memory bytes.
class ImportFile {
  const ImportFile({required this.name, required this.bytes});

  final String name;
  final Uint8List bytes;

  String get lowerName => name.toLowerCase();
}

/// A validated, not yet applied import.
class ImportPlan {
  const ImportPlan({
    required this.notesToAdd,
    required this.notesToUpdate,
    required this.foldersToAdd,
    required this.skippedNotes,
    required this.warnings,
  });

  final List<Note> notesToAdd;
  final List<Note> notesToUpdate;
  final List<Folder> foldersToAdd;
  final int skippedNotes;
  final List<String> warnings;

  int get addedCount => notesToAdd.length;
  int get updatedCount => notesToUpdate.length;
  bool get hasChanges =>
      notesToAdd.isNotEmpty ||
      notesToUpdate.isNotEmpty ||
      foldersToAdd.isNotEmpty;
}

/// Outcome of an applied import.
class ImportResult {
  const ImportResult({
    required this.added,
    required this.updated,
    required this.skipped,
    required this.foldersAdded,
    this.backupPath,
  });

  final int added;
  final int updated;
  final int skipped;
  final int foldersAdded;
  final String? backupPath;

  bool get changed => added > 0 || updated > 0 || foldersAdded > 0;
}

/// Reads Fox exports (zip or JSON), Markdown and plain text, and merges them
/// into an existing library without silently overwriting newer notes.
class FoxImporter {
  FoxImporter({Uuid? uuid, DateTime Function()? clock})
      : _uuid = uuid ?? const Uuid(),
        _clock = clock ?? DateTime.now;

  final Uuid _uuid;
  final DateTime Function() _clock;

  static const _textExtensions = {'.md', '.markdown', '.txt'};

  /// Parses [bytes] into a plan. Throws [ImportException] on any invalid
  /// input; no partial plan is ever returned.
  ImportPlan previewBytes({
    required String source,
    required Uint8List bytes,
    required List<Note> existingNotes,
    required List<Folder> existingFolders,
  }) {
    if (bytes.isEmpty) {
      throw const ImportException('The selected file is empty.');
    }

    if (_looksLikeZip(bytes)) {
      final entries = _readZip(source, bytes);
      final envelopeBytes = entries[FoxExportArchive.jsonFileName];
      if (envelopeBytes != null) {
        return _planFromEnvelope(
          _decodeEnvelope(source, envelopeBytes),
          existingNotes,
          existingFolders,
        );
      }
      final textEntries = <ImportFile>[];
      for (final entry in entries.entries) {
        if (_isTextFile(entry.key)) {
          textEntries.add(ImportFile(name: entry.key, bytes: entry.value));
        }
      }
      if (textEntries.isEmpty) {
        throw const ImportException(
          'This zip has no fox-backup.json and no Markdown or text files.',
        );
      }
      return _planFromText(textEntries, existingNotes, existingFolders);
    }

    final text = _decodeText(source, bytes);
    if (_looksLikeJson(source, text)) {
      return _planFromEnvelope(
        _decodeEnvelope(source, bytes),
        existingNotes,
        existingFolders,
      );
    }
    return _planFromText(
      [ImportFile(name: source, bytes: bytes)],
      existingNotes,
      existingFolders,
    );
  }

  /// Parses several files (for example a picked folder) into one plan.
  ImportPlan previewFiles({
    required List<ImportFile> files,
    required List<Note> existingNotes,
    required List<Folder> existingFolders,
  }) {
    if (files.isEmpty) {
      throw const ImportException('No files were selected.');
    }
    if (files.length == 1) {
      final file = files.single;
      return previewBytes(
        source: file.name,
        bytes: file.bytes,
        existingNotes: existingNotes,
        existingFolders: existingFolders,
      );
    }
    for (final file in files) {
      if (file.lowerName.endsWith('.json') ||
          _looksLikeZip(file.bytes) ||
          file.lowerName.endsWith('.zip')) {
        throw const ImportException(
          'Import a backup on its own, not together with other files.',
        );
      }
    }
    return _planFromText(files, existingNotes, existingFolders);
  }

  /// Writes a full backup of the current library, then applies [plan].
  ///
  /// If the backup cannot be written nothing is mutated.
  Future<ImportResult> apply({
    required ImportPlan plan,
    required NoteAndFolderRepository repository,
    required Directory backupDirectory,
    required Settings settings,
  }) async {
    if (!plan.hasChanges) {
      return ImportResult(
        added: 0,
        updated: 0,
        skipped: plan.skippedNotes,
        foldersAdded: 0,
      );
    }

    final backup = await _writeBackup(repository, backupDirectory, settings);

    for (final folder in plan.foldersToAdd) {
      await repository.upsertFolder(folder);
    }
    final notes = [...plan.notesToAdd, ...plan.notesToUpdate];
    await repository.upsertAll(notes);

    return ImportResult(
      added: plan.notesToAdd.length,
      updated: plan.notesToUpdate.length,
      skipped: plan.skippedNotes,
      foldersAdded: plan.foldersToAdd.length,
      backupPath: backup.path,
    );
  }

  Future<File> _writeBackup(
    NoteAndFolderRepository repository,
    Directory directory,
    Settings settings,
  ) async {
    final notes = await repository.getAll();
    final folders = await repository.getAllFolders();
    final envelope = FoxExportArchive(
      exportedAt: _clock(),
      appVersion: foxAppVersion,
      notes: notes,
      folders: folders,
      settings: settings,
    );
    try {
      if (!directory.existsSync()) await directory.create(recursive: true);
      final stamp = _stamp(_clock());
      final file = File('${directory.path}/pre-import-$stamp.json');
      await file.writeAsString(envelope.encode(), flush: true);
      return file;
    } on FileSystemException catch (e) {
      throw ImportException(
        'Could not write the pre-import backup, so nothing was imported: '
        '${e.message}',
      );
    }
  }

  ImportPlan _planFromEnvelope(
    FoxExportArchive archive,
    List<Note> existingNotes,
    List<Folder> existingFolders,
  ) {
    final existingById = {for (final note in existingNotes) note.id: note};
    final folderResolution = _FolderResolution(
      existing: existingFolders,
      generatedId: _uuid.v4,
      now: _clock(),
    );

    final deduped = <String, Note>{};
    for (final note in archive.notes) {
      final current = deduped[note.id];
      if (current == null || note.updatedAt.isAfter(current.updatedAt)) {
        deduped[note.id] = note;
      }
    }

    final resolved = deduped.values.map((note) {
      if (note.folderId == null) return note;
      final folderId = folderResolution.resolveEnvelopeFolder(
        note.folderId!,
        archive.folders,
      );
      return folderId == note.folderId
          ? note
          : note.copyWith(folderId: folderId, clearFolder: folderId == null);
    }).toList();

    return _compareWithExisting(
      resolved,
      existingById,
      folderResolution.foldersToAdd,
    );
  }

  ImportPlan _planFromText(
    List<ImportFile> files,
    List<Note> existingNotes,
    List<Folder> existingFolders,
  ) {
    final existingById = {for (final note in existingNotes) note.id: note};
    final folderResolution = _FolderResolution(
      existing: existingFolders,
      generatedId: _uuid.v4,
      now: _clock(),
    );

    final warnings = <String>[];
    final deduped = <String, Note>{};
    var skipped = 0;

    for (final file in files) {
      if (!_isTextFile(file.name)) {
        throw ImportException('${file.name} is not a Markdown or text file.');
      }
      final parsed = _parseTextFile(file, folderResolution);
      if (parsed == null) {
        skipped++;
        warnings.add('Skipped empty file ${file.name}.');
        continue;
      }
      final current = deduped[parsed.id];
      if (current == null || parsed.updatedAt.isAfter(current.updatedAt)) {
        deduped[parsed.id] = parsed;
      }
    }

    final plan = _compareWithExisting(
      deduped.values.toList(),
      existingById,
      folderResolution.foldersToAdd,
    );
    return ImportPlan(
      notesToAdd: plan.notesToAdd,
      notesToUpdate: plan.notesToUpdate,
      foldersToAdd: plan.foldersToAdd,
      skippedNotes: plan.skippedNotes + skipped,
      warnings: [...warnings, ...plan.warnings],
    );
  }

  ImportPlan _compareWithExisting(
    List<Note> imported,
    Map<String, Note> existingById,
    List<Folder> foldersToAdd,
  ) {
    final toAdd = <Note>[];
    final toUpdate = <Note>[];
    var skipped = 0;

    for (final note in imported) {
      final existing = existingById[note.id];
      if (existing == null) {
        toAdd.add(note);
      } else if (note.updatedAt.isAfter(existing.updatedAt)) {
        toUpdate.add(note);
      } else {
        skipped++;
      }
    }

    return ImportPlan(
      notesToAdd: toAdd,
      notesToUpdate: toUpdate,
      foldersToAdd: foldersToAdd,
      skippedNotes: skipped,
      warnings: const [],
    );
  }

  Note? _parseTextFile(ImportFile file, _FolderResolution folders) {
    final text = _decodeText(file.name, file.bytes);
    final parsed = _parseFrontMatter(text);
    final frontMatter = parsed.values;
    final body = parsed.body.trim();
    final frontMatterTitle = (frontMatter['title'] ?? '').trim();

    if (body.isEmpty && frontMatterTitle.isEmpty) return null;

    final title = (frontMatterTitle.isNotEmpty
            ? frontMatterTitle
            : body.isEmpty
                ? _titleFromFileName(file.name)
                : _titleFromBody(body))
        .replaceAll(RegExp(r'^#+\s*'), '')
        .trim();

    final rawTags = frontMatter['tags'];
    final tags = rawTags == null
        ? const <String>[]
        : rawTags
            .replaceAll(RegExp(r'^\[|\]$'), '')
            .split(',')
            .map(_unquote)
            .map((tag) => tag.trim())
            .where((tag) => tag.isNotEmpty)
            .toList(growable: false);

    final folderName = frontMatter['folder']?.trim();
    final folderId = folderName == null || folderName.isEmpty
        ? null
        : folders.resolveByName(folderName);

    final updatedAt = _parseOptionalDate(frontMatter['updatedAt']) ?? _clock();

    return Note(
      id: frontMatter['id'] ?? _uuid.v4(),
      title: title,
      content: MarkdownCodec.plainTextToContent(body),
      pinned: frontMatter['pinned']?.toLowerCase() == 'true',
      updatedAt: updatedAt,
      tags: tags,
      folderId: folderId,
      color: frontMatter['color']?.trim(),
    );
  }

  static String _titleFromBody(String body) {
    for (final line in body.split('\n')) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      return trimmed;
    }
    return '';
  }

  static String _titleFromFileName(String fileName) {
    final base = fileName.split('/').last;
    final dot = base.lastIndexOf('.');
    return dot > 0 ? base.substring(0, dot) : base;
  }

  static DateTime? _parseOptionalDate(String? value) {
    if (value == null || value.isEmpty) return null;
    return DateTime.tryParse(value.trim());
  }

  static _ParsedText _parseFrontMatter(String text) {
    final normalized = text.replaceAll('\r\n', '\n');
    if (!normalized.startsWith('---\n')) {
      return _ParsedText(const {}, normalized);
    }
    final end = normalized.indexOf('\n---', 4);
    if (end < 0) return _ParsedText(const {}, normalized);

    final block = normalized.substring(4, end);
    final bodyStart = normalized.indexOf('\n', end + 1);
    final body = bodyStart < 0 ? '' : normalized.substring(bodyStart + 1);
    final values = <String, String>{};
    for (final line in block.split('\n')) {
      final colon = line.indexOf(':');
      if (colon <= 0) continue;
      final key = line.substring(0, colon).trim();
      final value = line.substring(colon + 1).trim();
      if (key.isEmpty || value.isEmpty) continue;
      values[key] = _unquote(value);
    }
    return _ParsedText(values, body);
  }

  static String _unquote(String value) {
    final trimmed = value.trim();
    if (trimmed.length >= 2 &&
        trimmed.startsWith('"') &&
        trimmed.endsWith('"')) {
      try {
        return jsonDecode(trimmed) as String;
      } on FormatException {
        return trimmed.substring(1, trimmed.length - 1);
      }
    }
    if (trimmed.length >= 2 &&
        trimmed.startsWith("'") &&
        trimmed.endsWith("'")) {
      return trimmed.substring(1, trimmed.length - 1);
    }
    return trimmed;
  }

  static bool _looksLikeZip(Uint8List bytes) =>
      bytes.length > 4 && bytes[0] == 0x50 && bytes[1] == 0x4B;

  static bool _looksLikeJson(String source, String text) {
    if (source.toLowerCase().endsWith('.json')) return true;
    final trimmed = text.trimLeft();
    return trimmed.startsWith('{');
  }

  static bool _isTextFile(String name) {
    final lower = name.toLowerCase();
    return _textExtensions.any(lower.endsWith);
  }

  static String _decodeText(String source, Uint8List bytes) {
    try {
      return utf8.decode(bytes);
    } on FormatException {
      throw ImportException('$source is not valid UTF-8 text.');
    }
  }

  static FoxExportArchive _decodeEnvelope(String source, Uint8List bytes) {
    try {
      return FoxExportArchive.decode(_decodeText(source, bytes));
    } on ExportFormatException catch (e) {
      throw ImportException(e.message);
    }
  }

  static Map<String, Uint8List> _readZip(String source, Uint8List bytes) {
    Archive archive;
    try {
      archive = ZipDecoder().decodeBytes(bytes);
    } on FormatException {
      throw ImportException('$source is not a readable zip archive.');
    } catch (e) {
      throw ImportException(
        '$source could not be opened. If it is an encrypted export, '
        'decrypt it first (encrypted import is not supported yet).',
      );
    }
    final entries = <String, Uint8List>{};
    for (final file in archive) {
      if (!file.isFile) continue;
      final data = file.readBytes();
      if (data != null) entries[file.name] = data;
    }
    return entries;
  }

  static String _stamp(DateTime time) {
    String two(int value) => value.toString().padLeft(2, '0');
    return '${time.year}${two(time.month)}${two(time.day)}'
        '-${two(time.hour)}${two(time.minute)}${two(time.second)}';
  }
}

class _ParsedText {
  const _ParsedText(this.values, this.body);

  final Map<String, String> values;
  final String body;
}

/// Resolves imported folder ids to the local library, matching by id first
/// and then by case-insensitive name.
class _FolderResolution {
  _FolderResolution({
    required List<Folder> existing,
    required String Function() generatedId,
    required DateTime now,
  })  : _generatedId = generatedId,
        _now = now {
    for (final folder in existing) {
      _byId[folder.id] = folder.id;
      _byName.putIfAbsent(_normalize(folder.name), () => folder.id);
    }
  }

  final String Function() _generatedId;
  final DateTime _now;
  final Map<String, String> _byId = {};
  final Map<String, String> _byName = {};
  final List<Folder> foldersToAdd = [];

  String? resolveEnvelopeFolder(String importedId, List<Folder> imported) {
    final resolved = _byId[importedId];
    if (resolved != null) return resolved;

    final folder = imported.firstWhereOrNull((f) => f.id == importedId);
    if (folder == null) return null;

    final byName = _byName[_normalize(folder.name)];
    if (byName != null) {
      _byId[importedId] = byName;
      return byName;
    }

    // Preserve the imported id so a round-trip into an empty library keeps
    // every note field stable.
    foldersToAdd.add(folder);
    _byId[folder.id] = folder.id;
    _byName[_normalize(folder.name)] = folder.id;
    return folder.id;
  }

  String resolveByName(String name) {
    final existing = _byName[_normalize(name)];
    if (existing != null) return existing;

    final folder = Folder(id: _generatedId(), name: name, createdAt: _now);
    foldersToAdd.add(folder);
    _byId[folder.id] = folder.id;
    _byName[_normalize(name)] = folder.id;
    return folder.id;
  }

  static String _normalize(String name) => name.trim().toLowerCase();
}
