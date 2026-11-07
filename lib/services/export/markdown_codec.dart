import 'dart:convert';

import 'package:fox/models/note.dart';

/// Converts between a [Note] and the Markdown representation used by exports.
///
/// The Markdown is intentionally plain: YAML front matter followed by the
/// note body rendered from the Quill Delta. It opens fine in Obsidian, Finder
/// or any text editor with no Fox installed.
class MarkdownCodec {
  MarkdownCodec._();

  /// Renders [note] as Markdown with front matter.
  ///
  /// [folderName] is the folder's display name, or null for unfiled notes.
  static String noteToMarkdown(Note note, {String? folderName}) {
    final buffer = StringBuffer()
      ..writeln('---')
      ..writeln('id: ${_yamlString(note.id)}')
      ..writeln('title: ${_yamlString(note.title)}')
      ..writeln(
        'updatedAt: ${_yamlString(note.updatedAt.toUtc().toIso8601String())}',
      )
      ..writeln('pinned: ${note.pinned}');
    if (note.tags.isNotEmpty) {
      buffer.writeln(
        'tags: [${note.tags.map(_yamlString).join(', ')}]',
      );
    }
    if (note.color != null) {
      buffer.writeln('color: ${_yamlString(note.color!)}');
    }
    if (folderName != null) {
      buffer.writeln('folder: ${_yamlString(folderName)}');
    }
    buffer
      ..writeln('---')
      ..writeln();

    final body = deltaToMarkdown(note);
    buffer.write(body.isEmpty ? _fallbackBody(note) : body);
    return buffer.toString();
  }

  /// Renders a note's Delta as Markdown, without front matter.
  static String deltaToMarkdown(Note note) {
    final ops = _decodeOps(note.content);
    if (ops.isEmpty) return '';

    final lines = <String>[];
    var current = StringBuffer();
    var blockAttributes = const <String, Object?>{};

    for (final op in ops) {
      if (op is! Map) continue;
      final insert = op['insert'];
      if (insert is! String) continue; // Embedded objects are not exported.
      final attributes = op['attributes'];
      final attrs = attributes is Map
          ? attributes.cast<String, Object?>()
          : const <String, Object?>{};

      final segments = insert.split('\n');
      for (var i = 0; i < segments.length; i++) {
        if (i > 0) {
          // Quill normally stores line attributes on the newline op, but some
          // documents carry them on the text op instead.
          final lineAttributes =
              _hasBlockAttributes(attrs) ? attrs : blockAttributes;
          lines.add(_renderLine(current.toString(), lineAttributes));
          current = StringBuffer();
          blockAttributes = const <String, Object?>{};
        } else if (current.isEmpty && _hasBlockAttributes(attrs)) {
          blockAttributes = attrs;
        }
        if (segments[i].isNotEmpty) {
          current.write(_inline(segments[i], attrs));
        }
      }
    }
    if (current.isNotEmpty) {
      lines.add(_renderLine(current.toString(), blockAttributes));
    }

    while (lines.isNotEmpty && lines.last.trim().isEmpty) {
      lines.removeLast();
    }
    return lines.join('\n');
  }

  /// Converts plain text (Markdown or `.txt`) into Quill Delta JSON.
  static String plainTextToContent(String text) {
    final normalized = text.replaceAll('\r\n', '\n');
    final ops = <Map<String, Object?>>[];
    final lines = normalized.split('\n');
    for (var i = 0; i < lines.length; i++) {
      if (lines[i].isNotEmpty) ops.add({'insert': lines[i]});
      if (i < lines.length - 1) ops.add({'insert': '\n'});
    }
    if (ops.isEmpty) ops.add({'insert': '\n'});
    return jsonEncode(ops);
  }

  /// Turns a note title into a safe cross-platform file name.
  static String safeFileName(String title, {String fallback = 'Untitled'}) {
    var name = title
        .replaceAll(RegExp(r'[\\/:*?"<>|\x00-\x1F]'), '-')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    // A leading dot hides the file on Unix, a trailing dot breaks Windows.
    name = name.replaceAll(RegExp(r'^[.]+|[.]+$'), '').trim();
    if (name.isEmpty) name = fallback;
    if (name.length > 80) {
      name = name.substring(0, 80).trim();
      if (name.isEmpty) name = fallback;
    }
    return name;
  }

  static bool _hasBlockAttributes(Map<String, Object?> attributes) {
    return attributes['header'] != null ||
        attributes['list'] != null ||
        attributes['blockquote'] == true ||
        attributes['code-block'] == true;
  }

  static String _renderLine(String text, Map<String, Object?> attributes) {
    if (text.isEmpty) return '';
    final header = attributes['header'];
    if (header is int && header > 0 && header <= 6) {
      return '${'#' * header} $text';
    }
    if (attributes['code-block'] == true) {
      return '    $text';
    }
    final quote = attributes['blockquote'] == true;
    final list = attributes['list'];
    final prefix = switch (list) {
      'ordered' => '1. ',
      'bullet' || 'checked' || 'unchecked' => '- ',
      _ => '',
    };
    if (quote) return '> $prefix$text';
    return '$prefix$text';
  }

  static String _inline(String text, Map<String, Object?> attributes) {
    var result = text;
    if (attributes['code'] == true) return '`$result`';
    if (attributes['bold'] == true) result = '**$result**';
    if (attributes['italic'] == true) result = '*$result*';
    if (attributes['strike'] == true) result = '~~$result~~';
    if (attributes['underline'] == true) result = '<u>$result</u>';
    final link = attributes['link'];
    if (link is String && link.isNotEmpty) result = '[$result]($link)';
    return result;
  }

  static String _fallbackBody(Note note) {
    final plain = note.plainText.trim();
    return plain.isEmpty ? '' : '$plain\n';
  }

  static String _yamlString(String value) => jsonEncode(value);

  static List<dynamic> _decodeOps(String content) {
    if (content.isEmpty) return const [];
    try {
      final decoded = jsonDecode(content);
      final ops = decoded is Map ? decoded['ops'] : decoded;
      return ops is List ? ops : const [];
    } on FormatException {
      return const [];
    }
  }
}
