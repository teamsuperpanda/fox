import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:fox/models/note.dart';
import 'package:fox/models/note_adapter.dart';
import 'package:fox/services/box_names.dart';
import 'package:hive/hive.dart';

/// Reads one stored field by name.
///
/// Unknown names throw, so adding a field to [Note.fieldNames] without adding
/// it here makes every test in this file fail.
Object? _fieldValue(Note note, String field) {
  return switch (field) {
    'id' => note.id,
    'title' => note.title,
    'content' => note.content,
    'pinned' => note.pinned,
    'updatedAt' => note.updatedAt,
    'tags' => note.tags,
    'folderId' => note.folderId,
    'color' => note.color,
    _ => throw ArgumentError('Unknown Note field "$field"'),
  };
}

/// Asserts that [actual] kept every field of [expected].
void _expectSameFields(Note expected, Note actual, {String? reason}) {
  for (final field in Note.fieldNames) {
    final expectedValue = _fieldValue(expected, field);
    final actualValue = _fieldValue(actual, field);
    if (field == 'updatedAt') {
      // Stored as epoch millis, so the UTC flag is not part of the value.
      expect(
        (actualValue! as DateTime).millisecondsSinceEpoch,
        (expectedValue! as DateTime).millisecondsSinceEpoch,
        reason: reason ?? 'copyWith dropped "$field"',
      );
      continue;
    }
    expect(
      actualValue,
      expectedValue,
      reason: reason ?? 'copyWith dropped "$field"',
    );
  }
}

Note _fullNote() {
  return Note(
    id: 'full-note',
    title: 'A fully populated note',
    content: r'{"ops":[{"insert":"every field\n"}]}',
    pinned: true,
    updatedAt: DateTime.utc(2024, 5, 6, 7, 8, 9),
    tags: const ['alpha', 'beta'],
    folderId: 'folder-1',
    color: '#AB47BC',
  );
}

void main() {
  group('Note field registry', () {
    test('names every field of a fully populated note', () {
      final note = _fullNote();
      expect(Note.fieldNames, hasLength(8));
      for (final field in Note.fieldNames) {
        expect(_fieldValue(note, field), isNotNull, reason: field);
      }
    });

    test('copyWith with no arguments preserves every field', () {
      final note = _fullNote();
      _expectSameFields(note, note.copyWith());
    });

    test('copyWith mutations keep every other field', () {
      final note = _fullNote();

      final pinned = note.copyWith(pinned: false);
      expect(pinned.pinned, isFalse);
      _expectSameFields(note.copyWith(pinned: false), pinned);

      final tagged = note.copyWith(tags: const ['gamma']);
      expect(tagged.tags, ['gamma']);
      for (final field in Note.fieldNames.where((f) => f != 'tags')) {
        expect(_fieldValue(tagged, field), _fieldValue(note, field),
            reason: field);
      }

      final folded = note.copyWith(folderId: 'folder-2');
      expect(folded.folderId, 'folder-2');
      for (final field in Note.fieldNames.where((f) => f != 'folderId')) {
        expect(_fieldValue(folded, field), _fieldValue(note, field),
            reason: field);
      }

      final coloured = note.copyWith(color: '#00FF00');
      expect(coloured.color, '#00FF00');
      for (final field in Note.fieldNames.where((f) => f != 'color')) {
        expect(_fieldValue(coloured, field), _fieldValue(note, field),
            reason: field);
      }
    });

    test('copyWith clears nullable fields only when asked', () {
      final note = _fullNote();

      final clearedFolder = note.copyWith(folderId: null);
      expect(clearedFolder.folderId, isNull);
      expect(clearedFolder.color, note.color);
      _expectSameFields(
        note.copyWith(folderId: null),
        clearedFolder,
      );

      final clearedColor = note.copyWith(color: null);
      expect(clearedColor.color, isNull);
      expect(clearedColor.folderId, note.folderId);
    });
  });

  group('Note adapter', () {
    late Directory dir;

    setUp(() async {
      dir = await Directory.systemTemp.createTemp('fox_note_adapter');
      Hive.init(dir.path);
      if (!Hive.isAdapterRegistered(3)) {
        Hive.registerAdapter(NoteAdapter());
      }
    });

    tearDown(() async {
      await Hive.close();
      await Hive.deleteFromDisk();
      await dir.delete(recursive: true);
    });

    test('round-trips a note with every field set', () async {
      final box = await Hive.openBox<Note>(BoxNames.notes);
      final note = _fullNote();

      await box.put(note.id, note);
      final restored = box.get(note.id);

      expect(restored, isNotNull);
      _expectSameFields(note, restored!, reason: 'adapter dropped a field');
    });
  });

  group('Note export and import', () {
    test('round-trips every field through the map codec', () {
      final note = _fullNote();
      _expectSameFields(note, Note.fromMap(note.toMap()));
    });

    test('round-trips every field through JSON', () {
      final note = _fullNote();
      final encoded = jsonEncode(note.toMap());
      final decoded = jsonDecode(encoded) as Map<String, dynamic>;
      _expectSameFields(note, Note.fromMap(decoded));
    });
  });
}
