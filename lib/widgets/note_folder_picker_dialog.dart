import 'package:flutter/material.dart';
import 'package:fox/l10n/app_localizations.dart';
import 'package:fox/models/folder.dart';

/// Folder picker for a note.
///
/// Calls [onSelected] with the chosen folder id, or `null` for "No Folder",
/// then closes.
class NoteFolderPickerDialog extends StatelessWidget {
  const NoteFolderPickerDialog({
    required this.folders,
    required this.selectedFolderId,
    required this.onSelected,
    super.key,
  });

  final List<Folder> folders;
  final String? selectedFolderId;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.moveToFolder),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                Icons.notes,
                color: selectedFolderId == null
                    ? Theme.of(context).colorScheme.primary
                    : null,
              ),
              title: Text(l10n.noFolder),
              selected: selectedFolderId == null,
              contentPadding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
              onTap: () {
                onSelected(null);
                Navigator.of(context).pop();
              },
            ),
            ...folders.map((folder) {
              return ListTile(
                leading: Icon(
                  Icons.folder,
                  color: selectedFolderId == folder.id
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
                title: Text(folder.name),
                selected: selectedFolderId == folder.id,
                contentPadding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
                onTap: () {
                  onSelected(folder.id);
                  Navigator.of(context).pop();
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}
