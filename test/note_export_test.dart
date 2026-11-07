import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:fox/models/note.dart';
import 'package:fox/services/note_export.dart';

Note _note(String title, List<Map<String, Object?>> ops) => Note(
      id: 'export-id',
      title: title,
      content: jsonEncode({'ops': ops}),
      pinned: false,
      updatedAt: DateTime(2026),
    );

Note _structuredNote() => _note('Shopping', [
      {'insert': 'Intro'},
      {'insert': '\n'},
      {
        'insert': 'Bold',
        'attributes': {'bold': true},
      },
      {'insert': '\n'},
      {
        'insert': 'Link',
        'attributes': {'link': 'https://example.com'},
      },
      {'insert': '\n'},
      {
        'insert': 'Item',
        'attributes': {'list': 'bullet'},
      },
      {'insert': '\n'},
      {
        'insert': 'Done',
        'attributes': {'list': 'checked'},
      },
      {'insert': '\n'},
      {
        'insert': 'Todo',
        'attributes': {'list': 'unchecked'},
      },
      {'insert': '\n'},
      {
        'insert': 'Heading',
        'attributes': {'header': 2},
      },
      {'insert': '\n'},
      {
        'insert': 'code line',
        'attributes': {'code-block': true},
      },
      {'insert': '\n'},
    ]);

void main() {
  group('note export', () {
    test('plain text includes the title and body', () {
      final text = exportNote(_structuredNote(), NoteExportFormat.plainText);

      expect(text, startsWith('Shopping\n\n'));
      expect(text, contains('Intro'));
      expect(text, contains('Item'));
    });

    test('markdown preserves headings, inline styles, lists and checklists',
        () {
      final md = exportNote(_structuredNote(), NoteExportFormat.markdown);

      expect(md, contains('# Shopping'));
      expect(md, contains('**Bold**'));
      expect(md, contains('[Link](https://example.com)'));
      expect(md, contains('- Item'));
      expect(md, contains('- [x] Done'));
      expect(md, contains('- [ ] Todo'));
      expect(md, contains('## Heading'));
      expect(md, contains('    code line'));
    });

    test('html preserves the same structure', () {
      final html = exportNote(_structuredNote(), NoteExportFormat.html);

      expect(html, contains('<h1>Shopping</h1>'));
      expect(html, contains('<strong>Bold</strong>'));
      expect(html, contains('<a href="https://example.com">Link</a>'));
      expect(html, contains('<ul class="checklist">'));
      expect(html, contains('<input type="checkbox" disabled checked>'));
      expect(html, contains('<h2>Heading</h2>'));
      expect(html, contains('<pre><code>'));
      expect(html, contains('code line'));
    });

    test('html escapes user text', () {
      final note = _note('A < B', [
        {'insert': '<script>alert(1)</script>\n'},
      ]);
      final html = exportNote(note, NoteExportFormat.html);

      expect(html, contains('&lt;script&gt;'));
      expect(html, isNot(contains('<script>alert')));
      expect(html, contains('<title>A &lt; B</title>'));
    });

    test('plain text and markdown keep checklist item text', () {
      final note = _note('Tasks', [
        {
          'insert': 'Buy milk',
          'attributes': {'list': 'unchecked'},
        },
        {'insert': '\n'},
      ]);

      expect(
        exportNote(note, NoteExportFormat.plainText),
        contains('Buy milk'),
      );
      expect(
        exportNote(note, NoteExportFormat.markdown),
        contains('- [ ] Buy milk'),
      );
    });
  });

  group('note export filename', () {
    test('strips characters unsafe on Android and iOS', () {
      final name = noteExportFileName(
        'a/b:c*?"<>| weird. ',
        NoteExportFormat.markdown,
      );

      expect(name, 'abc weird.md');
      expect(name, isNot(contains('/')));
    });

    test('falls back to note for an empty title', () {
      expect(
        noteExportFileName('   ', NoteExportFormat.plainText),
        'note.txt',
      );
    });

    test('caps the filename length and uses the right extension', () {
      final name = noteExportFileName(
        'x' * 200,
        NoteExportFormat.html,
      );

      expect(name.endsWith('.html'), isTrue);
      expect(name.length, lessThanOrEqualTo(85));
    });
  });
}
