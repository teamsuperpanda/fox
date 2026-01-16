// Handwritten Hive TypeAdapter for Settings to avoid build_runner for now.
import 'package:hive/hive.dart';
import 'settings.dart';

class SettingsAdapter extends TypeAdapter<Settings> {
  @override
  final int typeId = 2;

  @override
  Settings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numOfFields; i++) {
      final field = reader.readByte();
      fields[field] = reader.read();
    }
    return Settings(
      themeMode: fields[0] as String? ?? 'system',
      locale: fields[1] as String?,
      showTags: fields[2] as bool? ?? true,
      alternatingColors: fields[3] as bool? ?? false,
      fabAnimation: fields[4] as bool? ?? true,
      showContent: fields[5] as bool? ?? true,
    );
  }

  @override
  void write(BinaryWriter writer, Settings obj) {
    writer.writeByte(6); // Number of fields
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
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is SettingsAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}
