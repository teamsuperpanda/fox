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

  /// Notes in the trash, newest deletion first.
  List<Note> _trashedNotes = const [];
  List<Note> get trash => _trashedNotes;

  bool get hasNotes => _unfilteredNotes.isNotEmpty;

  /// How many deletes can be undone in one session.
  static const int undoLimit = 10;

  final List<String> _undoStack = <String>[];

  bool get canUndo => _undoStack.isNotEmpty;

  Note? get lastRemovedNote =>
      _undoStack.isEmpty ? null : _findAny(_undoStack.last);

  String _searchTerm = '';
  String get searchTerm => _searchTerm;
  String _lastSearchTerm = '';

  List<Folder> _folders = const [];
  List<Folder> get folders => _folders;

  String? _selectedFolderId;
  String? get selectedFolderId => _selectedFolderId;

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    await _repo.init();
    final all = [...await _repo.getAll()];
    await _purgeExpired(all);
    _unfilteredNotes = all.where((n) => n.deletedAt == null).toList();
    _trashedNotes = all.where((n) => n.deletedAt != null).toList()
      ..sort((a, b) => b.deletedAt!.compareTo(a.deletedAt!));
    _folders = await _repo.getAllFolders();
    _loadSettings();
    _updateView();
    _loading = false;
    notifyListeners();
  }

  /// Permanently removes trashed notes older than [Note.trashRetention].
  Future<void> _purgeExpired(List<Note> notes) async {
    final cutoff = DateTime.now().subtract(Note.trashRetention);
    final expired = notes
        .where((n) => n.deletedAt != null && n.deletedAt!.isBefore(cutoff))
        .toList();
    for (final note in expired) {
      await _repo.delete(note.id);
    }
    notes.removeWhere((n) => expired.any((e) => e.id == n.id));
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
    _trashedNotes = _trashedNotes.where((n) => n.id != note.id).toList();
    _undoStack.remove(note.id);
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
    _unfilteredNotes = [
      ...(_unfilteredNotes.where((n) => n.id != id)),
      updated,
    ];
    _updateView();
    notifyListeners();
  }

  /// Moves a note to the trash. The note keeps its folder and timestamp so a
  /// restore puts it back where it was.
  Future<void> remove(String id) async {
    final note = _unfilteredNotes.firstWhereOrNull((n) => n.id == id);
    if (note == null) return;
    final trashed = note.copyWith(deletedAt: DateTime.now());
    await _repo.upsert(trashed);
    _unfilteredNotes = _unfilteredNotes.where((n) => n.id != id).toList();
    _trashedNotes = [trashed, ..._trashedNotes];
    _pushUndo(id);
    _updateView();
    notifyListeners();
  }

  void _pushUndo(String id) {
    _undoStack.add(id);
    if (_undoStack.length > undoLimit) {
      _undoStack.removeRange(0, _undoStack.length - undoLimit);
    }
  }

  /// Restores the most recently trashed note that still exists.
  Future<void> undoRemove() async {
    while (_undoStack.isNotEmpty) {
      final id = _undoStack.removeLast();
      final note = _trashedNotes.firstWhereOrNull((n) => n.id == id);
      if (note == null) continue;
      await restore(id);
      return;
    }
  }

  /// Restores one note from the trash.
  Future<void> restore(String id) async {
    final note = _trashedNotes.firstWhereOrNull((n) => n.id == id);
    if (note == null) return;
    final restored = note.copyWith(clearDeletedAt: true);
    await _repo.upsert(restored);
    _undoStack.remove(id);
    _trashedNotes = _trashedNotes.where((n) => n.id != id).toList();
    _unfilteredNotes = [..._unfilteredNotes, restored];
    _updateView();
    notifyListeners();
  }

  /// Deletes one trashed note for good.
  Future<void> deletePermanently(String id) async {
    if (!_trashedNotes.any((n) => n.id == id)) return;
    await _repo.delete(id);
    _undoStack.remove(id);
    _trashedNotes = _trashedNotes.where((n) => n.id != id).toList();
    notifyListeners();
  }

  /// Deletes every trashed note for good.
  Future<void> emptyTrash() async {
    for (final note in [..._trashedNotes]) {
      await _repo.delete(note.id);
    }
    _undoStack.clear();
    _trashedNotes = const [];
    notifyListeners();
  }

  Note? _findAny(String id) {
    return _unfilteredNotes.firstWhereOrNull((n) => n.id == id) ??
        _trashedNotes.firstWhereOrNull((n) => n.id == id);
  }

  Note? find(String id) => _findAny(id);

  List<Note> _filterAndSort(List<Note> list) {
    final copy = [...list];

    if (_selectedFolderId != null) {
      if (_selectedFolderId == AppConstants.unfiledFolderId) {
        copy.retainWhere((note) => note.folderId == null);
      } else {
        copy.retainWhere((note) => note.folderId == _selectedFolderId);
      }
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
