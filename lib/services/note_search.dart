import 'dart:math' as math;

import 'package:fox/models/note.dart';

/// Diacritic groups used by [foldText]. Each group maps every accented
/// character on the right to the plain ASCII character on the left.
const Map<String, String> _diacriticGroups = {
  'a': 'àáâãäåāăą',
  'c': 'çćĉċč',
  'd': 'ďđð',
  'e': 'èéêëēĕėęě',
  'g': 'ĝğġģ',
  'h': 'ĥħ',
  'i': 'ìíîïĩīĭįı',
  'j': 'ĵ',
  'k': 'ķ',
  'l': 'ĺļľł',
  'n': 'ñńņňŉ',
  'o': 'òóôõöøōŏő',
  'r': 'ŕŗř',
  's': 'śŝşš',
  't': 'ţťŧ',
  'u': 'ùúûüũūŭůűų',
  'w': 'ŵ',
  'y': 'ýÿŷ',
  'z': 'źżž',
};

/// Folded character -> ASCII replacement, built once from [_diacriticGroups].
final Map<String, String> _foldTable = {
  for (final entry in _diacriticGroups.entries)
    for (final char in entry.value.split('')) char: entry.key,
  // Characters that lowercase into more than one code point.
  'İ': 'i',
};

/// Lowercases [input] and replaces accented Latin characters with their plain
/// ASCII equivalent.
///
/// The result is always the same length in UTF-16 code units as [input], so
/// indexes found in the folded text can be applied to the original. This keeps
/// match highlighting aligned.
String foldText(String input) {
  if (input.isEmpty) return input;
  final buffer = StringBuffer();
  for (final rune in input.runes) {
    final original = String.fromCharCode(rune);
    var folded = original.toLowerCase();
    // Some characters (Turkish dotted I, for example) lowercase into two code
    // points. Fall back to the original so indexes stay aligned.
    if (folded.length != original.length) folded = original;
    buffer.write(_foldTable[folded] ?? folded);
  }
  return buffer.toString();
}

final RegExp _whitespace = RegExp(r'\s+');
final RegExp _wordPattern = RegExp('[a-z0-9]+');

List<String> _splitWords(String folded) => _wordPattern
    .allMatches(folded)
    .map((match) => match.group(0)!)
    .toList(growable: false);

/// A parsed search query: folded tokens that must all match a note.
class SearchQuery {
  SearchQuery(String raw)
      : tokens = foldText(raw)
            .split(_whitespace)
            .where((token) => token.isNotEmpty)
            .toList(growable: false);

  /// Folded, lowercased tokens. A note matches when every token matches.
  final List<String> tokens;

  bool get isEmpty => tokens.isEmpty;
}

class _Weights {
  const _Weights({
    required this.exact,
    required this.prefix,
    required this.wordPrefix,
    required this.substring,
  });

  final int exact;
  final int prefix;
  final int wordPrefix;
  final int substring;
}

const _Weights _titleWeights =
    _Weights(exact: 1000, prefix: 800, wordPrefix: 600, substring: 400);
const _Weights _tagWeights =
    _Weights(exact: 300, prefix: 260, wordPrefix: 220, substring: 180);
const _Weights _bodyWeights =
    _Weights(exact: 160, prefix: 140, wordPrefix: 120, substring: 100);

/// Points subtracted when a token only matches with one typo.
const int _fuzzyPenalty = 30;

/// A folded view of a note used for matching. Built once per note instance.
class _SearchDocument {
  _SearchDocument(Note note)
      : title = foldText(note.title),
        tags = note.tags.map(foldText).toList(growable: false),
        body = foldText(note.plainText);

  final String title;
  final List<String> tags;
  final String body;

  late final List<String> titleWords = _splitWords(title);
  late final List<String> bodyWords = _splitWords(body);
  late final List<List<String>> tagWords =
      tags.map(_splitWords).toList(growable: false);
}

final Expando<_SearchDocument> _documents = Expando<_SearchDocument>();

_SearchDocument _documentFor(Note note) {
  final cached = _documents[note];
  if (cached != null) return cached;
  final document = _SearchDocument(note);
  _documents[note] = document;
  return document;
}

int? _scoreText(
  String text,
  List<String> words,
  String token,
  _Weights weights,
) {
  if (words.contains(token)) return weights.exact;
  if (text.startsWith(token)) return weights.prefix;
  for (final word in words) {
    if (word.startsWith(token)) return weights.wordPrefix;
  }
  if (text.contains(token)) return weights.substring;
  if (token.length > 4 && _anyWordWithinOneEdit(words, token)) {
    return weights.substring - _fuzzyPenalty;
  }
  return null;
}

bool _anyWordWithinOneEdit(List<String> words, String token) {
  for (final word in words) {
    if (_withinOneEdit(word, token)) return true;
  }
  return false;
}

/// True when [a] and [b] differ by at most one insertion, deletion,
/// substitution or adjacent transposition.
bool _withinOneEdit(String a, String b) {
  if (a == b) return true;
  final lengthA = a.length;
  final lengthB = b.length;
  if ((lengthA - lengthB).abs() > 1) return false;

  var indexA = 0;
  var indexB = 0;
  var edits = 0;
  while (indexA < lengthA && indexB < lengthB) {
    if (a.codeUnitAt(indexA) == b.codeUnitAt(indexB)) {
      indexA++;
      indexB++;
      continue;
    }
    edits++;
    if (edits > 1) return false;
    if (lengthA == lengthB) {
      // Substitution or transposition.
      if (indexA + 1 < lengthA &&
          indexB + 1 < lengthB &&
          a.codeUnitAt(indexA + 1) == b.codeUnitAt(indexB) &&
          a.codeUnitAt(indexA) == b.codeUnitAt(indexB + 1)) {
        indexA += 2;
        indexB += 2;
        continue;
      }
      indexA++;
      indexB++;
    } else if (lengthA > lengthB) {
      indexA++;
    } else {
      indexB++;
    }
  }
  if (indexA < lengthA || indexB < lengthB) edits++;
  return edits <= 1;
}

/// Scores [note] against [query].
///
/// Returns null when any query token is missing from the note. Title matches
/// score above tags, which score above body text, and prefixes above
/// substrings, so higher scores are more relevant.
int? scoreNote(Note note, SearchQuery query) {
  if (query.isEmpty) return 0;
  final document = _documentFor(note);
  var total = 0;
  for (final token in query.tokens) {
    int? best = _scoreText(
      document.title,
      document.titleWords,
      token,
      _titleWeights,
    );
    for (var i = 0; i < document.tags.length; i++) {
      final tagScore = _scoreText(
        document.tags[i],
        document.tagWords[i],
        token,
        _tagWeights,
      );
      if (tagScore != null && (best == null || tagScore > best)) {
        best = tagScore;
      }
    }
    final bodyScore = _scoreText(
      document.body,
      document.bodyWords,
      token,
      _bodyWeights,
    );
    if (bodyScore != null && (best == null || bodyScore > best)) {
      best = bodyScore;
    }
    if (best == null) return null;
    total += best;
  }
  return total;
}

/// A half-open range of characters to highlight in the original text.
class SearchMatchRange {
  const SearchMatchRange(this.start, this.end);

  final int start;
  final int end;
}

/// Finds every occurrence of [tokens] in [text], collapsed and sorted.
///
/// Matching is case and diacritic insensitive. Tokens longer than four
/// characters also match words that differ by one typo.
List<SearchMatchRange> findMatchRanges(String text, List<String> tokens) {
  if (text.isEmpty || tokens.isEmpty) return const [];
  final folded = foldText(text);
  final found = <SearchMatchRange>[];
  for (final token in tokens) {
    if (token.isEmpty) continue;
    var matched = false;
    var start = 0;
    while (true) {
      final index = folded.indexOf(token, start);
      if (index < 0) break;
      final end = math.min(index + token.length, text.length);
      found.add(SearchMatchRange(index, end));
      matched = true;
      start = index + token.length;
    }
    if (!matched && token.length > 4) {
      for (final match in _wordPattern.allMatches(folded)) {
        final word = match.group(0)!;
        if (!_withinOneEdit(word, token)) continue;
        final end = math.min(match.end, text.length);
        found.add(SearchMatchRange(match.start, end));
      }
    }
  }
  if (found.isEmpty) return const [];
  found.sort((a, b) => a.start.compareTo(b.start));
  final merged = <SearchMatchRange>[found.first];
  for (final range in found.skip(1)) {
    final last = merged.last;
    if (range.start <= last.end) {
      merged[merged.length - 1] =
          SearchMatchRange(last.start, math.max(last.end, range.end));
    } else {
      merged.add(range);
    }
  }
  return merged;
}
