import 'package:flutter_test/flutter_test.dart';

import 'package:fox/models/folder.dart';

void main() {
  group('Folder', () {
    late Folder folder;
    late DateTime created;

    setUp(() {
      created = DateTime(2025, 6, 1, 12, 0);
      folder = Folder(id: 'f-1', name: 'Work', createdAt: created);
    });

    test('stores id, name, and createdAt', () {
      expect(folder.id, 'f-1');
      expect(folder.name, 'Work');
      expect(folder.createdAt, created);
    });

    test('copyWith returns new Folder with updated name', () {
      final updated = folder.copyWith(name: 'Personal');
      expect(updated.name, 'Personal');
      expect(updated.id, folder.id);
      expect(updated.createdAt, folder.createdAt);
    });

    test('copyWith returns new Folder with updated id', () {
      final updated = folder.copyWith(id: 'f-2');
      expect(updated.id, 'f-2');
      expect(updated.name, folder.name);
    });

    test('copyWith returns new Folder with updated createdAt', () {
      final newDate = DateTime(2026, 1, 1);
      final updated = folder.copyWith(createdAt: newDate);
      expect(updated.createdAt, newDate);
    });

    test('copyWith with no arguments returns equivalent folder', () {
      final copy = folder.copyWith();
      expect(copy.id, folder.id);
      expect(copy.name, folder.name);
      expect(copy.createdAt, folder.createdAt);
    });
  });
}
