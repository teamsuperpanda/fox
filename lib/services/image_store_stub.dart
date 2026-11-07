import 'package:flutter/widgets.dart';

/// Web fallback for [ImageStore]: the browser build has no writable documents
/// directory and no local file paths, so image attachments are unavailable.
///
/// This file and `image_store_io.dart` must keep identical member signatures.
class ImageStore {
  ImageStore({
    // Ignored on the web; kept so the constructor matches the IO store.
    // ignore: avoid_unused_constructor_parameters
    String? rootPath,
  });

  static const attachmentsDirectory = 'attachments';

  bool get isSupported => false;

  bool get isReady => false;

  Future<void> init() async {}

  Future<String> save(String sourcePath) async {
    throw UnsupportedError('Image attachments are not available on the web');
  }

  ImageProvider? imageProvider(String relativePath) => null;

  Future<void> deleteUnreferenced(
    Iterable<String> candidates, {
    Iterable<String> stillReferenced = const [],
  }) async {}
}
