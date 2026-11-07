import 'package:flutter/material.dart';
import 'package:fox/l10n/app_localizations.dart';
import 'package:fox/models/folder.dart';
import 'package:fox/services/constants.dart';
import 'package:fox/services/notes_controller.dart';

/// A dialog that lets the user manage folders: create, rename, delete, and
/// select a folder filter.
class FoldersDialog extends StatefulWidget {
  const FoldersDialog({required this.controller, super.key});
  final NotesController controller;

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
      if (!mounted) return;
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
    renameCtrl.dispose();
    if (!mounted) return;
    if (newName != null && newName.trim().isNotEmpty) {
      final isDuplicate =
          controller.folders.any((f) => f.name == newName.trim() && f.id != id);
      if (isDuplicate) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.folderAlreadyExists)),
        );
        return;
      }
      await controller.renameFolder(id, newName);
      if (!mounted) return;
      setState(() {});
    }
  }

  Future<void> _addSubfolder(Folder parent) async {
    final l10n = AppLocalizations.of(context);
    final nameCtrl = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.subfolder),
        content: TextField(
          controller: nameCtrl,
          autofocus: true,
          decoration: InputDecoration(hintText: l10n.folderName),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(nameCtrl.text),
            child: Text(l10n.create),
          ),
        ],
      ),
    );
    if (!mounted || name == null || name.trim().isEmpty) return;
    await controller.addFolder(name, parentId: parent.id);
    if (!mounted) return;
    setState(() {});
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
    if (confirmed ?? false) {
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
              Semantics(
                label: l10n.allNotes,
                child: ListTile(
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
              ),
              // "Unfiled" option
              Semantics(
                label: l10n.unfiled,
                child: ListTile(
                  leading: Icon(
                    Icons.notes,
                    color: controller.selectedFolderId ==
                            AppConstants.unfiledFolderId
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                  title: Text(l10n.unfiled),
                  selected: controller.selectedFolderId ==
                      AppConstants.unfiledFolderId,
                  contentPadding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  onTap: () {
                    controller.setSelectedFolder(AppConstants.unfiledFolderId);
                    setState(() {});
                  },
                ),
              ),
              ..._folderTiles(context),
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

  List<Widget> _folderTiles(BuildContext context) {
    final tiles = <Widget>[];
    for (final root in controller.rootFolders) {
      tiles.add(_folderTile(context, root, depth: 0));
      for (final child in controller.childFolders(root.id)) {
        tiles.add(_folderTile(context, child, depth: 1));
      }
    }
    return tiles;
  }

  Widget _folderTile(
    BuildContext context,
    Folder folder, {
    required int depth,
  }) {
    final l10n = AppLocalizations.of(context);
    final selected = controller.selectedFolderId == folder.id;
    return Semantics(
      label: 'Folder: ${controller.folderPath(folder.id)}',
      child: Padding(
        padding: EdgeInsets.only(left: depth * 16),
        child: ListTile(
          leading: Icon(
            depth == 0 ? Icons.folder : Icons.subdirectory_arrow_right,
            color: selected ? Theme.of(context).colorScheme.primary : null,
          ),
          title: Text(
            depth == 0 ? folder.name : controller.folderPath(folder.id),
          ),
          selected: selected,
          contentPadding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
          onTap: () {
            controller.setSelectedFolder(folder.id);
            setState(() {});
          },
          trailing: PopupMenuButton<String>(
            itemBuilder: (_) => [
              PopupMenuItem(value: 'rename', child: Text(l10n.rename)),
              if (depth == 0)
                PopupMenuItem(
                  value: 'subfolder',
                  child: Text(l10n.subfolder),
                ),
              PopupMenuItem(value: 'delete', child: Text(l10n.delete)),
            ],
            onSelected: (action) async {
              if (action == 'rename') {
                await _renameFolder(folder.id, folder.name);
              } else if (action == 'subfolder') {
                await _addSubfolder(folder);
              } else if (action == 'delete') {
                await _deleteFolder(folder.id);
              }
            },
          ),
        ),
      ),
    );
  }
}
