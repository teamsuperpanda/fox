class Note {
  final String id;
  final String title;
  final String content;
  final bool pinned;
  final DateTime updatedAt;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.pinned,
    required this.updatedAt,
  });

  Note copyWith({
    String? id,
    String? title,
    String? content,
    bool? pinned,
    DateTime? updatedAt,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      pinned: pinned ?? this.pinned,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static Note fromMap(Map<String, Object?> map) {
    return Note(
      id: map['id'] as String,
      title: (map['title'] as String?) ?? '',
      content: (map['content'] as String?) ?? '',
      pinned: (map['pinned'] as int? ?? 0) == 1,
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int),
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'pinned': pinned ? 1 : 0,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }
}

abstract class NoteRepository {
  Future<void> init();
  Future<List<Note>> getAll();
  Future<Note?> getById(String id);
  Future<void> upsert(Note note);
  Future<void> delete(String id);
  Future<void> clear(); // not used in app, but handy for tests
}
