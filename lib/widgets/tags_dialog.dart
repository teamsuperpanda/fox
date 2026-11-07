import 'package:flutter/material.dart';
import 'package:fox/l10n/app_localizations.dart';
import 'package:fox/services/notes_controller.dart';

/// Lists every tag in use with its note count. Tapping a tag filters the note
/// list, and each tag can be renamed (merging duplicates) or deleted.
class TagsDialog extends StatefulWidget {
  const TagsDialog({required this.controller, super.key});
  final NotesController controller;

  @override
  State<TagsDialog> createState() => _TagsDialogState();
}

class _TagsDialogState extends State<TagsDialog> {
  NotesController get controller => widget.controller;

  Future<void> _renameTag(String tag) async {
    final l10n = AppLocalizations.of(context);
    final controller = this.controller;
    final messenger = ScaffoldMessenger.maybeOf(context);
    final newName = await showDialog<String>(
      context: context,
      builder: (_) => _TagRenameDialog(initialName: tag),
    );
    if (!mounted) return;
    if (newName == null || newName.trim().isEmpty) return;

    await controller.renameTag(tag, newName);
    if (!mounted) return;
    setState(() {});
    messenger?.showSnackBar(
      SnackBar(
        content: Text(l10n.tagRenamed(newName.trim().toLowerCase())),
        action: SnackBarAction(
          label: l10n.undo,
          onPressed: () async {
            await controller.undoRenameTag();
            if (!mounted) return;
            setState(() {});
          },
        ),
      ),
    );
  }

  Future<void> _deleteTag(String tag) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteTag),
        content: Text(l10n.deleteTagMessage),
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
      await controller.deleteTag(tag);
      if (!mounted) return;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tagCounts = controller.tagCounts;
    return AlertDialog(
      title: Text(l10n.manageTags),
      content: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 400),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (tagCounts.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(l10n.noTags),
                )
              else
                for (final entry in tagCounts.entries)
                  Semantics(
                    label: '${l10n.tags}: ${entry.key}',
                    child: ListTile(
                      leading: Icon(
                        Icons.label_outline,
                        color: controller.selectedTag == entry.key
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                      title: Text(entry.key),
                      subtitle: Text(l10n.tagNoteCount(entry.value)),
                      selected: controller.selectedTag == entry.key,
                      contentPadding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                      onTap: () {
                        controller.setSelectedTag(entry.key);
                        Navigator.of(context).pop();
                      },
                      trailing: PopupMenuButton<String>(
                        itemBuilder: (_) => [
                          PopupMenuItem(
                            value: 'rename',
                            child: Text(l10n.rename),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Text(l10n.delete),
                          ),
                        ],
                        onSelected: (action) async {
                          if (action == 'rename') {
                            await _renameTag(entry.key);
                          } else if (action == 'delete') {
                            await _deleteTag(entry.key);
                          }
                        },
                      ),
                    ),
                  ),
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

class _TagRenameDialog extends StatefulWidget {
  const _TagRenameDialog({required this.initialName});
  final String initialName;

  @override
  State<_TagRenameDialog> createState() => _TagRenameDialogState();
}

class _TagRenameDialogState extends State<_TagRenameDialog> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initialName);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.renameTag),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: InputDecoration(hintText: l10n.tagName),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: Text(l10n.rename),
        ),
      ],
    );
  }
}
