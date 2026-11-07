import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:fox/models/note_content.dart';

/// Encodes and decodes note content.
///
/// This is the only module outside the editor page that imports
/// `flutter_quill`, so a Quill upgrade is confined to this file and
/// `note_detail_page.dart`, and the stored Delta JSON format does not change.
///
/// Upgrade procedure: bump `flutter_quill` in `pubspec.yaml`, run the app
/// check (`flutter analyze`), then this codec's tests. If the library's
/// `Document` or `QuillController` API moved, only this file and the editor
/// page need edits; `Note`, `NotesController` and the repository stay put.
class NoteContentCodec {
  const NoteContentCodec();

  /// Converts an editor document into storable content.
  NoteContent fromDocument(Document document) => NoteContent(
        deltaJson: jsonEncode(document.toDelta().toJson()),
        plainText: document.toPlainText(),
      );

  /// Decodes stored Delta JSON into a document.
  ///
  /// Empty, truncated, malformed or unknown-embed payloads fall back to an
  /// empty document instead of throwing.
  Document toDocument(String deltaJson) {
    final ops = _decodeOps(deltaJson);
    if (ops.isEmpty) return Document();
    try {
      return Document.fromJson(ops);
    } catch (_) {
      return Document();
    }
  }

  /// Extracts plain text from stored Delta JSON.
  String plainTextOf(String deltaJson) {
    final ops = _decodeOps(deltaJson);
    if (ops.isEmpty) return '';
    try {
      return Document.fromJson(ops).toPlainText();
    } catch (_) {
      return '';
    }
  }

  static List<dynamic> _decodeOps(String content) {
    if (content.isEmpty) return const [];
    try {
      final decoded = jsonDecode(content);
      final ops = decoded is Map ? decoded['ops'] ?? [] : decoded;
      return ops is List ? ops : const [];
    } catch (_) {
      return const [];
    }
  }
}

/// Localizations flutter_quill needs at app level, exposed here so `main.dart`
/// does not import the editor package directly.
const List<LocalizationsDelegate<dynamic>> quillLocalizationsDelegates = [
  FlutterQuillLocalizations.delegate,
];

List<Locale> get quillSupportedLocales =>
    FlutterQuillLocalizations.supportedLocales;
