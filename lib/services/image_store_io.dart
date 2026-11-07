import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

/// Stores note images inside the app documents directory.
///
/// The Quill Delta holds the path relative to the documents directory (for
/// example `attachments/0f2a.jpg`) rather than an absolute path, because the
/// iOS container path changes between installs and updates. Files are copied
/// in once, never read from the picker's temporary location afterwards.
///
/// This file and `image_store_stub.dart` must keep identical member
/// signatures; the stub is what the analyzer sees for the web target.
class ImageStore {
  ImageStore({String? rootPath}) : _rootPath = rootPath;

  static const attachmentsDirectory = 'attachments';
  static const _uuid = Uuid();

  String? _rootPath;

  bool get isSupported => true;

  bool get isReady => _rootPath != null;

  /// Resolves the documents directory once. Safe to call more than once.
  Future<void> init() async {
    if (_rootPath != null) return;
    final directory = await getApplicationDocumentsDirectory();
    _rootPath = directory.path;
  }

  Future<Directory> _attachmentsDir() async {
    await init();
    final dir = Directory(p.join(_rootPath!, attachmentsDirectory));
    if (!dir.existsSync()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Copies [sourcePath] into the attachments directory and returns the
  /// relative path to store in the Delta.
  Future<String> save(String sourcePath) async {
    final dir = await _attachmentsDir();
    final extension = p.extension(sourcePath).toLowerCase();
    final name = '${_uuid.v4()}$extension';
    await File(sourcePath).copy(p.join(dir.path, name));
    return p.join(attachmentsDirectory, name);
  }

  File _fileFor(String relativePath) => File(p.join(_rootPath!, relativePath));

  ImageProvider? imageProvider(String relativePath) {
    final root = _rootPath;
    if (root == null || relativePath.isEmpty) return null;
    return FileImage(File(p.join(root, relativePath)));
  }

  /// Deletes stored images that no note references any more. Paths outside
  /// the attachments directory are ignored, and a missing file is not an
  /// error. Failures deleting a single file are swallowed: losing a cleanup
  /// is better than failing the note operation that triggered it.
  Future<void> deleteUnreferenced(
    Iterable<String> candidates, {
    Iterable<String> stillReferenced = const [],
  }) async {
    final root = _rootPath;
    if (root == null) return;
    final referenced = stillReferenced.toSet();
    for (final relativePath in candidates.toSet()) {
      if (referenced.contains(relativePath)) continue;
      if (!p.isWithin(attachmentsDirectory, relativePath) &&
          !p.equals(attachmentsDirectory, relativePath)) {
        continue;
      }
      final file = _fileFor(relativePath);
      try {
        if (file.existsSync()) await file.delete();
      } on FileSystemException catch (error) {
        debugPrint('Could not delete ${file.path}: $error');
      }
    }
  }
}
