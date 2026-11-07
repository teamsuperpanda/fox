import 'package:fox/models/note.dart';
import 'package:fox/services/constants.dart';

enum SortBy {
  titleAsc,
  titleDesc,
  dateAsc,
  dateDesc,
}

/// Pure filter and sort logic for the note list.
///
/// Has no repository, no notifier and no state, so it can be tested with plain
/// lists. `NotesController` owns the mutable inputs and calls [apply].
class NotesQuery {
  const NotesQuery();

  /// Returns the notes visible for [folderId] and [searchTerm] in [sortBy]
  /// order. Pinned notes always sort first. The input list is not mutated.
  List<Note> apply(
    List<Note> notes, {
    required SortBy sortBy,
    String? folderId,
    String searchTerm = '',
  }) {
    final copy = [...notes];

    if (folderId != null) {
      if (folderId == AppConstants.unfiledFolderId) {
        copy.retainWhere((note) => note.folderId == null);
      } else {
        copy.retainWhere((note) => note.folderId == folderId);
      }
    }

    if (searchTerm.isNotEmpty) {
      final term = searchTerm.toLowerCase();
      copy.retainWhere(
        (note) =>
            note.lowerTitle.contains(term) ||
            note.plainText.toLowerCase().contains(term) ||
            note.lowerTags.any((t) => t.contains(term)),
      );
    }

    copy.sort((a, b) => _compare(a, b, sortBy));
    return copy;
  }

  int _compare(Note a, Note b, SortBy sortBy) {
    if (a.pinned != b.pinned) return a.pinned ? -1 : 1;

    switch (sortBy) {
      case SortBy.titleAsc:
        return a.title.compareTo(b.title);
      case SortBy.titleDesc:
        return b.title.compareTo(a.title);
      case SortBy.dateAsc:
        return a.updatedAt.compareTo(b.updatedAt);
      case SortBy.dateDesc:
        return b.updatedAt.compareTo(a.updatedAt);
    }
  }
}
