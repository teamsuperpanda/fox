// Handwritten Hive TypeAdapter for Folder to avoid build_runner.
import 'package:fox/models/folder.dart';
import 'package:hive/hive.dart';

class FolderAdapter extends TypeAdapter<Folder> {
  /// Field indices. 3-7 are intentionally left free for future folder fields;
  /// icon and colour were added at 8 and 9 so older records (which only carry
  /// 0-2) still deserialise.
  static const _idField = 0;
  static const _nameField = 1;
  static const _createdAtField = 2;
  static const _iconField = 8;
  static const _colorField = 9;

  @override
  final int typeId = 4;

  @override
  Folder read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numOfFields; i++) {
      final field = reader.readByte();
      fields[field] = reader.read();
    }
    return Folder(
      id: (fields[_idField] as String?) ?? '',
      name: fields[_nameField] as String? ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        (fields[_createdAtField] as int?) ?? 0,
      ),
      icon: fields[_iconField] as String?,
      color: fields[_colorField] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Folder obj) {
    final fields = <int, Object?>{
      _idField: obj.id,
      _nameField: obj.name,
      _createdAtField: obj.createdAt.millisecondsSinceEpoch,
      if (obj.icon != null) _iconField: obj.icon,
      if (obj.color != null) _colorField: obj.color,
    };
    writer.writeByte(fields.length);
    fields.forEach((field, value) {
      writer.writeByte(field);
      writer.write(value);
    });
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
