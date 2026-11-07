// Tolerant field readers shared by the handwritten Hive adapters.
//
// A missing field, or one stored with an unexpected type, falls back to a
// default instead of throwing. That keeps boxes written by an older version
// readable, and lets a box written by a newer version be opened by a build
// that does not know about the extra fields yet.

String? readString(Object? value) => value is String ? value : null;

bool? readBool(Object? value) => value is bool ? value : null;

int? readInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return null;
}

DateTime? readDate(Object? value) {
  final millis = readInt(value);
  return millis == null ? null : DateTime.fromMillisecondsSinceEpoch(millis);
}

List<String> readStringList(Object? value) {
  if (value is! List) return const [];
  return value.map((e) => e.toString()).toList(growable: false);
}
