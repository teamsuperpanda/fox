// Handwritten Hive TypeAdapter for Folder to avoid build_runner.
import 'package:fox/models/folder.dart';
import 'package:hive/hive.dart';

class FolderAdapter extends TypeAdapter<Folder> {
  @override
  final int typeId = 4;

  /// Number of fields written by this version. Append at this index next.
  static const int fieldCount = 4;

  @override
  Folder read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numOfFields; i++) {
      final field = reader.readByte();
      fields[field] = reader.read();
    }
    final parentId = fields[3];
    return Folder(
      id: fields[0] as String,
      name: fields[1] as String? ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(fields[2] as int),
      parentId: parentId is String ? parentId : null,
    );
  }

  @override
  void write(BinaryWriter writer, Folder obj) {
    writer.writeByte(fieldCount); // Number of fields
    writer.writeByte(0);
    writer.write(obj.id);
    writer.writeByte(1);
    writer.write(obj.name);
    writer.writeByte(2);
    writer.write(obj.createdAt.millisecondsSinceEpoch);
    writer.writeByte(3);
    writer.write(obj.parentId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FolderAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
