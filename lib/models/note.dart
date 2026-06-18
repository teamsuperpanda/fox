import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_quill/flutter_quill.dart';

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
  }) : _plainText = _parsePlainText(content);
  final String id;
  final String title;
  final String content; // JSON string representing Quill Delta
  final bool pinned;
  final DateTime updatedAt;
  final List<String> tags;
  final String? folderId;
  final String? color; // Hex string e.g. '#FF5252'
  final String _plainText;

  // Create content JSON from a Document
  static String documentToContent(Document document) =>
      jsonEncode(document.toDelta().toJson());

  static String _parsePlainText(String content) {
    if (content.isEmpty) return '';
    try {
      final decoded = jsonDecode(content);
      final ops = decoded is Map ? decoded['ops'] ?? [] : decoded;
      if (ops is! List || ops.isEmpty) return '';
      return Document.fromJson(ops).toPlainText();
    } catch (e) {
      return '';
    }
  }

  // Parse document with error handling - returns empty Document if JSON is corrupted
  Document get document {
    if (content.isEmpty) return Document();
    try {
      final decoded = jsonDecode(content);
      final ops = decoded is Map ? decoded['ops'] ?? [] : decoded;
      if (ops is! List || ops.isEmpty) return Document();
      return Document.fromJson(ops);
    } catch (e) {
      return Document(); // Fallback to empty document
    }
  }

  // Get plain text from the Document for search/display
  // Pre-computed during construction to avoid parsing JSON repeatedly during search/render
  String get plainText => _plainText;

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
