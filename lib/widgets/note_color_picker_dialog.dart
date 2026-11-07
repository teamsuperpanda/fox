import 'package:flutter/material.dart';
import 'package:fox/l10n/app_localizations.dart';
import 'package:fox/models/note_colors.dart';

/// Per-note highlight colour picker.
///
/// Calls [onSelected] with the chosen hex value, or `null` for "no colour",
/// then closes.
class NoteColorPickerDialog extends StatelessWidget {
  const NoteColorPickerDialog({
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final String? selected;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.noteColour),
      content: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: noteColorOptions.map((hex) {
          final isSelected = selected == hex;
          final displayColor = parseHexColor(hex);
          return GestureDetector(
            onTap: () {
              onSelected(hex.isEmpty ? null : hex);
              Navigator.of(context).pop();
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: displayColor ??
                    Theme.of(context).colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.transparent,
                  width: 3,
                ),
              ),
              child: hex.isEmpty
                  ? Icon(
                      Icons.block,
                      size: 20,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    )
                  : isSelected
                      ? const Icon(Icons.check, size: 20, color: Colors.white)
                      : null,
            ),
          );
        }).toList(),
      ),
    );
  }
}
