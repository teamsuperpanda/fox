import 'package:flutter/material.dart';

/// Predefined app-wide accent colours.  The first entry is the app default.
const List<Color> accentColorOptions = [
  Color(0xFF8B9A6B), // Sage green (default)
  Color(0xFF5B8DBE), // Steel blue
  Color(0xFFD4845A), // Terracotta
  Color(0xFF9B6B9E), // Plum
  Color(0xFFCB4B4B), // Crimson
  Color(0xFF4A9B8E), // Teal
  Color(0xFFD4A843), // Amber gold
  Color(0xFF6B7B8D), // Slate
  Color(0xFFE07BA0), // Rose
  Color(0xFF5C6BC0), // Indigo
];

/// Predefined note colour palette (per-note highlight colours for the editor).
/// Empty string represents the default (no colour) option.
const List<String> noteColorOptions = [
  '', // No colour (default)
  '#FF5252', // Red
  '#FF7043', // Deep Orange
  '#FFCA28', // Amber
  '#66BB6A', // Green
  '#42A5F5', // Blue
  '#AB47BC', // Purple
  '#8D6E63', // Brown
  '#78909C', // Blue Grey
];

/// Parses a hex colour string (e.g. `'#FF5252'`) into a [Color].
///
/// Returns `null` if [hex] is null, malformed, or not exactly 7 characters.
Color? parseHexColor(String? hex) {
  if (hex == null || hex.length != 7 || !hex.startsWith('#')) return null;
  try {
    return Color(int.parse('FF${hex.substring(1)}', radix: 16));
  } catch (_) {
    return null;
  }
}

/// Serializes a [Color] to a `'#RRGGBB'` hex string (inverse of
/// [parseHexColor]).
String colorToHex(Color color) =>
    '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
