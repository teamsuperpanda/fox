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
    );
  }

  @override
  void write(BinaryWriter writer, Settings obj) {
    writer.writeByte(2);
    writer.writeByte(0);
    writer.write(obj.themeMode);
    writer.writeByte(1);
    writer.write(obj.locale);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is SettingsAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}
