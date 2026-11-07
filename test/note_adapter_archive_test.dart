import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:fox/models/note.dart';
import 'package:fox/models/note_adapter.dart';
import 'package:hive/hive.dart';

void main() {
  test('NoteAdapter round-trips archivedAt', () async {
    final dir = await Directory.systemTemp.createTemp('fox_archive_adapter');
    Hive.init(dir.path);
    Hive.registerAdapter(NoteAdapter());
    final box = await Hive.openBox<Note>('notes_db');

    final archivedAt = DateTime.utc(2025, 6, 7, 8, 9);
    await box.put(
      'note-1',
      Note(
        id: 'note-1',
        title: 'Archived',
        content: '{}',
        pinned: false,
        updatedAt: DateTime.utc(2025),
        archivedAt: archivedAt,
      ),
    );

    final restored = box.get('note-1');
    expect(restored, isNotNull);
    expect(restored!.isArchived, isTrue);
    expect(
      restored.archivedAt!.millisecondsSinceEpoch,
      archivedAt.millisecondsSinceEpoch,
    );

    await Hive.close();
    await Hive.deleteFromDisk();
    await dir.delete(recursive: true);
  });
}
