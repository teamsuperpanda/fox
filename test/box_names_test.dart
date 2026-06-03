import 'package:flutter_test/flutter_test.dart';

import 'package:fox/services/box_names.dart';

void main() {
  group('BoxNames', () {
    test('notes constant equals notes_db', () {
      expect(BoxNames.notes, 'notes_db');
    });

    test('folders constant equals folders_db', () {
      expect(BoxNames.folders, 'folders_db');
    });

    test('settings constant equals settings_db', () {
      expect(BoxNames.settings, 'settings_db');
    });

    test('all box names are unique', () {
      final names = [
        BoxNames.notes,
        BoxNames.folders,
        BoxNames.settings,
      ];
      expect(names.toSet().length, names.length);
    });
  });
}
