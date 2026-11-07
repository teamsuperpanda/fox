import 'package:flutter_test/flutter_test.dart';
import 'package:fox/models/note.dart';
import 'package:fox/services/note_search.dart';

import 'test_helpers.dart';

String _body(String text) => '{"ops":[{"insert":"$text\\n"}]}';

void main() {
  group('foldText', () {
    test('lowercases and strips diacritics', () {
      expect(foldText('Café'), 'cafe');
      expect(foldText('STRASSE'), 'strasse');
      expect(foldText('Ångström'), 'angstrom');
      expect(foldText('naïve résumé'), 'naive resume');
    });

    test('keeps the same UTF-16 length as the input', () {
      for (final input in ['Café', '日本語', '😀 emoji', 'İstanbul']) {
        expect(foldText(input).length, input.length, reason: input);
      }
    });

    test('leaves CJK and emoji content searchable', () {
      expect(foldText('日本語 😀'), '日本語 😀');
    });
  });

  group('SearchQuery', () {
    test('splits into folded tokens', () {
      expect(SearchQuery('Tax 2025').tokens, ['tax', '2025']);
      expect(SearchQuery('  Café   ').tokens, ['cafe']);
      expect(SearchQuery('').isEmpty, isTrue);
      expect(SearchQuery('   ').isEmpty, isTrue);
    });
  });

  group('scoreNote', () {
    test('finds accented titles from an unaccented query', () {
      final note = makeNote(title: 'Café');
      expect(scoreNote(note, SearchQuery('cafe')), isNotNull);
      expect(scoreNote(note, SearchQuery('CAFÉ')), isNotNull);
    });

    test('finds accented body text from an unaccented query', () {
      final note = makeNote(title: 'Menu', content: _body('crème brûlée'));
      expect(scoreNote(note, SearchQuery('creme brulee')), isNotNull);
    });

    test('requires every token in any order', () {
      final note =
          makeNote(title: 'Return', content: _body('tax filing for 2025'));
      expect(scoreNote(note, SearchQuery('tax 2025')), isNotNull);
      expect(scoreNote(note, SearchQuery('2025 tax')), isNotNull);
      expect(scoreNote(note, SearchQuery('tax 2024')), isNull);
    });

    test('tolerates one typo in longer tokens', () {
      final note =
          makeNote(title: 'Shopping', content: _body('keep the receipt'));
      expect(scoreNote(note, SearchQuery('reciept')), isNotNull);
      expect(scoreNote(note, SearchQuery('recept')), isNotNull);
      // Tokens of four characters or fewer stay exact.
      expect(scoreNote(note, SearchQuery('rept')), isNull);
    });

    test('matches tags', () {
      final note = makeNote(title: 'Plan', tags: ['Work', 'Important']);
      expect(scoreNote(note, SearchQuery('work')), isNotNull);
    });

    test('matches CJK and emoji text', () {
      final note = makeNote(title: '日本語', content: _body('旅行 😀'));
      expect(scoreNote(note, SearchQuery('日本')), isNotNull);
      expect(scoreNote(note, SearchQuery('旅行')), isNotNull);
    });

    test('ranks title above tag above body', () {
      final title = makeNote(title: 'dinner');
      final tag = makeNote(id: '2', title: 'other', tags: ['dinner']);
      final body = makeNote(id: '3', title: 'other', content: _body('dinner'));

      final titleScore = scoreNote(title, SearchQuery('dinner'))!;
      final tagScore = scoreNote(tag, SearchQuery('dinner'))!;
      final bodyScore = scoreNote(body, SearchQuery('dinner'))!;

      expect(titleScore, greaterThan(tagScore));
      expect(tagScore, greaterThan(bodyScore));
    });

    test('ranks a title prefix above a title substring', () {
      final prefix = makeNote(title: 'Apple pie');
      final substring = makeNote(id: '2', title: 'Pineapple pie');

      final prefixScore = scoreNote(prefix, SearchQuery('apple'))!;
      final substringScore = scoreNote(substring, SearchQuery('apple'))!;

      expect(prefixScore, greaterThan(substringScore));
    });

    test('empty query matches everything with score zero', () {
      expect(scoreNote(makeNote(title: 'Anything'), SearchQuery('')), 0);
    });
  });

  group('findMatchRanges', () {
    test('highlights an accented match in the original text', () {
      final ranges = findMatchRanges('Café Royal', SearchQuery('cafe').tokens);
      expect(ranges, hasLength(1));
      expect(ranges.single.start, 0);
      expect(ranges.single.end, 4);
    });

    test('highlights every token, merging overlaps', () {
      final ranges =
          findMatchRanges('tax and tax 2025', SearchQuery('tax 2025').tokens);
      expect(ranges.map((r) => (r.start, r.end)), [(0, 3), (8, 11), (12, 16)]);
    });

    test('highlights a word that only matches with a typo', () {
      final ranges =
          findMatchRanges('keep the receipt', SearchQuery('reciept').tokens);
      expect(ranges, hasLength(1));
      expect(ranges.single.start, 9);
      expect(ranges.single.end, 16);
    });

    test('returns no ranges when nothing matches', () {
      expect(findMatchRanges('hello', SearchQuery('zzz').tokens), isEmpty);
    });
  });

  group('performance', () {
    test('scores 2000 cached notes well under a frame budget', () {
      final notes = List<Note>.generate(
        2000,
        (i) => makeNote(
          id: '$i',
          title: 'Note $i',
          content: _body('some body text about meetings and receipts $i'),
        ),
      );
      final query = SearchQuery('meeting');

      // Warm the per-note cache first.
      for (final note in notes) {
        scoreNote(note, query);
      }

      final stopwatch = Stopwatch()..start();
      for (final note in notes) {
        scoreNote(note, query);
      }
      stopwatch.stop();

      // Generous bound: the target is 50 ms on a mid-range device, this
      // container can be much slower under concurrent test runs.
      expect(stopwatch.elapsedMilliseconds, lessThan(500));
    });
  });
}
