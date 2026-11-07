import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';
import 'package:fox/models/folder.dart';
import 'package:fox/models/note.dart';
import 'package:fox/models/settings.dart';
import 'package:fox/services/export/export_codec.dart';
import 'package:fox/services/export/export_encryption.dart';
import 'package:fox/services/export/markdown_codec.dart';

/// App version written into an export envelope. Kept in sync with
/// `pubspec.yaml`; the envelope is versioned separately by schemaVersion.
const String foxAppVersion = '2.1.1+20';

/// Raised when an export cannot be written.
class ExportException implements Exception {
  const ExportException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// A single progress tick while an export is running.
@immutable
class ExportProgress {
  const ExportProgress({
    required this.completed,
    required this.total,
    required this.stage,
  });

  final int completed;
  final int total;
  final String stage;

  double get fraction => total == 0 ? 1 : completed / total;
}

/// Result of a completed export.
@immutable
class ExportResult {
  const ExportResult({
    required this.archive,
    required this.noteCount,
    required this.folderCount,
    required this.bytes,
    this.encrypted = false,
  });

  /// The `.zip` (or `.foxenc`) file written on disk.
  final File archive;
  final int noteCount;
  final int folderCount;

  /// Raw bytes of the archive, already on disk.
  final Uint8List bytes;

  /// Whether a passphrase was used.
  final bool encrypted;
}

/// Builds a Fox export archive: `fox-backup.json`, a Markdown tree and a
/// README, zipped together. Read-only with respect to the source notes.
class FoxExporter {
  FoxExporter({
    DateTime Function()? clock,
    this.appVersion = foxAppVersion,
  }) : _clock = clock ?? DateTime.now;

  final DateTime Function() _clock;
  final String appVersion;

  /// Writes `fox-export-YYYYMMDD-HHMM.zip` into [outputDirectory].
  ///
  /// When [passphrase] is set the zip bytes are wrapped in a passphrase
  /// encrypted container and written as `.foxenc` instead. The passphrase is
  /// not stored: losing it means losing the backup.
  Future<ExportResult> export({
    required List<Note> notes,
    required List<Folder> folders,
    required Settings settings,
    required Directory outputDirectory,
    String? passphrase,
    ExportEncryption? encryption,
    ValueChanged<ExportProgress>? onProgress,
  }) async {
    if (!outputDirectory.existsSync()) {
      await outputDirectory.create(recursive: true);
    }

    final now = _clock();
    final baseName = 'fox-export-${_stamp(now)}';
    final archiveFiles = <ArchiveFile>[];

    final folderNames = <String, String>{
      for (final folder in folders) folder.id: folder.name,
    };

    final envelope = FoxExportArchive(
      exportedAt: now,
      appVersion: appVersion,
      notes: notes,
      folders: folders,
      settings: settings,
    );
    archiveFiles.add(
      ArchiveFile.string(
        FoxExportArchive.jsonFileName,
        envelope.encode(),
      ),
    );

    onProgress?.call(
      ExportProgress(completed: 0, total: notes.length, stage: 'markdown'),
    );

    final usedNames = <String>{};
    for (var i = 0; i < notes.length; i++) {
      final note = notes[i];
      final folderName = folderNames[note.folderId];
      final directory = folderName == null
          ? 'markdown/Unfiled'
          : 'markdown/${_safeSegment(folderName)}';
      final fileName = MarkdownCodec.safeFileName(note.title);
      var candidate = '$directory/$fileName.md';
      var suffix = 2;
      while (!usedNames.add(candidate)) {
        candidate = '$directory/$fileName ($suffix).md';
        suffix++;
      }
      archiveFiles.add(
        ArchiveFile.string(
          candidate,
          MarkdownCodec.noteToMarkdown(note, folderName: folderName),
        ),
      );
      if (i % 25 == 0 || i == notes.length - 1) {
        onProgress?.call(
          ExportProgress(
            completed: i + 1,
            total: notes.length,
            stage: 'markdown',
          ),
        );
      }
    }

    archiveFiles.add(
      ArchiveFile.string(
        'README.txt',
        _readme(now: now, notes: notes.length, folders: folders.length),
      ),
    );

    onProgress?.call(
      ExportProgress(
          completed: notes.length, total: notes.length, stage: 'zip'),
    );

    final archive = Archive();
    archiveFiles.forEach(archive.add);
    final zipBytes = ZipEncoder().encodeBytes(archive);

    final encrypted = passphrase != null && passphrase.isNotEmpty;
    final bytes = encrypted
        ? await (encryption ?? ExportEncryption()).encrypt(
            bytes: zipBytes,
            passphrase: passphrase,
          )
        : zipBytes;
    final extension = encrypted ? ExportEncryption.fileExtension : 'zip';
    final file = File('${outputDirectory.path}/$baseName.$extension');
    await file.writeAsBytes(bytes, flush: true);

    onProgress?.call(
      ExportProgress(
        completed: notes.length,
        total: notes.length,
        stage: 'done',
      ),
    );

    return ExportResult(
      archive: file,
      noteCount: notes.length,
      folderCount: folders.length,
      bytes: bytes,
      encrypted: encrypted,
    );
  }

  static String _stamp(DateTime time) {
    String two(int value) => value.toString().padLeft(2, '0');
    return '${time.year}${two(time.month)}${two(time.day)}'
        '-${two(time.hour)}${two(time.minute)}';
  }

  static String _safeSegment(String value) {
    final safe = MarkdownCodec.safeFileName(value, fallback: 'Unfiled');
    return safe;
  }

  static String _readme({
    required DateTime now,
    required int notes,
    required int folders,
  }) {
    return '''
Fox export
==========
Created: ${now.toUtc().toIso8601String()}
Notes: $notes
Folders: $folders

Contents
--------
fox-backup.json
  Full, versioned backup. Import this file in Fox to restore everything.
  schemaVersion ${FoxExportArchive.currentSchemaVersion}: format
  "fox-backup", exportedAt, appVersion, manifest counts, notes, folders
  and settings. Newer schema versions are refused by older app builds.

markdown/
  One Markdown file per note, grouped by folder ("Unfiled" when a note has
  no folder). Each file starts with YAML front matter: id, title, updatedAt,
  pinned, optional tags, color and folder. The body is rendered from the
  note's rich text. These files open in Obsidian, Finder or any editor
  without Fox.

Import
------
In Fox, open View options, choose Import, and pick fox-backup.json or a
.zip of this export. Notes are merged by id; folders are matched by name.
A local backup is written automatically before anything is imported.

Your data is yours: this export is a copy. The app's own data is untouched.
''';
  }
}

/// Exposed for tests that inspect the generated Markdown tree without a zip.
@visibleForTesting
String encodeEnvelope(FoxExportArchive archive) => archive.encode();

/// Exposed for tests that need the README text.
@visibleForTesting
String buildReadme(DateTime now, int notes, int folders) => FoxExporter._readme(
      now: now,
      notes: notes,
      folders: folders,
    );
