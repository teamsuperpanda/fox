import 'package:flutter/material.dart';
import 'package:fox/l10n/app_localizations.dart';
import 'package:fox/models/note.dart';
import 'package:fox/services/notes_controller.dart';
import 'package:intl/intl.dart';

/// Lists trashed notes with restore and permanent delete actions.
class TrashPage extends StatelessWidget {
  const TrashPage({required this.controller, super.key});

  final NotesController controller;

  static final DateFormat _dateFormat = DateFormat.yMMMd().add_jm();

  Future<void> _confirmEmpty(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.emptyTrash),
        content: Text(l10n.emptyTrashConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              l10n.delete,
              style: TextStyle(color: Theme.of(ctx).colorScheme.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed ?? false) {
      await controller.emptyTrash();
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    Note note,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteForever),
        content: Text(l10n.deleteForeverConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              l10n.delete,
              style: TextStyle(color: Theme.of(ctx).colorScheme.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed ?? false) {
      await controller.deletePermanently(note.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.trash),
        actions: [
          AnimatedBuilder(
            animation: controller,
            builder: (context, _) => IconButton(
              tooltip: l10n.emptyTrash,
              icon: const Icon(Icons.delete_sweep),
              onPressed: controller.trash.isEmpty
                  ? null
                  : () => _confirmEmpty(context),
            ),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final trashed = controller.trash;
          if (trashed.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  l10n.trashEmpty,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            );
          }
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Text(
                  l10n.trashRetentionInfo,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: trashed.length,
                  itemBuilder: (context, index) {
                    final note = trashed[index];
                    final deletedAt = note.deletedAt;
                    return ListTile(
                      title: Text(
                        note.title.isEmpty ? l10n.untitled : note.title,
                      ),
                      subtitle: deletedAt == null
                          ? null
                          : Text(_dateFormat.format(deletedAt)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: l10n.restore,
                            icon: const Icon(Icons.restore_from_trash),
                            onPressed: () => controller.restore(note.id),
                          ),
                          IconButton(
                            tooltip: l10n.deleteForever,
                            icon: const Icon(Icons.delete_forever),
                            onPressed: () => _confirmDelete(context, note),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
