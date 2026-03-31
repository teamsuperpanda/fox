import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:fox/models/folder.dart';
import 'package:fox/models/folder_adapter.dart';

void main() {
  group('FolderAdapter', () {
    late FolderAdapter adapter;

    setUp(() {
      adapter = FolderAdapter();
    });

    test('typeId is 4', () {
      expect(adapter.typeId, 4);
    });

    test('equality between identical adapters', () {
      final other = FolderAdapter();
      expect(adapter == other, isTrue);
    });

    test('hashCode is consistent with typeId', () {
      expect(adapter.hashCode, adapter.typeId.hashCode);
    });

    test('round-trip write and read preserves data', () async {
      Hive.init('./test/hive_folder_adapter_test');
      if (!Hive.isAdapterRegistered(4)) {
        Hive.registerAdapter(FolderAdapter());
      }

      final box = await Hive.openBox('folder_adapter_test');
      final original = Folder(
        id: 'abc-123',
        name: 'My Folder',
        createdAt: DateTime(2025, 7, 4, 15, 30),
      );

      await box.put('testFolder', original);

      // Read back via Hive low-level API
      final bytes = box.get('testFolder');
      // Hive returns the deserialized object directly
      expect(bytes, isA<Folder>());
      final restored = bytes as Folder;

      expect(restored.id, original.id);
      expect(restored.name, original.name);
      expect(restored.createdAt, original.createdAt);

      await box.close();
      await Hive.deleteFromDisk();
    });
  });
}
