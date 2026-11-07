import 'package:flutter/foundation.dart';

@immutable
class Folder {
  Folder({
    required this.id,
    required this.name,
    required this.createdAt,
    this.parentId,
  }) : assert(name.trim().isNotEmpty, 'Folder name cannot be empty');
  final String id;
  final String name;
  final DateTime createdAt;

  /// Parent folder id, or null for a top-level folder.
  ///
  /// Nesting is capped at one level: a folder with a [parentId] cannot be a
  /// parent itself.
  final String? parentId;

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
    String? parentId,
    bool clearParent = false,
  }) {
    return Folder(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      parentId: clearParent ? null : (parentId ?? this.parentId),
    );
  }
}
