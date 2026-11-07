import 'package:flutter_test/flutter_test.dart';
import 'package:fox/models/note.dart';
import 'package:fox/services/constants.dart';
import 'package:fox/services/notes_query.dart';

import 'test_helpers.dart';

void main() {
  group('NotesQuery', () {
    const query = NotesQuery();

    final apple = makeNote(
      title: 'Apple',
      content: r'{"ops":[{"insert":"fruit\n"}]}',
      updatedAt: DateTime(2025),
      tags: const ['work'],
    );
    final banana = makeNote(
      id: '2',
      title: 'Banana',
      content: r'{"ops":[{"insert":"yellow\n"}]}',
      updatedAt: DateTime(2025, 1, 2),
      tags: const ['personal'],
    );
    final car = makeNote(
      id: '3',
      title: 'Car',
      content: r'{"ops":[{"insert":"vehicle\n"}]}',
      updatedAt: DateTime(2025, 1, 3),
      folderId: 'folder-a',
    );

    List<String> titles(List<Note> notes) => notes.map((n) => n.title).toList();

    test('empty list stays empty', () {
      expect(query.apply([], sortBy: SortBy.dateDesc), isEmpty);
    });

    test('filters by folder id', () {
      final result = query.apply(
        [apple, banana, car],
        folderId: 'folder-a',
        sortBy: SortBy.dateDesc,
      );
      expect(titles(result), ['Car']);
    });

    test('unfiled filter keeps only notes without a folder', () {
      final result = query.apply(
        [apple, banana, car],
        folderId: AppConstants.unfiledFolderId,
        sortBy: SortBy.dateDesc,
      );
      expect(titles(result), ['Banana', 'Apple']);
    });

    test('searches titles, content and tags', () {
      expect(
        titles(query.apply([apple, banana, car],
            searchTerm: 'apple', sortBy: SortBy.dateDesc)),
        ['Apple'],
      );
      expect(
        titles(query.apply([apple, banana, car],
            searchTerm: 'vehicle', sortBy: SortBy.dateDesc)),
        ['Car'],
      );
      expect(
        titles(query.apply([apple, banana, car],
            searchTerm: 'PERSONAL', sortBy: SortBy.dateDesc)),
        ['Banana'],
      );
      expect(
        query.apply([apple, banana, car],
            searchTerm: 'nothing', sortBy: SortBy.dateDesc),
        isEmpty,
      );
    });

    test('sorts by title ascending and descending', () {
      expect(
        titles(query.apply([car, apple, banana], sortBy: SortBy.titleAsc)),
        ['Apple', 'Banana', 'Car'],
      );
      expect(
        titles(query.apply([apple, banana, car], sortBy: SortBy.titleDesc)),
        ['Car', 'Banana', 'Apple'],
      );
    });

    test('sorts by date ascending and descending', () {
      expect(
        titles(query.apply([banana, car, apple], sortBy: SortBy.dateAsc)),
        ['Apple', 'Banana', 'Car'],
      );
      expect(
        titles(query.apply([apple, car, banana], sortBy: SortBy.dateDesc)),
        ['Car', 'Banana', 'Apple'],
      );
    });

    test('pinned notes sort first in every order', () {
      final pinnedCar = car.copyWith(pinned: true);
      expect(
        titles(
            query.apply([apple, pinnedCar, banana], sortBy: SortBy.titleAsc)),
        ['Car', 'Apple', 'Banana'],
      );
    });

    test('does not mutate the input list order', () {
      final input = [car, apple, banana];
      query.apply(input, sortBy: SortBy.titleAsc);
      expect(input, [car, apple, banana]);
    });
  });
}
