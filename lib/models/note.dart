import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_quill/flutter_quill.dart';

/// Whether a note's stored Delta JSON can be read back into an editor.
enum NoteContentStatus {
  /// A valid Quill Delta that can be opened and edited.
  valid,

  /// No content, or an empty Delta.
  empty,

  /// Content that cannot be parsed. It must never be replaced by an empty
  /// document.
  unparseable,
}

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
  NoteContentStatus? _contentStatus;
  final String _lowerTitle;
  final List<String> _lowerTags;

  String get lowerTitle => _lowerTitle;
  List<String> get lowerTags => _lowerTags;

  // Create content JSON from a Document
  static String documentToContent(Document document) =>
      jsonEncode(document.toDelta().toJson());

  /// The parse state of [content]. Cached after the first access.
  NoteContentStatus get contentStatus {
    final cached = _contentStatus;
    if (cached != null) return cached;
    final status = _classifyContent(content);
    _contentStatus = status;
    if (status == NoteContentStatus.unparseable) {
      // Note id only, never the content.
      debugPrint('Fox: unparseable note content (note $id)');
    }
    return status;
  }

  /// Text used by search. Unparseable notes fall back to the raw stored
  /// content so they stay findable instead of disappearing from search.
  String get searchableText =>
      contentStatus == NoteContentStatus.unparseable ? content : plainText;

  static NoteContentStatus _classifyContent(String content) {
    final trimmed = content.trim();
    if (trimmed.isEmpty) return NoteContentStatus.empty;

    final Object? decoded;
    try {
      decoded = jsonDecode(trimmed);
    } catch (_) {
      return NoteContentStatus.unparseable;
    }

    final List<dynamic> ops;
    if (decoded is List) {
      ops = decoded;
    } else if (decoded is Map) {
      if (!decoded.containsKey('ops')) {
        return decoded.isEmpty
            ? NoteContentStatus.empty
            : NoteContentStatus.unparseable;
      }
      final rawOps = decoded['ops'];
      if (rawOps is! List) return NoteContentStatus.unparseable;
      ops = rawOps;
    } else {
      return NoteContentStatus.unparseable;
    }

    if (ops.isEmpty) return NoteContentStatus.empty;
    if (!ops.every(_isValidOp)) return NoteContentStatus.unparseable;

    try {
      Document.fromJson(ops);
      return NoteContentStatus.valid;
    } catch (_) {
      return NoteContentStatus.unparseable;
    }
  }

  static bool _isValidOp(Object? op) {
    if (op is! Map) return false;
    final insert = op['insert'];
    if (insert is String) return true;
    if (insert is Map) {
      // A single string key identifies an embed. Anything else is malformed.
      return insert.length == 1 && insert.keys.single is String;
    }
    return false;
  }

  /// Parses the content. Returns an empty document for empty or unparseable
  /// content; callers that write back must check [contentStatus] first.
  Document get document {
    if (contentStatus != NoteContentStatus.valid) return Document();
    try {
      return Document.fromJson(_decodeOps(content));
    } catch (_) {
      return Document();
    }
  }

  // Get plain text from the Document for search/display.
  // Computed lazily and cached after the first access.
  String get plainText {
    final cached = _plainText;
    if (cached != null) return cached;
    final computed = contentStatus == NoteContentStatus.valid
        ? _parsePlainText(content)
        : '';
    _plainText = computed;
    return computed;
  }

  static String _parsePlainText(String content) {
    final ops = _decodeOps(content);
    if (ops.isEmpty) return '';
    try {
      return Document.fromJson(ops).toPlainText();
    } catch (e) {
      return '';
    }
  }

  static List<dynamic> _decodeOps(String content) {
    if (content.isEmpty) return const [];
    try {
      final decoded = jsonDecode(content);
      final ops = decoded is Map ? decoded['ops'] ?? [] : decoded;
      return ops is List ? ops : const [];
    } catch (e) {
      return const [];
    }
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
