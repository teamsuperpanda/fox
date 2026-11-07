// Handwritten Hive TypeAdapter for Settings to avoid build_runner for now.
//
// Stored-field rules (see lib/services/schema_migrations.dart):
// - Field indices are permanent. Never reuse or renumber one.
// - typeId 2 is permanent: it identifies Settings inside settings_db.
// - Append new fields at the next free index and give them a default here.
// - Bump currentSchemaVersion when a field is added or changed.
import 'package:fox/models/adapter_utils.dart';
import 'package:fox/models/settings.dart';
import 'package:hive/hive.dart';

class SettingsAdapter extends TypeAdapter<Settings> {
  @override
  final int typeId = 2;

  /// Number of fields written by this version. Append at this index next.
  static const int fieldCount = 8;

  @override
  Settings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numOfFields; i++) {
      final field = reader.readByte();
      fields[field] = reader.read();
    }
    return Settings(
      themeMode: readString(fields[0]) ?? 'system',
      locale: readString(fields[1]),
      showTags: readBool(fields[2]) ?? true,
      alternatingColors: readBool(fields[3]) ?? false,
      fabAnimation: readBool(fields[4]) ?? true,
      showContent: readBool(fields[5]) ?? true,
      sortBy: readString(fields[6]) ?? 'dateDesc',
      accentColor: readString(fields[7]),
    );
  }

  @override
  void write(BinaryWriter writer, Settings obj) {
    writer.writeByte(fieldCount);
    writer.writeByte(0);
    writer.write(obj.themeMode);
    writer.writeByte(1);
    writer.write(obj.locale);
    writer.writeByte(2);
    writer.write(obj.showTags);
    writer.writeByte(3);
    writer.write(obj.alternatingColors);
    writer.writeByte(4);
    writer.write(obj.fabAnimation);
    writer.writeByte(5);
    writer.write(obj.showContent);
    writer.writeByte(6);
    writer.write(obj.sortBy);
    writer.writeByte(7);
    writer.write(obj.accentColor);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
