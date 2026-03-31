import 'package:flutter/material.dart';

/// Predefined note colour palette.
///
/// `null` represents the default (no colour) option.
const List<String?> noteColorOptions = [
  null,       // No colour (default)
  '#FF5252',  // Red
  '#FF7043',  // Deep Orange
  '#FFCA28',  // Amber
  '#66BB6A',  // Green
  '#42A5F5',  // Blue
  '#AB47BC',  // Purple
  '#8D6E63',  // Brown
  '#78909C',  // Blue Grey
];

/// Parses a hex colour string (e.g. `'#FF5252'`) into a [Color].
///
/// Returns `null` if [hex] is null, malformed, or not exactly 7 characters.
Color? parseNoteColor(String? hex) {
  if (hex == null || hex.length != 7) return null;
  try {
    return Color(int.parse('FF${hex.substring(1)}', radix: 16));
  } catch (_) {
    return null;
  }
}
