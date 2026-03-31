import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/notes_controller.dart';

/// A dialog that lets the user manage folders: create, rename, delete, and
/// select a folder filter.
class FoldersDialog extends StatefulWidget {
  final NotesController controller;

  const FoldersDialog({super.key, required this.controller});

  @override
  State<FoldersDialog> createState() => _FoldersDialogState();
}

class _FoldersDialogState extends State<FoldersDialog> {
  final _folderNameCtrl = TextEditingController();

  NotesController get controller => widget.controller;

  @override
  void dispose() {
    _folderNameCtrl.dispose();
    super.dispose();
  }

  Future<void> _addFolder() async {
    final name = _folderNameCtrl.text.trim();
    if (name.isNotEmpty) {
      await controller.addFolder(name);
      _folderNameCtrl.clear();
      setState(() {});
    }
  }

  Future<void> _renameFolder(String id, String currentName) async {
    final l10n = AppLocalizations.of(context);
    final renameCtrl = TextEditingController(text: currentName);
    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.renameFolder),
        content: TextField(
          controller: renameCtrl,
          autofocus: true,
          decoration: InputDecoration(hintText: l10n.folderName),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(renameCtrl.text),
            child: Text(l10n.rename),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (newName != null && newName.trim().isNotEmpty) {
      await controller.renameFolder(id, newName);
      if (!mounted) return;
      setState(() {});
    }
  }

  Future<void> _deleteFolder(String id) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteFolder),
        content: Text(l10n.deleteFolderMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              l10n.delete,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (confirmed == true) {
      await controller.deleteFolder(id);
      if (!mounted) return;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.folders),
      content: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 400),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _folderNameCtrl,
                decoration: InputDecoration(
                  hintText: l10n.newFolderName,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _addFolder,
                  ),
                ),
                onSubmitted: (_) => _addFolder(),
              ),
              const SizedBox(height: 16),
              // "All Notes" option
              ListTile(
                leading: Icon(
                  Icons.folder_open,
                  color: controller.selectedFolderId == null
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
                title: Text(l10n.allNotes),
                selected: controller.selectedFolderId == null,
                contentPadding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
                onTap: () {
                  controller.setSelectedFolder(null);
                  setState(() {});
                },
              ),
              // "Unfiled" option
              ListTile(
                leading: Icon(
                  Icons.notes,
                  color: controller.selectedFolderId == NotesController.unfiledFolderId
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
                title: Text(l10n.unfiled),
                selected: controller.selectedFolderId == NotesController.unfiledFolderId,
                contentPadding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
                onTap: () {
                  controller.setSelectedFolder(NotesController.unfiledFolderId);
                  setState(() {});
                },
              ),
              ...controller.folders.map((folder) {
                return ListTile(
                  leading: Icon(
                    Icons.folder,
                    color: controller.selectedFolderId == folder.id
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                  title: Text(folder.name),
                  selected: controller.selectedFolderId == folder.id,
                  contentPadding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  onTap: () {
                    controller.setSelectedFolder(folder.id);
                    setState(() {});
                  },
                  trailing: PopupMenuButton<String>(
                    itemBuilder: (_) => [
                      PopupMenuItem(value: 'rename', child: Text(l10n.rename)),
                      PopupMenuItem(value: 'delete', child: Text(l10n.delete)),
                    ],
                    onSelected: (action) async {
                      if (action == 'rename') {
                        await _renameFolder(folder.id, folder.name);
                      } else if (action == 'delete') {
                        await _deleteFolder(folder.id);
                      }
                    },
                  ),
                );
              }),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.close),
        ),
      ],
    );
  }
}
