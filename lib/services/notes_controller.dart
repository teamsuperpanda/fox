import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:fox/models/folder.dart';
import 'package:fox/models/note.dart';
import 'package:fox/services/constants.dart';
import 'package:fox/services/folder_controller.dart';
import 'package:fox/services/repository.dart';
import 'package:fox/services/settings_service.dart';
import 'package:uuid/uuid.dart';

enum SortBy {
  titleAsc,
  titleDesc,
  dateAsc,
  dateDesc,
}

class NotesController extends ChangeNotifier {
  NotesController(this._repo, {SettingsService? settingsService})
      : _folder = FolderController(_repo),
        _settingsService = settingsService ?? SettingsService();
  final NoteAndFolderRepository _repo;

  final FolderController _folder;

  final SettingsService _settingsService;

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

  /// Whether any notes exist at all, regardless of the active search filter.
  bool get hasNotes => _unfilteredNotes.isNotEmpty;

  Note? _lastRemovedNote;
  Note? get lastRemovedNote => _lastRemovedNote;

  String _searchTerm = '';
  String get searchTerm => _searchTerm;

  // Folder support — delegated to [_folder]
  List<Folder> get folders => _folder.folders;
  String? get selectedFolderId => _folder.selectedFolderId;

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    await _repo.init();
    _unfilteredNotes = await _repo.getAll();
    await _folder.load();
    _loadSettings();
    _updateView();
    _loading = false;
    notifyListeners();
  }

  void _loadSettings() {
    try {
      final service = _settingsService;
      _showTags = service.getShowTags();
      _showContent = service.getShowContent();
      _alternatingColors = service.getAlternatingColors();
      _fabAnimation = service.getFabAnimation();
      final sortStr = service.getSortBy();
      final sort = SortBy.values.where((e) => e.name == sortStr).firstOrNull;
      if (sort != null) _sortBy = sort;
    } catch (e) {
      debugPrint('NotesController: failed to load settings: $e');
    }
  }

  void _updateView() {
    _visibleNotes = _filterAndSort(_unfilteredNotes);
  }

  void setSearchTerm(String term) {
    _searchTerm = term;
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
    _folder.setSelectedFolder(folderId);
    _updateView();
    notifyListeners();
  }

  // Folder CRUD
  Future<void> addFolder(String name) async {
    await _folder.addFolder(name);
    notifyListeners();
  }

  Future<void> renameFolder(String id, String newName) async {
    await _folder.renameFolder(id, newName);
    notifyListeners();
  }

  Future<void> deleteFolder(String id) async {
    await _folder.deleteFolder(id);
    final now = DateTime.now();
    final batch = <Note>[];
    for (final note in _unfilteredNotes) {
      if (note.folderId == id) {
        batch.add(note.copyWith(clearFolder: true, updatedAt: now));
      }
    }
    if (batch.isNotEmpty) await _repo.upsertAll(batch);
    _unfilteredNotes = _unfilteredNotes.map((n) => n.folderId == id ? n.copyWith(clearFolder: true, updatedAt: now) : n).toList();
    _updateView();
    notifyListeners();
  }

  String? getFolderName(String? folderId) => _folder.getFolderName(folderId);

  Future<void> addOrUpdate({
    required String title, required Document content, String? id,
    bool pinned = false,
    List<String> tags = const [],
    String? folderId,
    String? color,
  }) async {
    // Validate input
    final trimmedTitle = title.trim();
    final plainText = content.toPlainText().trim();
    
    if (trimmedTitle.isEmpty && plainText.isEmpty) {
      throw ArgumentError('Note cannot be empty - title and content are both blank');
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
    _lastRemovedNote = _unfilteredNotes.firstWhereOrNull((n) => n.id == id);
    if (_lastRemovedNote == null) return;
    await _repo.delete(id);
    _unfilteredNotes = _unfilteredNotes.where((n) => n.id != id).toList();
    _updateView();
    notifyListeners();
  }

  Future<void> undoRemove() async {
    if (_lastRemovedNote != null) {
      await _repo.upsert(_lastRemovedNote!);
      _unfilteredNotes = [..._unfilteredNotes, _lastRemovedNote!];
      _lastRemovedNote = null;
      _updateView();
      notifyListeners();
    }
  }

  Note? find(String id) => _unfilteredNotes.firstWhereOrNull((n) => n.id == id);

  List<Note> _filterAndSort(List<Note> list) {
    final copy = [...list];

    // Folder filter
    if (_folder.selectedFolderId != null) {
      if (_folder.selectedFolderId == AppConstants.unfiledFolderId) {
        copy.retainWhere((note) => note.folderId == null);
      } else {
        copy.retainWhere((note) => note.folderId == _folder.selectedFolderId);
      }
    }

    if (_searchTerm.isNotEmpty) {
      final term = _searchTerm.toLowerCase();
      copy.retainWhere((note) =>
          note.title.toLowerCase().contains(term) ||
          note.plainText.toLowerCase().contains(term) ||
          note.tags.any((tag) => tag.toLowerCase().contains(term)),);
    }

    copy.sort((a, b) {
      if (a.pinned != b.pinned) return a.pinned ? -1 : 1; // pinned first

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
