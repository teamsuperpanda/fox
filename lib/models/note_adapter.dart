// Handwritten Hive TypeAdapter for Note to avoid build_runner.
import 'package:hive/hive.dart';
import 'note.dart';

class NoteAdapter extends TypeAdapter<Note> {
  @override
  final int typeId = 3; // Different from Settings (typeId: 2)

  @override
  Note read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numOfFields; i++) {
      final field = reader.readByte();
      fields[field] = reader.read();
    }
    return Note(
      id: fields[0] as String,
      title: fields[1] as String? ?? '',
      content: fields[2] as String? ?? '',
      pinned: fields[3] as bool? ?? false,
      updatedAt: DateTime.fromMillisecondsSinceEpoch(fields[4] as int),
    );
  }

  @override
  void write(BinaryWriter writer, Note obj) {
    writer.writeByte(5); // Number of fields
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
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is NoteAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}
