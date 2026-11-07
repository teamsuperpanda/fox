import 'dart:convert';

import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fox/editor/quill_codec.dart';

void main() {
  group('NoteContentCodec', () {
    const codec = NoteContentCodec();

    test('round-trips a document without changing the Delta JSON format', () {
      final document = Document.fromJson([
        {'insert': 'Hello'},
        {
          'insert': ' World',
          'attributes': {'bold': true},
        },
        {'insert': '\n'},
      ]);

      final content = codec.fromDocument(document);

      expect(
        jsonDecode(content.deltaJson),
        [
          {'insert': 'Hello'},
          {
            'insert': ' World',
            'attributes': {'bold': true},
          },
          {'insert': '\n'},
        ],
      );
      expect(content.plainText, 'Hello World\n');
      expect(codec.plainTextOf(content.deltaJson), 'Hello World\n');
      expect(
          codec.toDocument(content.deltaJson).toPlainText(), 'Hello World\n');
    });

    test('empty content decodes to an empty document', () {
      final document = codec.toDocument('');

      expect(document.isEmpty(), isTrue);
      expect(codec.plainTextOf(''), '');
    });

    test('empty ops list decodes to an empty document', () {
      expect(codec.toDocument('{"ops":[]}').isEmpty(), isTrue);
      expect(codec.toDocument('[]').isEmpty(), isTrue);
      expect(codec.plainTextOf('{"ops":[]}'), '');
    });

    test('accepts ops wrapped in a map', () {
      final document = codec.toDocument(
        r'{"ops":[{"insert":"wrapped\n"}]}',
      );

      expect(document.toPlainText(), contains('wrapped'));
    });

    test('truncated JSON falls back to an empty document', () {
      final document = codec.toDocument('{"ops":[{"insert":"hi');

      expect(document.isEmpty(), isTrue);
      expect(codec.plainTextOf('{"ops":[{"insert":"hi'), '');
    });

    test('malformed JSON falls back to an empty document', () {
      final document = codec.toDocument('{invalid}');

      expect(document.isEmpty(), isTrue);
      expect(codec.plainTextOf('{invalid}'), '');
    });

    test('unknown embed payloads do not throw', () {
      const payload =
          r'{"ops":[{"insert":{"unknownEmbed":{"id":"x"}}},{"insert":"\n"}]}';

      late Document document;
      expect(() => document = codec.toDocument(payload), returnsNormally);
      expect(() => codec.plainTextOf(payload), returnsNormally);
      expect(document.toPlainText(), isA<String>());
    });

    test('non-list ops payload falls back to empty', () {
      expect(codec.toDocument('{"ops":"nope"}').isEmpty(), isTrue);
      expect(codec.toDocument('42').isEmpty(), isTrue);
    });
  });
}
