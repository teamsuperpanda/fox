class Folder {
  final String id;
  final String name;
  final DateTime createdAt;

  Folder({
    required this.id,
    required this.name,
    required this.createdAt,
  });

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
