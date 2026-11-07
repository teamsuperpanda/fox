import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fox/models/folder_appearance.dart';
import 'package:fox/models/note_colors.dart';
import 'package:fox/theme/app_theme.dart';

/// WCAG 2 relative luminance of a colour.
double _luminance(Color color) {
  double channel(double value) => value <= 0.03928
      ? value / 12.92
      : math.pow((value + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * channel(color.r) +
      0.7152 * channel(color.g) +
      0.0722 * channel(color.b);
}

double _contrast(Color a, Color b) {
  final la = _luminance(a);
  final lb = _luminance(b);
  final lighter = math.max(la, lb);
  final darker = math.min(la, lb);
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  group('folder appearance', () {
    test('icon names resolve, unknown and null return null', () {
      expect(folderIconData('work'), isNotNull);
      expect(folderIconData('not-a-real-icon'), isNull);
      expect(folderIconData(null), isNull);
    });

    test('every icon option has a unique name and icon', () {
      expect(folderIconOptions.keys.toSet().length, folderIconOptions.length);
      expect(folderIconOptions.values.toSet().length, folderIconOptions.length);
    });

    test('palette colours keep 3:1 against the light and dark surfaces', () {
      final accent = accentColorOptions.first;
      final surfaces = {
        'light': AppTheme.light(accent).scaffoldBackgroundColor,
        'dark': AppTheme.dark(accent).scaffoldBackgroundColor,
      };

      for (final hex in folderColorOptions) {
        final color = parseHexColor(hex);
        expect(color, isNotNull, reason: '$hex should parse');
        for (final entry in surfaces.entries) {
          final ratio = _contrast(color!, entry.value);
          expect(
            ratio,
            greaterThanOrEqualTo(3),
            reason: '$hex on the ${entry.key} surface is '
                '${ratio.toStringAsFixed(2)}:1',
          );
        }
      }
    });
  });
}
