import 'dart:convert';
import 'dart:ui';

import 'package:fox/models/note.dart';
import 'package:share_plus/share_plus.dart';

enum NoteExportFormat {
  markdown,
  plainText,
  html;

  String get extension => switch (this) {
        NoteExportFormat.markdown => 'md',
        NoteExportFormat.plainText => 'txt',
        NoteExportFormat.html => 'html',
      };

  String get mimeType => switch (this) {
        NoteExportFormat.markdown => 'text/markdown',
        NoteExportFormat.plainText => 'text/plain',
        NoteExportFormat.html => 'text/html',
      };
}

/// Renders a note in [format]. The conversion is pure so it can be reused by
/// the import path and unit tested without a platform channel.
String exportNote(Note note, NoteExportFormat format) {
  return switch (format) {
    NoteExportFormat.markdown => _noteToMarkdown(note),
    NoteExportFormat.plainText => _noteToPlainText(note),
    NoteExportFormat.html => _noteToHtml(note),
  };
}

/// Filename safe on Android and iOS, derived from the note title.
String noteExportFileName(String title, NoteExportFormat format) {
  var base = title
      .trim()
      .replaceAll(RegExp(r'[\x00-\x1F<>:"/\\|?*]'), '')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim()
      .replaceAll(RegExp(r'[. ]+$'), '');
  if (base.isEmpty) base = 'note';
  if (base.length > 80) {
    base = base.substring(0, 80).trim().replaceAll(RegExp(r'[. ]+$'), '');
  }
  return '$base.${format.extension}';
}

/// Opens the platform share sheet with the note rendered as a file.
Future<void> shareNote(
  Note note,
  NoteExportFormat format, {
  Rect? sharePositionOrigin,
}) async {
  final content = exportNote(note, format);
  final fileName = noteExportFileName(note.title, format);
  final subject = note.title.trim().isEmpty ? null : note.title.trim();

  await SharePlus.instance.share(
    ShareParams(
      files: [
        XFile.fromData(
          utf8.encode(content),
          mimeType: format.mimeType,
        ),
      ],
      fileNameOverrides: [fileName],
      subject: subject,
      text: subject,
      sharePositionOrigin: sharePositionOrigin,
    ),
  );
}

String _noteToPlainText(Note note) {
  final parts = <String>[
    if (note.title.trim().isNotEmpty) note.title.trim(),
    if (note.plainText.trim().isNotEmpty) note.plainText.trim(),
  ];
  return parts.join('\n\n');
}

String _noteToMarkdown(Note note) {
  final buffer = StringBuffer();
  if (note.title.trim().isNotEmpty) {
    buffer.writeln('# ${note.title.trim()}');
    buffer.writeln();
  }
  for (final line in _linesFrom(note)) {
    buffer.writeln(_markdownLine(line));
  }
  return buffer.toString().trimRight();
}

String _noteToHtml(Note note) {
  final body = StringBuffer();
  var openList = '';
  var inCodeBlock = false;

  void closeList() {
    if (openList.isNotEmpty) {
      body.writeln('</$openList>');
      openList = '';
    }
  }

  void closeCode() {
    if (inCodeBlock) {
      body.writeln('</code></pre>');
      inCodeBlock = false;
    }
  }

  for (final line in _linesFrom(note)) {
    final block = line.block;
    final list = block['list'];

    if (block['code-block'] == true) {
      closeList();
      if (!inCodeBlock) {
        body.writeln('<pre><code>');
        inCodeBlock = true;
      }
      body.writeln(_escapeHtml(_plainLine(line)));
      continue;
    }
    closeCode();

    if (list == 'bullet' || list == 'checked' || list == 'unchecked') {
      if (openList != 'ul') {
        closeList();
        body.writeln('<ul class="checklist">');
        openList = 'ul';
      }
      final checkbox = switch (list) {
        'checked' => '<input type="checkbox" disabled checked> ',
        'unchecked' => '<input type="checkbox" disabled> ',
        _ => '',
      };
      body.writeln('<li>$checkbox${_htmlInline(line)}</li>');
      continue;
    }
    if (list == 'ordered') {
      if (openList != 'ol') {
        closeList();
        body.writeln('<ol>');
        openList = 'ol';
      }
      body.writeln('<li>${_htmlInline(line)}</li>');
      continue;
    }
    closeList();

    final header = block['header'];
    final text = _htmlInline(line);
    if (header is int) {
      final level = header.clamp(1, 6);
      body.writeln('<h$level>$text</h$level>');
    } else if (block['blockquote'] == true) {
      body.writeln('<blockquote>$text</blockquote>');
    } else if (text.isNotEmpty) {
      body.writeln('<p>$text</p>');
    }
  }
  closeCode();
  closeList();

  final title = _escapeHtml(note.title.trim().isEmpty ? 'Note' : note.title);
  return '<!DOCTYPE html>\n'
      '<html>\n<head>\n<meta charset="utf-8">\n<title>$title</title>\n</head>\n'
      '<body>\n'
      '${note.title.trim().isNotEmpty ? '<h1>$title</h1>\n' : ''}'
      '$body'
      '</body>\n</html>';
}

String _markdownLine(_ExportLine line) {
  final text = line.inlines.map(_markdownInline).join();
  final block = line.block;
  final header = block['header'];
  if (header is int) {
    return '${'#' * header.clamp(1, 6)} $text';
  }
  return switch (block['list']) {
    'checked' => '- [x] $text',
    'unchecked' => '- [ ] $text',
    'bullet' => '- $text',
    'ordered' => '1. $text',
    _ => block['blockquote'] == true
        ? '> $text'
        : block['code-block'] == true
            ? '    $text'
            : text,
  };
}

String _markdownInline(_Inline inline) {
  if (inline.embedType != null) {
    final type = inline.embedType!;
    final data = inline.embedData?.toString() ?? '';
    return switch (type) {
      'image' => '![image]($data)',
      'video' => '[video]($data)',
      _ => '[$type]($data)',
    };
  }
  var text = inline.text;
  final attrs = inline.attributes;
  if (attrs['code'] == true) return '`$text`';
  if (attrs['bold'] == true) text = '**$text**';
  if (attrs['italic'] == true) text = '_${text}_';
  if (attrs['strike'] == true) text = '~~$text~~';
  final link = attrs['link'];
  if (link is String && link.isNotEmpty) text = '[$text]($link)';
  return text;
}

String _plainLine(_ExportLine line) {
  return line.inlines.map((inline) {
    if (inline.embedType != null) return '[${inline.embedType}]';
    return inline.text;
  }).join();
}

String _htmlInline(_ExportLine line) {
  return line.inlines.map((inline) {
    if (inline.embedType != null) {
      final type = _escapeHtml(inline.embedType!);
      final data = _escapeHtml(inline.embedData?.toString() ?? '');
      return switch (inline.embedType) {
        'image' => '<img src="$data" alt="image">',
        'video' => '<a href="$data">video</a>',
        _ => '<span class="embed $type">$data</span>',
      };
    }
    var text = _escapeHtml(inline.text);
    final attrs = inline.attributes;
    if (attrs['code'] == true) text = '<code>$text</code>';
    if (attrs['bold'] == true) text = '<strong>$text</strong>';
    if (attrs['italic'] == true) text = '<em>$text</em>';
    if (attrs['strike'] == true) text = '<del>$text</del>';
    final link = attrs['link'];
    if (link is String && link.isNotEmpty) {
      text = '<a href="${_escapeHtml(link)}">$text</a>';
    }
    return text;
  }).join();
}

String _escapeHtml(String value) => value
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;')
    .replaceAll("'", '&#39;');

class _Inline {
  _Inline.text(this.text, this.attributes)
      : embedType = null,
        embedData = null;
  _Inline.embed(this.embedType, this.embedData, this.attributes) : text = '';

  final String text;
  final Map<String, dynamic> attributes;
  final String? embedType;
  final Object? embedData;
}

class _ExportLine {
  final List<_Inline> inlines = [];
  final Map<String, dynamic> block = {};

  void addText(String text, Map<String, dynamic> attrs) {
    if (text.isEmpty) return;
    inlines.add(_Inline.text(text, attrs));
  }

  void addEmbed(String type, Object? data, Map<String, dynamic> attrs) {
    inlines.add(_Inline.embed(type, data, attrs));
  }
}

List<_ExportLine> _linesFrom(Note note) {
  final lines = <_ExportLine>[];
  var current = _ExportLine();
  const blockKeys = {'header', 'list', 'blockquote', 'code-block'};

  void finishLine(Map<String, dynamic> attrs) {
    for (final entry in attrs.entries) {
      if (blockKeys.contains(entry.key)) current.block[entry.key] = entry.value;
    }
    lines.add(current);
    current = _ExportLine();
  }

  for (final op in note.document.toDelta().toJson()) {
    final insert = op['insert'];
    final attrs = (op['attributes'] as Map?)?.cast<String, dynamic>() ??
        const <String, dynamic>{};
    if (insert is String) {
      for (final key in blockKeys) {
        if (attrs.containsKey(key)) current.block[key] = attrs[key];
      }
      final parts = insert.split('\n');
      for (var i = 0; i < parts.length; i++) {
        current.addText(parts[i], attrs);
        if (i != parts.length - 1) finishLine(attrs);
      }
    } else if (insert is Map && insert.isNotEmpty) {
      for (final key in blockKeys) {
        if (attrs.containsKey(key)) current.block[key] = attrs[key];
      }
      current.addEmbed(
        insert.keys.first.toString(),
        insert.values.first,
        attrs,
      );
    }
  }
  if (current.inlines.isNotEmpty || current.block.isNotEmpty) {
    lines.add(current);
  }
  return lines;
}
