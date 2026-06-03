import 'package:flutter/foundation.dart';

@immutable
class Folder {

  Folder({
    required this.id,
    required this.name,
    required this.createdAt,
  }) : assert(name.trim().isNotEmpty, 'Folder name cannot be empty');
  final String id;
  final String name;
  final DateTime createdAt;

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
  }) {
    return Folder(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
