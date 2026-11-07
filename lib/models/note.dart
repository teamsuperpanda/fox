import 'package:flutter/foundation.dart';
import 'package:fox/editor/quill_codec.dart';

class Note {
  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.pinned,
    required this.updatedAt,
    this.tags = const [],
    this.folderId,
    this.color,
  })  : _lowerTitle = title.toLowerCase(),
        _lowerTags = tags.map((t) => t.toLowerCase()).toList(growable: false);
  final String id;
  final String title;
  final String content; // JSON string representing Quill Delta
  final bool pinned;
  final DateTime updatedAt;
  final List<String> tags;
  final String? folderId;
  final String? color; // Hex string e.g. '#FF5252'

  String? _plainText;
  final String _lowerTitle;
  final List<String> _lowerTags;

  String get lowerTitle => _lowerTitle;
  List<String> get lowerTags => _lowerTags;

  static const NoteContentCodec _codec = NoteContentCodec();

  // Get plain text from the stored content for search/display.
  // Computed lazily and cached after the first access.
  String get plainText {
    final cached = _plainText;
    if (cached != null) return cached;
    final computed = _codec.plainTextOf(content);
    _plainText = computed;
    return computed;
  }

  Note copyWith({
    String? id,
    String? title,
    String? content,
    bool? pinned,
    DateTime? updatedAt,
    List<String>? tags,
    String? folderId,
    String? color,
    bool clearFolder = false,
    bool clearColor = false,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      pinned: pinned ?? this.pinned,
      updatedAt: updatedAt ?? this.updatedAt,
      tags: tags ?? this.tags,
      folderId: clearFolder ? null : (folderId ?? this.folderId),
      color: clearColor ? null : (color ?? this.color),
    );
  }

  @visibleForTesting
  static Note fromMap(Map<String, Object?> map) {
    return Note(
      id: (map['id'] as String?) ?? '',
      title: (map['title'] as String?) ?? '',
      content: (map['content'] as String?) ?? '',
      pinned: (map['pinned'] as int? ?? 0) == 1,
      updatedAt:
          DateTime.fromMillisecondsSinceEpoch((map['updatedAt'] as int?) ?? 0),
      tags:
          (map['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
              const [],
      folderId: map['folderId'] as String?,
      color: map['color'] as String?,
    );
  }

  @visibleForTesting
  Map<String, Object?> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'pinned': pinned ? 1 : 0,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'tags': tags,
      'folderId': folderId,
      'color': color,
    };
  }
}
