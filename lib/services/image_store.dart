// Platform-specific image storage: `dart:io` on mobile and desktop, a stub on
// the web where the app has no writable documents directory.
export 'image_store_stub.dart' if (dart.library.io) 'image_store_io.dart';
