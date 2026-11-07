import 'package:flutter/material.dart';
import 'package:fox/l10n/app_localizations.dart';
import 'package:fox/models/folder.dart';
import 'package:fox/models/folder_appearance.dart';
import 'package:fox/models/note_colors.dart';
import 'package:fox/services/constants.dart';
import 'package:fox/services/notes_controller.dart';
import 'package:fox/widgets/folder_icon.dart';

/// A dialog that lets the user manage folders: create, rename, delete, edit
/// the icon and colour, and select a folder filter.
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

  Future<void> _editAppearance(Folder folder) async {
    final result = await showDialog<_FolderAppearance>(
      context: context,
      builder: (_) => _FolderAppearanceDialog(folder: folder),
    );
    if (!mounted || result == null) return;
    await controller.setFolderAppearance(
      folder.id,
      icon: result.icon,
      color: result.color,
      clearIcon: result.icon == null,
      clearColor: result.color == null,
    );
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
              ...controller.folders.map((folder) {
                return Semantics(
                  label: 'Folder: ${folder.name}',
                  child: ListTile(
                    leading: FolderIcon(folder),
                    title: Text(folder.name),
                    selected: controller.selectedFolderId == folder.id,
                    selectedColor: controller.selectedFolderId == folder.id
                        ? Theme.of(context).colorScheme.primary
                        : null,
                    contentPadding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                    onTap: () {
                      controller.setSelectedFolder(folder.id);
                      setState(() {});
                    },
                    trailing: PopupMenuButton<String>(
                      itemBuilder: (_) => [
                        PopupMenuItem(
                          value: 'appearance',
                          child: Text(l10n.appearance),
                        ),
                        PopupMenuItem(
                            value: 'rename', child: Text(l10n.rename)),
                        PopupMenuItem(
                            value: 'delete', child: Text(l10n.delete)),
                      ],
                      onSelected: (action) async {
                        if (action == 'appearance') {
                          await _editAppearance(folder);
                        } else if (action == 'rename') {
                          await _renameFolder(folder.id, folder.name);
                        } else if (action == 'delete') {
                          await _deleteFolder(folder.id);
                        }
                      },
                    ),
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

class _FolderAppearance {
  const _FolderAppearance({this.icon, this.color});
  final String? icon;
  final String? color;
}

class _FolderAppearanceDialog extends StatefulWidget {
  const _FolderAppearanceDialog({required this.folder});
  final Folder folder;

  @override
  State<_FolderAppearanceDialog> createState() =>
      _FolderAppearanceDialogState();
}

class _FolderAppearanceDialogState extends State<_FolderAppearanceDialog> {
  late String? _icon = widget.folder.icon;
  late String? _color = widget.folder.color;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    return AlertDialog(
      title: Text(l10n.folderAppearance),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.folderIcon),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                IconButton(
                  tooltip: l10n.noIcon,
                  onPressed: () => setState(() => _icon = null),
                  icon: const Icon(Icons.block),
                  style: IconButton.styleFrom(
                    backgroundColor: _icon == null
                        ? colorScheme.primary.withValues(alpha: 0.15)
                        : null,
                  ),
                ),
                for (final entry in folderIconOptions.entries)
                  IconButton(
                    tooltip: entry.key,
                    onPressed: () => setState(() => _icon = entry.key),
                    icon: Icon(entry.value),
                    style: IconButton.styleFrom(
                      backgroundColor: _icon == entry.key
                          ? colorScheme.primary.withValues(alpha: 0.15)
                          : null,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(l10n.folderColour),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                Semantics(
                  label: l10n.noColour,
                  child: Tooltip(
                    message: l10n.noColour,
                    child: GestureDetector(
                      onTap: () => setState(() => _color = null),
                      child: _ColorDot(
                        color: colorScheme.surfaceContainerHighest,
                        selected: _color == null,
                        child: Icon(
                          Icons.block,
                          size: 20,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ),
                for (final hex in folderColorOptions)
                  Semantics(
                    label: hex,
                    child: Tooltip(
                      message: hex,
                      child: GestureDetector(
                        onTap: () => setState(() => _color = hex),
                        child: _ColorDot(
                          color: parseHexColor(hex) ?? colorScheme.primary,
                          selected: _color == hex,
                          child: _color == hex
                              ? const Icon(Icons.check,
                                  size: 20, color: Colors.white)
                              : null,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(context)
              .pop(_FolderAppearance(icon: _icon, color: _color)),
          child: Text(l10n.save),
        ),
      ],
    );
  }
}

class _ColorDot extends StatelessWidget {
  const _ColorDot({
    required this.color,
    required this.selected,
    this.child,
  });

  final Color color;
  final bool selected;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: selected
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          width: 3,
        ),
      ),
      child: child,
    );
  }
}
