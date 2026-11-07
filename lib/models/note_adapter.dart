// Handwritten Hive TypeAdapter for Note to avoid build_runner.
import 'package:fox/models/note.dart';
import 'package:hive/hive.dart';

class NoteAdapter extends TypeAdapter<Note> {
  @override
  final int typeId = 3; // Different from Settings (typeId: 2)

  /// Number of fields written by this version. Append at this index next.
  static const int fieldCount = 9;

  @override
  Note read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numOfFields; i++) {
      final field = reader.readByte();
      fields[field] = reader.read();
    }
    final archivedAt = fields[8];
    return Note(
      id: fields[0] as String,
      title: fields[1] as String? ?? '',
      content: fields[2] as String? ?? '',
      pinned: fields[3] as bool? ?? false,
      updatedAt: DateTime.fromMillisecondsSinceEpoch(fields[4] as int),
      tags: (fields[5] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          const [],
      folderId: fields[6] as String?,
      color: fields[7] as String?,
      archivedAt: archivedAt is int
          ? DateTime.fromMillisecondsSinceEpoch(archivedAt)
          : null,
    );
  }

  @override
  void write(BinaryWriter writer, Note obj) {
    writer.writeByte(fieldCount); // Number of fields
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
    writer.writeByte(8);
    writer.write(obj.archivedAt?.millisecondsSinceEpoch);
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
