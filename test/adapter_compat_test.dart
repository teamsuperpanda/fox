import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:fox/models/folder.dart';
import 'package:fox/models/folder_adapter.dart';
import 'package:fox/models/note.dart';
import 'package:fox/models/note_adapter.dart';
import 'package:fox/services/box_names.dart';
import 'package:hive/hive.dart';

/// The shape of a note before tags, folders, colour and pinning existed:
/// only id, title and content were written.
class _LegacyNoteV1 {
  _LegacyNoteV1({
    required this.id,
    required this.title,
    required this.content,
  });

  final String id;
  final String title;
  final String content;
}

class _LegacyNoteV1Adapter extends TypeAdapter<_LegacyNoteV1> {
  @override
  final int typeId = 3;

  @override
  _LegacyNoteV1 read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numOfFields; i++) {
      final field = reader.readByte();
      fields[field] = reader.read();
    }
    return _LegacyNoteV1(
      id: fields[0] as String,
      title: fields[1] as String,
      content: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, _LegacyNoteV1 obj) {
    writer.writeByte(3);
    writer.writeByte(0);
    writer.write(obj.id);
    writer.writeByte(1);
    writer.write(obj.title);
    writer.writeByte(2);
    writer.write(obj.content);
  }
}

class _LegacyFolderV1 {
  _LegacyFolderV1({required this.id, required this.name});

  final String id;
  final String name;
}

class _LegacyFolderV1Adapter extends TypeAdapter<_LegacyFolderV1> {
  @override
  final int typeId = 4;

  @override
  _LegacyFolderV1 read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numOfFields; i++) {
      final field = reader.readByte();
      fields[field] = reader.read();
    }
    return _LegacyFolderV1(
      id: fields[0] as String,
      name: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, _LegacyFolderV1 obj) {
    writer.writeByte(2);
    writer.writeByte(0);
    writer.write(obj.id);
    writer.writeByte(1);
    writer.write(obj.name);
  }
}

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('fox_adapter_compat');
    Hive.init(tempDir.path);
    Hive.registerAdapter(_LegacyNoteV1Adapter(), override: true);
  });

  tearDown(() async {
    await Hive.close();
    if (tempDir.existsSync()) await tempDir.delete(recursive: true);
  });

  test('the current NoteAdapter reads a v1 payload with defaults', () async {
    final legacyBox = await Hive.openBox<_LegacyNoteV1>(BoxNames.notes);
    await legacyBox.put(
      'old',
      _LegacyNoteV1(
        id: 'old',
        title: 'From v1',
        content: r'[{"insert":"legacy body\n"}]',
      ),
    );
    await legacyBox.close();

    Hive.registerAdapter(NoteAdapter(), override: true);
    final box = await Hive.openBox<Note>(BoxNames.notes);

    final note = box.get('old');
    expect(note, isNotNull);
    expect(note!.id, 'old');
    expect(note.title, 'From v1');
    expect(note.content, r'[{"insert":"legacy body\n"}]');
    // Fields that v1 never wrote fall back instead of throwing.
    expect(note.pinned, isFalse);
    expect(note.tags, isEmpty);
    expect(note.folderId, isNull);
    expect(note.color, isNull);
    expect(note.updatedAt, DateTime.fromMillisecondsSinceEpoch(0));
  });

  test('a folder without a timestamp still decodes', () async {
    Hive.registerAdapter(_LegacyFolderV1Adapter(), override: true);
    final legacyBox = await Hive.openBox<_LegacyFolderV1>(BoxNames.folders);
    await legacyBox.put(
        'folder-1', _LegacyFolderV1(id: 'folder-1', name: 'Work'));
    await legacyBox.close();

    Hive.registerAdapter(FolderAdapter(), override: true);
    final box = await Hive.openBox<Folder>(BoxNames.folders);

    final folder = box.get('folder-1');
    expect(folder!.name, 'Work');
    expect(folder.createdAt, DateTime.fromMillisecondsSinceEpoch(0));
  });
}
