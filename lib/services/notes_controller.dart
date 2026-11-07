import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:fox/models/folder.dart';
import 'package:fox/models/note.dart';
import 'package:fox/services/constants.dart';
import 'package:fox/services/repository_hive.dart';
import 'package:fox/services/settings_service.dart';
import 'package:uuid/uuid.dart';

enum SortBy {
  titleAsc,
  titleDesc,
  dateAsc,
  dateDesc,
}

class NotesController extends ChangeNotifier {
  NotesController(this._repo, {SettingsService? settingsRepository})
      : _settingsRepository = settingsRepository ?? SettingsService();
  final NoteAndFolderRepository _repo;

  final SettingsService _settingsRepository;

  static const Uuid _uuid = Uuid();

  bool _loading = false;
  bool get loading => _loading;

  SortBy _sortBy = SortBy.dateDesc;
  SortBy get sortBy => _sortBy;

  bool _showTags = true;
  bool get showTags => _showTags;

  bool _showContent = true;
  bool get showContent => _showContent;

  bool _alternatingColors = false;
  bool get alternatingColors => _alternatingColors;

  bool _fabAnimation = true;
  bool get fabAnimation => _fabAnimation;

  List<Note> _unfilteredNotes = const [];
  List<Note> _visibleNotes = const [];
  List<Note> get notes => _visibleNotes;

  bool get hasNotes => _unfilteredNotes.isNotEmpty;

  Note? _lastRemovedNote;
  Note? get lastRemovedNote => _lastRemovedNote;

  String _searchTerm = '';
  String get searchTerm => _searchTerm;
  String _lastSearchTerm = '';

  List<Folder> _folders = const [];
  List<Folder> get folders => _folders;

  String? _selectedFolderId;
  String? get selectedFolderId => _selectedFolderId;

  String? _selectedTag;
  String? get selectedTag => _selectedTag;

  _TagRename? _lastTagRename;

  /// Every tag in use, mapped to the number of notes carrying it. Ordered by
  /// note count (descending) and then alphabetically, so the chip row and the
  /// tag manager stay stable between rebuilds.
  Map<String, int> get tagCounts {
    final counts = <String, int>{};
    for (final note in _unfilteredNotes) {
      for (final tag in note.tags) {
        counts[tag] = (counts[tag] ?? 0) + 1;
      }
    }
    final entries = counts.entries.toList()
      ..sort((a, b) {
        final byCount = b.value.compareTo(a.value);
        return byCount != 0 ? byCount : a.key.compareTo(b.key);
      });
    return {for (final entry in entries) entry.key: entry.value};
  }

  List<String> get allTags => tagCounts.keys.toList(growable: false);

  /// Tag completions for [query]. Returns nothing until at least two
  /// characters have been typed, and skips tags already in [exclude].
  List<String> suggestTags(String query, {List<String> exclude = const []}) {
    final needle = query.trim().toLowerCase();
    if (needle.length < 2) return const [];
    return allTags
        .where((tag) => tag.startsWith(needle) && !exclude.contains(tag))
        .take(5)
        .toList(growable: false);
  }

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    await _repo.init();
    _unfilteredNotes = await _repo.getAll();
    _folders = await _repo.getAllFolders();
    _loadSettings();
    _updateView();
    _loading = false;
    notifyListeners();
  }

  void _loadSettings() {
    _showTags = _settingsRepository.getShowTags();
    _showContent = _settingsRepository.getShowContent();
    _alternatingColors = _settingsRepository.getAlternatingColors();
    _fabAnimation = _settingsRepository.getFabAnimation();
    final sortStr = _settingsRepository.getSortBy();
    final sort = SortBy.values.where((e) => e.name == sortStr).firstOrNull;
    if (sort != null) _sortBy = sort;
  }

  void _updateView() {
    _visibleNotes = _filterAndSort(_unfilteredNotes);
  }

  void setSearchTerm(String term) {
    _searchTerm = term;
    if (term == _lastSearchTerm) return;
    _lastSearchTerm = term;
    _updateView();
    notifyListeners();
  }

  void setSortBy(SortBy value) {
    _sortBy = value;
    _updateView();
    notifyListeners();
  }

  void setShowTags(bool value) {
    _showTags = value;
    notifyListeners();
  }

  void setShowContent(bool value) {
    _showContent = value;
    notifyListeners();
  }

  void setAlternatingColors(bool value) {
    _alternatingColors = value;
    notifyListeners();
  }

  void setFabAnimation(bool value) {
    _fabAnimation = value;
    notifyListeners();
  }

  void setSelectedFolder(String? folderId) {
    _selectedFolderId = folderId;
    _updateView();
    notifyListeners();
  }

  void setSelectedTag(String? tag) {
    _selectedTag = tag?.trim().toLowerCase();
    _updateView();
    notifyListeners();
  }

  /// Renames [from] to [to] across every note that carries it. Notes that
  /// already have [to] are merged rather than duplicated.
  Future<void> renameTag(String from, String to) async {
    final source = from.trim().toLowerCase();
    final target = to.trim().toLowerCase();
    if (source.isEmpty || target.isEmpty || source == target) return;

    final previous = <Note>[];
    final updated = <Note>[];
    for (final note in _unfilteredNotes) {
      if (!note.tags.contains(source)) continue;
      final tags = <String>[];
      for (final tag in note.tags) {
        final next = tag == source ? target : tag;
        if (!tags.contains(next)) tags.add(next);
      }
      previous.add(note);
      updated.add(note.copyWith(tags: tags, updatedAt: DateTime.now()));
    }
    if (updated.isEmpty) return;

    await _repo.upsertAll(updated);
    _lastTagRename = _TagRename(
      previous: previous,
      previousSelectedTag: _selectedTag,
    );
    final updatedIds = updated.map((note) => note.id).toSet();
    _unfilteredNotes = [
      ..._unfilteredNotes.where((note) => !updatedIds.contains(note.id)),
      ...updated,
    ];
    if (_selectedTag == source) _selectedTag = target;
    _updateView();
    notifyListeners();
  }

  /// Reverses the last [renameTag], putting every affected note back.
  Future<void> undoRenameTag() async {
    final rename = _lastTagRename;
    if (rename == null) return;
    await _repo.upsertAll(rename.previous);
    final restoredIds = rename.previous.map((note) => note.id).toSet();
    _unfilteredNotes = [
      ..._unfilteredNotes.where((note) => !restoredIds.contains(note.id)),
      ...rename.previous,
    ];
    _selectedTag = rename.previousSelectedTag;
    if (identical(_lastTagRename, rename)) _lastTagRename = null;
    _updateView();
    notifyListeners();
  }

  /// Removes [tag] from every note. The notes themselves are kept.
  Future<void> deleteTag(String tag) async {
    final target = tag.trim().toLowerCase();
    if (target.isEmpty) return;

    final updated = <Note>[];
    for (final note in _unfilteredNotes) {
      if (!note.tags.contains(target)) continue;
      updated.add(
        note.copyWith(
          tags: note.tags.where((t) => t != target).toList(growable: false),
          updatedAt: DateTime.now(),
        ),
      );
    }
    if (updated.isEmpty) return;

    await _repo.upsertAll(updated);
    _lastTagRename = null;
    final updatedIds = updated.map((note) => note.id).toSet();
    _unfilteredNotes = [
      ..._unfilteredNotes.where((note) => !updatedIds.contains(note.id)),
      ...updated,
    ];
    if (_selectedTag == target) _selectedTag = null;
    _updateView();
    notifyListeners();
  }

  Future<void> addFolder(String name) async {
    final folder = Folder(
      id: _uuid.v4(),
      name: name.trim(),
      createdAt: DateTime.now(),
    );
    await _repo.upsertFolder(folder);
    _folders = [..._folders, folder];
    notifyListeners();
  }

  Future<void> renameFolder(String id, String newName) async {
    final folder = _folders.firstWhereOrNull((f) => f.id == id);
    if (folder == null) return;
    final updated = folder.copyWith(name: newName.trim());
    await _repo.upsertFolder(updated);
    _folders = _folders.map((f) => f.id == id ? updated : f).toList();
    notifyListeners();
  }

  List<Note> _clearFolderFrom(List<Note> notes, String folderId, DateTime now) {
    return notes
        .map((n) => n.folderId == folderId
            ? n.copyWith(clearFolder: true, updatedAt: now)
            : n)
        .toList();
  }

  Future<void> deleteFolder(String id) async {
    final now = DateTime.now();
    final cleared = _clearFolderFrom(_unfilteredNotes, id, now);
    final batch = [
      for (var i = 0; i < cleared.length; i++)
        if (_unfilteredNotes[i].folderId == id) cleared[i],
    ];
    if (batch.isNotEmpty) await _repo.upsertAll(batch);
    await _repo.deleteFolder(id);
    _folders = _folders.where((f) => f.id != id).toList();
    if (_selectedFolderId == id) {
      _selectedFolderId = null;
    }
    _unfilteredNotes = cleared;
    _updateView();
    notifyListeners();
  }

  String? getFolderName(String? folderId) {
    if (folderId == null) return null;
    return _folders.firstWhereOrNull((f) => f.id == folderId)?.name;
  }

  Future<void> addOrUpdate({
    required String title,
    required Document content,
    String? id,
    bool pinned = false,
    List<String> tags = const [],
    String? folderId,
    String? color,
  }) async {
    final trimmedTitle = title.trim();
    final plainText = content.toPlainText().trim();

    if (trimmedTitle.isEmpty && plainText.isEmpty) {
      throw ArgumentError(
          'Note cannot be empty - title and content are both blank');
    }

    final note = Note(
      id: id ?? _uuid.v4(),
      title: trimmedTitle,
      content: Note.documentToContent(content),
      pinned: pinned,
      updatedAt: DateTime.now(),
      tags: tags,
      folderId: folderId,
      color: color,
    );
    await _repo.upsert(note);
    _lastRemovedNote = null;
    _unfilteredNotes = [
      ...(_unfilteredNotes.where((n) => n.id != note.id)),
      note,
    ];
    _updateView();
    notifyListeners();
  }

  Future<void> setPinned(String id, bool pinned) async {
    final note = _unfilteredNotes.firstWhereOrNull((n) => n.id == id);
    if (note == null) return;
    final updated = note.copyWith(pinned: pinned, updatedAt: DateTime.now());
    await _repo.upsert(updated);
    _lastRemovedNote = null;
    _unfilteredNotes = [
      ...(_unfilteredNotes.where((n) => n.id != id)),
      updated,
    ];
    _updateView();
    notifyListeners();
  }

  Future<void> remove(String id) async {
    final note = _unfilteredNotes.firstWhereOrNull((n) => n.id == id);
    if (note == null) return;
    await _repo.delete(id);
    _lastRemovedNote = note;
    _unfilteredNotes = _unfilteredNotes.where((n) => n.id != id).toList();
    _updateView();
    notifyListeners();
  }

  Future<void> undoRemove() async {
    final note = _lastRemovedNote;
    if (note != null) {
      await _repo.upsert(note);
      _unfilteredNotes = [..._unfilteredNotes, note];
      if (identical(_lastRemovedNote, note)) {
        _lastRemovedNote = null;
      }
      _updateView();
      notifyListeners();
    }
  }

  Note? find(String id) => _unfilteredNotes.firstWhereOrNull((n) => n.id == id);

  List<Note> _filterAndSort(List<Note> list) {
    final copy = [...list];

    if (_selectedFolderId != null) {
      if (_selectedFolderId == AppConstants.unfiledFolderId) {
        copy.retainWhere((note) => note.folderId == null);
      } else {
        copy.retainWhere((note) => note.folderId == _selectedFolderId);
      }
    }

    if (_selectedTag != null) {
      copy.retainWhere((note) => note.tags.contains(_selectedTag));
    }

    if (_searchTerm.isNotEmpty) {
      final term = _searchTerm.toLowerCase();
      copy.retainWhere(
        (note) =>
            note.lowerTitle.contains(term) ||
            note.plainText.toLowerCase().contains(term) ||
            note.lowerTags.any((t) => t.contains(term)),
      );
    }

    copy.sort((a, b) {
      if (a.pinned != b.pinned) return a.pinned ? -1 : 1;

      switch (_sortBy) {
        case SortBy.titleAsc:
          return a.title.compareTo(b.title);
        case SortBy.titleDesc:
          return b.title.compareTo(a.title);
        case SortBy.dateAsc:
          return a.updatedAt.compareTo(b.updatedAt);
        case SortBy.dateDesc:
          return b.updatedAt.compareTo(a.updatedAt);
      }
    });
    return copy;
  }
}

/// Snapshot of the notes touched by the last tag rename, kept so the rename
/// can be undone from the snackbar.
class _TagRename {
  _TagRename({
    required this.previous,
    required this.previousSelectedTag,
  });

  final List<Note> previous;
  final String? previousSelectedTag;
}
