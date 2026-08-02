import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fox/models/note_colors.dart';

void main() {
  group('noteColorOptions', () {
    test('contains expected number of colour options', () {
      expect(noteColorOptions.length, 9);
    });

    test('first option is empty string (default / no colour)', () {
      expect(noteColorOptions.first, isEmpty);
    });

    test('remaining options are 7-character hex strings', () {
      for (final hex in noteColorOptions.skip(1)) {
        expect(hex, isNotNull);
        expect(hex.length, 7);
        expect(hex.startsWith('#'), isTrue);
      }
    });
  });

  group('parseHexColor', () {
    test('returns correct Color for valid hex', () {
      final color = parseHexColor('#FF5252');
      expect(color, isNotNull);
      expect(color, equals(const Color(0xFFFF5252)));
    });

    test('returns null for null input', () {
      expect(parseHexColor(null), isNull);
    });

    test('returns null for empty string', () {
      expect(parseHexColor(''), isNull);
    });

    test('returns null for short hex string', () {
      expect(parseHexColor('#FFF'), isNull);
    });

    test('returns null for long hex string', () {
      expect(parseHexColor('#FF525200'), isNull);
    });

    test('returns null for invalid hex characters', () {
      expect(parseHexColor('#GGGGGG'), isNull);
    });

    test('parses all predefined colour options', () {
      for (final hex in noteColorOptions.skip(1)) {
        final color = parseHexColor(hex);
        expect(color, isNotNull, reason: 'Failed to parse $hex');
      }
    });

    test('returns null for hex without # prefix', () {
      expect(parseHexColor('FF5252'), isNull);
      expect(parseHexColor('1FF5252'), isNull);
    });
  });
}
