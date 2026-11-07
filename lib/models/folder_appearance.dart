import 'package:flutter/material.dart';

/// Built-in icons a folder can be marked with. Stored on the folder as the
/// map key, so renaming an entry here is a schema change.
const Map<String, IconData> folderIconOptions = {
  'folder': Icons.folder_outlined,
  'work': Icons.work_outline,
  'home': Icons.home_outlined,
  'star': Icons.star_outline,
  'book': Icons.menu_book_outlined,
  'idea': Icons.lightbulb_outline,
  'shopping': Icons.shopping_bag_outlined,
  'school': Icons.school_outlined,
  'heart': Icons.favorite_outline,
  'travel': Icons.flight_takeoff,
};

/// The icon for a stored folder icon name, or `null` when unset/unknown.
IconData? folderIconData(String? name) =>
    name == null ? null : folderIconOptions[name];

/// Accent colours a folder can use.
///
/// This is deliberately a subset of the note palette: every entry keeps at
/// least 3:1 contrast against both the light and dark app surfaces, which the
/// full note palette does not guarantee (amber, for example, is about 1.4:1 on
/// the light surface). See `test/folder_appearance_test.dart`.
const List<String> folderColorOptions = [
  '#AB47BC', // Purple
  '#8D6E63', // Brown
  '#607D8B', // Blue Grey
  '#00838F', // Teal
  '#388E3C', // Green
];
