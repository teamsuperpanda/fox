import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter_quill/flutter_quill.dart';

class Note {
  final String id;
  final String title;
  final String content; // JSON string representing Quill Delta
  final bool pinned;
  final DateTime updatedAt;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.pinned,
    required this.updatedAt,
  });

  // Create content JSON from a Document
  static String documentToContent(Document document) => jsonEncode(document.toDelta().toJson());
  
  // Parse document with error handling - returns empty Document if JSON is corrupted
  Document get document {
    if (content.isEmpty) return Document();
    try {
      final decoded = jsonDecode(content);
      return Document.fromJson(decoded);
    } catch (e) {
      debugPrint('❌ Error parsing note document: $e');
      debugPrint('   Corrupted content: ${content.substring(0, math.min(100, content.length))}...');
      return Document(); // Fallback to empty document
    }
  }

  // Get plain text from the Document for search/display
  String get plainText => document.toPlainText();

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