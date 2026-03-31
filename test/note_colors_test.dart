import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fox/models/note_colors.dart';

void main() {
  group('noteColorOptions', () {
    test('contains expected number of colour options', () {
      expect(noteColorOptions.length, 9);
    });

    test('first option is null (default / no colour)', () {
      expect(noteColorOptions.first, isNull);
    });

    test('remaining options are 7-character hex strings', () {
      for (final hex in noteColorOptions.skip(1)) {
        expect(hex, isNotNull);
        expect(hex!.length, 7);
        expect(hex.startsWith('#'), isTrue);
      }
    });
  });

  group('parseNoteColor', () {
    test('returns correct Color for valid hex', () {
      final color = parseNoteColor('#FF5252');
      expect(color, isNotNull);
      expect(color, equals(const Color(0xFFFF5252)));
    });

    test('returns null for null input', () {
      expect(parseNoteColor(null), isNull);
    });

    test('returns null for empty string', () {
      expect(parseNoteColor(''), isNull);
    });

    test('returns null for short hex string', () {
      expect(parseNoteColor('#FFF'), isNull);
    });

    test('returns null for long hex string', () {
      expect(parseNoteColor('#FF525200'), isNull);
    });

    test('returns null for invalid hex characters', () {
      expect(parseNoteColor('#GGGGGG'), isNull);
    });

    test('parses all predefined colour options', () {
      for (final hex in noteColorOptions.skip(1)) {
        final color = parseNoteColor(hex);
        expect(color, isNotNull, reason: 'Failed to parse $hex');
      }
    });

    test('returns null for hex without # prefix', () {
      // 6 chars but no '#' → length is 6, not 7
      expect(parseNoteColor('FF5252'), isNull);
    });
  });
}
