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

  List<Note> _clearFolderFrom(List<Note> notes, String folderId) {
    return notes
        .map((n) => n.folderId == folderId ? n.copyWith(clearFolder: true) : n)
        .toList();
  }

  Folder? _lastDeletedFolder;
  Folder? get lastDeletedFolder => _lastDeletedFolder;
  int _lastDeletedFolderIndex = 0;
  List<String> _lastDeletedFolderNoteIds = const [];

  /// Deletes [id] and unfiles its notes without touching their timestamps.
  /// The folder and its memberships stay in memory so [undoDeleteFolder] can
  /// put them back while the snackbar is visible.
  Future<void> deleteFolder(String id) async {
    final folder = _folders.firstWhereOrNull((f) => f.id == id);
    if (folder == null) return;

    final members =
        _unfilteredNotes.where((n) => n.folderId == id).toList(growable: false);
    final unfiled = _clearFolderFrom(members, id);

    try {
      if (unfiled.isNotEmpty) await _repo.upsertAll(unfiled);
      await _repo.deleteFolder(id);
    } catch (e) {
      // Put the memberships back so a failed delete leaves state unchanged.
      if (unfiled.isNotEmpty) {
        try {
          await _repo.upsertAll(members);
        } catch (_) {
          // Nothing more we can do; the caller reports the original error.
        }
      }
      rethrow;
    }

    final unfiledById = {for (final n in unfiled) n.id: n};
    _unfilteredNotes = [
      for (final note in _unfilteredNotes) unfiledById[note.id] ?? note,
    ];
    _lastDeletedFolder = folder;
    _lastDeletedFolderIndex = _folders.indexWhere((f) => f.id == id);
    _folders = _folders.where((f) => f.id != id).toList();
    _lastDeletedFolderNoteIds = [for (final n in members) n.id];
    if (_selectedFolderId == id) {
      // Land on the notes that just moved out of the folder.
      _selectedFolderId = AppConstants.unfiledFolderId;
    }
    _updateView();
    notifyListeners();
  }

  /// Restores the folder deleted last, together with its memberships.
  Future<void> undoDeleteFolder() async {
    final folder = _lastDeletedFolder;
    if (folder == null) return;
    final ids = _lastDeletedFolderNoteIds.toSet();
    final restored = [
      for (final note in _unfilteredNotes)
        if (ids.contains(note.id)) note.copyWith(folderId: folder.id),
    ];

    await _repo.upsertFolder(folder);
    if (restored.isNotEmpty) await _repo.upsertAll(restored);

    final restoredById = {for (final n in restored) n.id: n};
    _unfilteredNotes = [
      for (final note in _unfilteredNotes) restoredById[note.id] ?? note,
    ];
    _folders = [..._folders]
      ..insert(_lastDeletedFolderIndex.clamp(0, _folders.length), folder);
    _lastDeletedFolder = null;
    _lastDeletedFolderNoteIds = const [];
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
