import 'package:flutter_test/flutter_test.dart';

import 'package:fox/models/folder.dart';

void main() {
  group('Folder', () {
    late Folder folder;
    late DateTime created;

    setUp(() {
      created = DateTime(2025, 6, 1, 12);
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
      final newDate = DateTime(2026);
      final updated = folder.copyWith(createdAt: newDate);
      expect(updated.createdAt, newDate);
    });

    test('copyWith with no arguments returns equivalent folder', () {
      final copy = folder.copyWith();
      expect(copy.id, folder.id);
      expect(copy.name, folder.name);
      expect(copy.createdAt, folder.createdAt);
    });

    test('icon and colour default to null', () {
      expect(folder.icon, isNull);
      expect(folder.color, isNull);
    });

    test('copyWith sets and clears the icon and colour', () {
      final decorated = folder.copyWith(icon: 'work', color: '#AB47BC');
      expect(decorated.icon, 'work');
      expect(decorated.color, '#AB47BC');

      final stripped = decorated.copyWith(clearIcon: true, clearColor: true);
      expect(stripped.icon, isNull);
      expect(stripped.color, isNull);
      expect(stripped.id, folder.id);
    });

    test('copyWith keeps the icon and colour when not passed', () {
      final decorated = folder.copyWith(icon: 'work', color: '#AB47BC');
      final renamed = decorated.copyWith(name: 'Renamed');
      expect(renamed.icon, 'work');
      expect(renamed.color, '#AB47BC');
    });
  });
}
