import 'package:flutter/foundation.dart';

/// Filters applied on top of the note list and search results.
@immutable
class SearchFilters {
  const SearchFilters({
    this.tag,
    this.pinnedOnly = false,
    this.color,
    this.from,
    this.to,
  });

  /// Tag to match. Comparison is case insensitive.
  final String? tag;
  final bool pinnedOnly;

  /// Note colour as a `#RRGGBB` hex string.
  final String? color;

  /// Inclusive start of the last-updated range.
  final DateTime? from;

  /// Inclusive end of the last-updated range.
  final DateTime? to;

  bool get isActive =>
      tag != null || pinnedOnly || color != null || from != null || to != null;

  SearchFilters copyWith({
    String? tag,
    bool clearTag = false,
    bool? pinnedOnly,
    String? color,
    bool clearColor = false,
    DateTime? from,
    DateTime? to,
    bool clearDates = false,
  }) {
    return SearchFilters(
      tag: clearTag ? null : (tag ?? this.tag),
      pinnedOnly: pinnedOnly ?? this.pinnedOnly,
      color: clearColor ? null : (color ?? this.color),
      from: clearDates ? null : (from ?? this.from),
      to: clearDates ? null : (to ?? this.to),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchFilters &&
          runtimeType == other.runtimeType &&
          tag == other.tag &&
          pinnedOnly == other.pinnedOnly &&
          color == other.color &&
          from == other.from &&
          to == other.to;

  @override
  int get hashCode => Object.hash(tag, pinnedOnly, color, from, to);
}
