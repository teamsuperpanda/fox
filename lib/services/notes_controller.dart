import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'repository.dart';
import '../models/note.dart';
import '../models/folder.dart';

enum SortBy {
  titleAsc,
  titleDesc,
  dateAsc,
  dateDesc,
}

class NotesController extends ChangeNotifier {
  final NoteRepository _repo;
  NotesController(this._repo);

  static const Uuid _uuid = Uuid();
  static const String unfiledFolderId = '__unfiled__';

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

  List<Note> _allNotes = const [];
  List<Note> _notes = const [];
  List<Note> get notes => _notes;

  /// Whether any notes exist at all, regardless of the active search filter.
  bool get hasNotes => _allNotes.isNotEmpty;

  Note? _lastRemovedNote;
  Note? get lastRemovedNote => _lastRemovedNote;

  String _searchTerm = '';
  String get searchTerm => _searchTerm;

  // Folder support
  List<Folder> _folders = const [];
  List<Folder> get folders => _folders;

  String? _selectedFolderId;
  String? get selectedFolderId => _selectedFolderId;

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    await _repo.init();
    _allNotes = await _repo.getAll();
    _folders = await _repo.getAllFolders();
    _updateView();
    _loading = false;
    notifyListeners();
  }

  void _updateView() {
    _notes = _sorted(_allNotes);
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

  // Folder filter
  void setSelectedFolder(String? folderId) {
    _selectedFolderId = folderId;
    _updateView();
    notifyListeners();
  }

  // Folder CRUD
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
    final folder = _folders.firstWhere((f) => f.id == id);
    final updated = folder.copyWith(name: newName.trim());
    await _repo.upsertFolder(updated);
    _folders = _folders.map((f) => f.id == id ? updated : f).toList();
    notifyListeners();
  }

  Future<void> deleteFolder(String id) async {
    await _repo.deleteFolder(id);
    _folders = _folders.where((f) => f.id != id).toList();
    // Clear folder assignment from notes in this folder in a single pass
    final now = DateTime.now();
    _allNotes = await Future.wait(_allNotes.map((note) async {
      if (note.folderId != id) return note;
      final updated = note.copyWith(clearFolder: true, updatedAt: now);
      await _repo.upsert(updated);
      return updated;
    }));
    if (_selectedFolderId == id) {
      _selectedFolderId = null;
    }
    _updateView();
    notifyListeners();
  }

  String? getFolderName(String? folderId) {
    if (folderId == null) return null;
    try {
      return _folders.firstWhere((f) => f.id == folderId).name;
    } catch (_) {
      return null;
    }
  }

  Future<void> addOrUpdate({
    String? id,
    required String title,
    required Document content,
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
    _allNotes = [
      ...(_allNotes.where((n) => n.id != note.id)),
      note,
    ];
    _updateView();
    notifyListeners();
  }

  Future<void> setPinned(String id, bool pinned) async {
    final note = _allNotes.firstWhere((n) => n.id == id);
    final updated = note.copyWith(pinned: pinned, updatedAt: DateTime.now());
    await _repo.upsert(updated);
    _lastRemovedNote = null;
    _allNotes = [
      ...(_allNotes.where((n) => n.id != id)),
      updated,
    ];
    _updateView();
    notifyListeners();
  }

  Future<void> remove(String id) async {
    _lastRemovedNote = _allNotes.firstWhere((n) => n.id == id);
    await _repo.delete(id);
    _allNotes = _allNotes.where((n) => n.id != id).toList();
    _updateView();
    notifyListeners();
  }

  Future<void> undoRemove() async {
    if (_lastRemovedNote != null) {
      await _repo.upsert(_lastRemovedNote!);
      _allNotes = [..._allNotes, _lastRemovedNote!];
      _lastRemovedNote = null;
      _updateView();
      notifyListeners();
    }
  }

  Note? find(String id) {
    try {
      return _notes.firstWhere((n) => n.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Note> _sorted(List<Note> list) {
    final copy = [...list];

    // Folder filter
    if (_selectedFolderId != null) {
      if (_selectedFolderId == unfiledFolderId) {
        copy.retainWhere((note) => note.folderId == null);
      } else {
        copy.retainWhere((note) => note.folderId == _selectedFolderId);
      }
    }

    if (_searchTerm.isNotEmpty) {
      final term = _searchTerm.toLowerCase();
      copy.retainWhere((note) =>
          note.title.toLowerCase().contains(term) ||
          note.plainText.toLowerCase().contains(term) ||
          note.tags.any((tag) => tag.toLowerCase().contains(term)));
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
