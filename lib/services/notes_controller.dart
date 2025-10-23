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
    final list = await _repo.getAll();
    _notes = _sorted(list);
    _loading = false;
    notifyListeners();
  }

  Future<void> setSearchTerm(String term) async {
    _searchTerm = term;
    await load();
  }

  Future<void> setSortBy(SortBy value) async {
    _sortBy = value;
    _notes = _sorted(_notes);
    notifyListeners();
  }

  Future<void> addOrUpdate({
    String? id,
    required String title,
    required Document content,
    bool pinned = false,
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
      copy.retainWhere((note) =>
          note.title.toLowerCase().contains(_searchTerm.toLowerCase()) ||
          note.plainText.toLowerCase().contains(_searchTerm.toLowerCase()));
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
