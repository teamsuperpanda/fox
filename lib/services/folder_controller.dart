import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:fox/models/folder.dart';
import 'package:fox/services/repository.dart';
import 'package:uuid/uuid.dart';

class FolderController extends ChangeNotifier {
  FolderController(this._repo);
  final NoteAndFolderRepository _repo;

  static const Uuid _uuid = Uuid();

  List<Folder> _folders = const [];
  List<Folder> get folders => _folders;

  String? _selectedFolderId;
  String? get selectedFolderId => _selectedFolderId;

  Future<void> load() async {
    _folders = await _repo.getAllFolders();
  }

  void setSelectedFolder(String? folderId) {
    _selectedFolderId = folderId;
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

  Future<void> deleteFolder(String id) async {
    await _repo.deleteFolder(id);
    _folders = _folders.where((f) => f.id != id).toList();
    if (_selectedFolderId == id) {
      _selectedFolderId = null;
    }
    notifyListeners();
  }

  String? getFolderName(String? folderId) {
    if (folderId == null) return null;
    return _folders.firstWhereOrNull((f) => f.id == folderId)?.name;
  }
}
