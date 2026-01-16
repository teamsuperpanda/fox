import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'repository.dart';
import '../models/note.dart';

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

  Note? _lastRemovedNote;
  Note? get lastRemovedNote => _lastRemovedNote;

  String _searchTerm = '';
  String get searchTerm => _searchTerm;

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    await _repo.init();
    _allNotes = await _repo.getAll();
    _updateView();
    _loading = false;
    notifyListeners();
  }

  void _updateView() {
    _notes = _sorted(_allNotes);
  }

  Future<void> setSearchTerm(String term) async {
    _searchTerm = term;
    _updateView();
    notifyListeners();
  }

  Future<void> setSortBy(SortBy value) async {
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

  Future<void> addOrUpdate({
    String? id,
    required String title,
    required Document content,
    bool pinned = false,
    List<String> tags = const [],
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
    );
    await _repo.upsert(note);
    await load();
  }

  Future<void> setPinned(String id, bool pinned) async {
    final note = _notes.firstWhere((n) => n.id == id);
    await _repo
        .upsert(note.copyWith(pinned: pinned, updatedAt: DateTime.now()));
    await load();
  }

  Future<void> remove(String id) async {
    _lastRemovedNote = _notes.firstWhere((n) => n.id == id);
    await _repo.delete(id);
    await load();
  }

  Future<void> undoRemove() async {
    if (_lastRemovedNote != null) {
      await _repo.upsert(_lastRemovedNote!);
      _lastRemovedNote = null;
      await load();
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
