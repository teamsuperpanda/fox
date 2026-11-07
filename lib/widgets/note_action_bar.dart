import 'package:flutter/material.dart';
import 'package:fox/l10n/app_localizations.dart';
import 'package:fox/models/note_colors.dart';

/// App bar for the note editor: back, folder, tags, colour, toolbar and pin.
class NoteEditorAppBar extends StatelessWidget implements PreferredSizeWidget {
  const NoteEditorAppBar({
    required this.pinned,
    required this.color,
    required this.folderId,
    required this.showToolbar,
    required this.onBack,
    required this.onFolder,
    required this.onTags,
    required this.onColor,
    required this.onToggleToolbar,
    required this.onTogglePin,
    super.key,
  });

  final bool pinned;
  final String? color;
  final String? folderId;
  final bool showToolbar;
  final VoidCallback onBack;
  final VoidCallback onFolder;
  final VoidCallback onTags;
  final VoidCallback onColor;
  final VoidCallback onToggleToolbar;
  final VoidCallback onTogglePin;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: onBack,
        tooltip: l10n.back,
      ),
      actions: [
        IconButton(
          tooltip: l10n.folder,
          icon: Icon(folderId != null ? Icons.folder : Icons.folder_outlined),
          onPressed: onFolder,
        ),
        IconButton(
          tooltip: l10n.tags,
          icon: const Icon(Icons.label_outline),
          onPressed: onTags,
        ),
        IconButton(
          tooltip: l10n.noteColour,
          icon: color != null
              ? Icon(Icons.circle, color: parseHexColor(color))
              : const Icon(Icons.palette_outlined),
          onPressed: onColor,
        ),
        IconButton(
          tooltip: showToolbar
              ? l10n.hideFormattingToolbar
              : l10n.showFormattingToolbar,
          icon: Icon(
            showToolbar ? Icons.text_format : Icons.text_format_outlined,
          ),
          onPressed: onToggleToolbar,
        ),
        IconButton(
          tooltip: pinned ? l10n.unpin : l10n.pin,
          icon: Icon(pinned ? Icons.push_pin : Icons.push_pin_outlined),
          onPressed: onTogglePin,
        ),
      ],
    );
  }
}

/// Centered save button, with a delete button when editing an existing note.
class NoteActionBar extends StatelessWidget {
  const NoteActionBar({
    required this.showDelete,
    required this.onDelete,
    required this.onSave,
    super.key,
  });

  final bool showDelete;
  final VoidCallback onDelete;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment:
            showDelete ? MainAxisAlignment.spaceBetween : MainAxisAlignment.end,
        children: [
          if (showDelete)
            FloatingActionButton(
              heroTag: 'delete',
              backgroundColor: Theme.of(context).colorScheme.error,
              onPressed: onDelete,
              child: Icon(
                Icons.delete,
                color: Theme.of(context).colorScheme.onError,
              ),
            ),
          FloatingActionButton(
            heroTag: 'save',
            onPressed: onSave,
            child: const Icon(Icons.save),
          ),
        ],
      ),
    );
  }
}
