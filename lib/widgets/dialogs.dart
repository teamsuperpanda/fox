import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/notes_controller.dart';

/// Shows a confirmation dialog for deleting a note.
///
/// Returns `true` if the user confirms, `false` or `null` otherwise.
Future<bool?> showDeleteConfirmDialog(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(l10n.deleteNote),
        content: Text(l10n.deleteNoteMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              l10n.delete,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      );
    },
  );
}

/// Shows a "Note deleted" snackbar with an Undo action.
void showUndoDeleteSnackBar(BuildContext context, NotesController controller) {
  final l10n = AppLocalizations.of(context);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(l10n.noteDeleted),
      action: SnackBarAction(
        label: l10n.undo,
        onPressed: () => controller.undoRemove(),
      ),
    ),
  );
}
