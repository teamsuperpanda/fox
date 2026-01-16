import 'dart:convert';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fox/models/note.dart';

void main() {
  group('Note Model', () {
    late DateTime testDateTime;
    late Note note;

    setUp(() {
      testDateTime = DateTime(2025, 11, 14, 10, 30);
      note = Note(
        id: 'test-id-123',
        title: 'Test Note',
        content: '{"ops":[{"insert":"Hello World\\n"}]}',
        pinned: false,
        updatedAt: testDateTime,
      );
    });

    test('creates a note with all fields', () {
      expect(note.id, equals('test-id-123'));
      expect(note.title, equals('Test Note'));
      expect(note.content, equals('{"ops":[{"insert":"Hello World\\n"}]}'));
      expect(note.pinned, equals(false));
      expect(note.updatedAt, equals(testDateTime));
      expect(note.tags, isEmpty);
    });

    test('copyWith creates new note with updated fields', () {
      final updated = note.copyWith(
        title: 'Updated Title',
        pinned: true,
        tags: ['tag1'],
      );

      expect(updated.id, equals(note.id));
      expect(updated.title, equals('Updated Title'));
      expect(updated.pinned, equals(true));
      expect(updated.content, equals(note.content));
      expect(updated.updatedAt, equals(note.updatedAt));
      expect(updated.tags, equals(['tag1']));
    });

    test('copyWith preserves unchanged fields', () {
      final updated = note.copyWith(title: 'New Title');

      expect(updated.id, equals(note.id));
      expect(updated.content, equals(note.content));
      expect(updated.updatedAt, equals(note.updatedAt));
    });

    test('copyWith with all null values returns identical note', () {
      final updated = note.copyWith();

      expect(updated.id, equals(note.id));
      expect(updated.title, equals(note.title));
      expect(updated.content, equals(note.content));
      expect(updated.pinned, equals(note.pinned));
      expect(updated.updatedAt, equals(note.updatedAt));
    });

    test('toMap converts note to map', () {
      final map = note.toMap();

      expect(map['id'], equals('test-id-123'));
      expect(map['title'], equals('Test Note'));
      expect(map['content'], equals('{"ops":[{"insert":"Hello World\\n"}]}'));
      expect(map['pinned'], equals(0)); // false -> 0
      expect(map['updatedAt'], equals(testDateTime.millisecondsSinceEpoch));
      expect(map['tags'], equals([]));
    });

    test('toMap converts pinned true to 1', () {
      final pinnedNote = note.copyWith(pinned: true);
      final map = pinnedNote.toMap();

      expect(map['pinned'], equals(1));
    });

    test('fromMap creates note from map', () {
      final map = {
        'id': 'map-id',
        'title': 'From Map',
        'content': '{"ops":[{"insert":"Content\\n"}]}',
        'pinned': 1, // 1 -> true
        'updatedAt': testDateTime.millisecondsSinceEpoch,
        'tags': ['a', 'b'],
      };

      final created = Note.fromMap(map);

      expect(created.id, equals('map-id'));
      expect(created.title, equals('From Map'));
      expect(created.content, equals('{"ops":[{"insert":"Content\\n"}]}'));
      expect(created.pinned, equals(true));
      expect(created.updatedAt, equals(testDateTime));
      expect(created.tags, equals(['a', 'b']));
    });

    test('fromMap converts 0 to pinned false', () {
      final map = {
        'id': 'id',
        'title': 'title',
        'content': '{}',
        'pinned': 0,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      };

      final created = Note.fromMap(map);
      expect(created.pinned, equals(false));
    });

    test('fromMap handles missing optional fields with defaults', () {
      final map = {
        'id': 'id',
        'updatedAt': testDateTime.millisecondsSinceEpoch,
      };

      final created = Note.fromMap(map);

      expect(created.id, equals('id'));
      expect(created.title, equals(''));
      expect(created.content, equals(''));
      expect(created.pinned, equals(false));
      expect(created.updatedAt, equals(testDateTime));
    });

    test('toMap and fromMap round-trip preserves data', () {
      final map = note.toMap();
      final recreated = Note.fromMap(map);

      expect(recreated.id, equals(note.id));
      expect(recreated.title, equals(note.title));
      expect(recreated.content, equals(note.content));
      expect(recreated.pinned, equals(note.pinned));
      expect(recreated.updatedAt, equals(note.updatedAt));
    });

    test('document getter parses valid JSON content', () {
      final document = note.document;
      expect(document, isA<Document>());
    });

    test('document getter returns empty Document for empty content', () {
      final emptyNote = note.copyWith(content: '');
      final document = emptyNote.document;

      expect(document, isA<Document>());
      expect(document.isEmpty(), isTrue);
    });

    test('document getter handles corrupted JSON gracefully', () {
      final corruptedNote = note.copyWith(content: '{invalid json}');
      final document = corruptedNote.document;

      expect(document, isA<Document>());
      expect(document.isEmpty(), isTrue);
    });

    test('plainText extracts text from document', () {
      final plainText = note.plainText;
      expect(plainText, isA<String>());
    });

    test('plainText from empty content returns empty string', () {
      final emptyNote = note.copyWith(content: '');
      final plainText = emptyNote.plainText;

      // Empty document returns newline by default in flutter_quill
      expect(plainText.trim(), equals(''));
    });

    test('documentToContent creates valid JSON string', () {
      final doc = Document();
      final content = Note.documentToContent(doc);

      expect(content, isA<String>());
      // Should be valid JSON that can be decoded
      expect(() => jsonDecode(content), returnsNormally);
    });
  });
}
