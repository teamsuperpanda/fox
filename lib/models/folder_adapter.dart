// Handwritten Hive TypeAdapter for Folder to avoid build_runner.
//
// Stored-field rules (see lib/services/schema_migrations.dart):
// - Field indices are permanent. Never reuse or renumber one.
// - typeId 4 is permanent: it identifies Folder inside folders_db.
// - Append new fields at the next free index and give them a default here.
// - Bump currentSchemaVersion when a field is added or changed.
import 'package:fox/models/adapter_utils.dart';
import 'package:fox/models/folder.dart';
import 'package:hive/hive.dart';

class FolderAdapter extends TypeAdapter<Folder> {
  @override
  final int typeId = 4;

  /// Number of fields written by this version. Append at this index next.
  static const int fieldCount = 3;

  @override
  Folder read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numOfFields; i++) {
      final field = reader.readByte();
      fields[field] = reader.read();
    }
    return Folder(
      id: readString(fields[0]) ?? '',
      name: readString(fields[1]) ?? '',
      createdAt: readDate(fields[2]) ?? DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  @override
  void write(BinaryWriter writer, Folder obj) {
    writer.writeByte(fieldCount);
    writer.writeByte(0);
    writer.write(obj.id);
    writer.writeByte(1);
    writer.write(obj.name);
    writer.writeByte(2);
    writer.write(obj.createdAt.millisecondsSinceEpoch);
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
