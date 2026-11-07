import 'package:flutter/foundation.dart';

@immutable
class Folder {
  Folder({
    required this.id,
    required this.name,
    required this.createdAt,
    this.icon,
    this.color,
  }) : assert(name.trim().isNotEmpty, 'Folder name cannot be empty');
  final String id;
  final String name;
  final DateTime createdAt;

  /// Key from `folderIconOptions`, or `null` for the default folder icon.
  final String? icon;

  /// Hex string such as `'#AB47BC'`, or `null` for the default tint.
  final String? color;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Folder && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  Folder copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    String? icon,
    String? color,
    bool clearIcon = false,
    bool clearColor = false,
  }) {
    return Folder(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      icon: clearIcon ? null : (icon ?? this.icon),
      color: clearColor ? null : (color ?? this.color),
    );
  }
}
