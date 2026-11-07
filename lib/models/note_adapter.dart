// Handwritten Hive TypeAdapter for Note to avoid build_runner.
//
// Stored-field rules (see lib/services/schema_migrations.dart):
// - Field indices are permanent. Never reuse or renumber one.
// - typeId 3 is permanent: it identifies Note inside notes_db.
// - Append new fields at the next free index and give them a default here.
// - Bump currentSchemaVersion when a field is added or changed.
import 'package:fox/models/adapter_utils.dart';
import 'package:fox/models/note.dart';
import 'package:hive/hive.dart';

class NoteAdapter extends TypeAdapter<Note> {
  @override
  final int typeId = 3; // Different from Settings (typeId: 2)

  /// Number of fields written by this version. Append at this index next.
  static const int fieldCount = 8;

  @override
  Note read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numOfFields; i++) {
      final field = reader.readByte();
      fields[field] = reader.read();
    }
    return Note(
      id: readString(fields[0]) ?? '',
      title: readString(fields[1]) ?? '',
      content: readString(fields[2]) ?? '',
      pinned: readBool(fields[3]) ?? false,
      updatedAt: readDate(fields[4]) ?? DateTime.fromMillisecondsSinceEpoch(0),
      tags: readStringList(fields[5]),
      folderId: readString(fields[6]),
      color: readString(fields[7]),
    );
  }

  @override
  void write(BinaryWriter writer, Note obj) {
    writer.writeByte(fieldCount);
    writer.writeByte(0);
    writer.write(obj.id);
    writer.writeByte(1);
    writer.write(obj.title);
    writer.writeByte(2);
    writer.write(obj.content);
    writer.writeByte(3);
    writer.write(obj.pinned);
    writer.writeByte(4);
    writer.write(obj.updatedAt.millisecondsSinceEpoch);
    writer.writeByte(5);
    writer.write(obj.tags);
    writer.writeByte(6);
    writer.write(obj.folderId);
    writer.writeByte(7);
    writer.write(obj.color);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NoteAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
