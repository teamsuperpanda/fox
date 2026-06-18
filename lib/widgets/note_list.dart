import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fox/l10n/app_localizations.dart';
import 'package:fox/models/note.dart';
import 'package:fox/models/note_colors.dart';
import 'package:fox/note_detail_page.dart';
import 'package:fox/services/notes_controller.dart';
import 'package:fox/widgets/dialogs.dart';
import 'package:intl/intl.dart';

class NoteList extends StatelessWidget {
  const NoteList({
    required this.controller,
    required this.notes,
    super.key,
    this.showTags = true,
    this.showContent = true,
  });
  final NotesController controller;
  final List<Note> notes;
  final bool showTags;
  final bool showContent;

  static final _timeFormat = DateFormat.jm();
  static final DateFormat _dateTimeFormat = DateFormat.yMMMd().add_jm();

  static String _formatDate(DateTime dt, AppLocalizations l10n) {
    final now = DateTime.now();
    final sameDay =
        dt.year == now.year && dt.month == now.month && dt.day == now.day;
    if (sameDay) {
      return '${l10n.today} • ${_timeFormat.format(dt)}';
    }
    return _dateTimeFormat.format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        final noteColor = parseNoteColor(note.color);
        final trimmedText = note.plainText.trim();
        return Dismissible(
          key: ValueKey(note.id),
          // Deletion is handled inside confirmDismiss so Dismissible never removes
          // the widget itself — the list updates via notifyListeners instead.
          confirmDismiss: (direction) async {
            if (direction == DismissDirection.endToStart) {
              // Delete confirmation — handled via parent widget controller
              final confirmed = await showDeleteConfirmDialog(context);
              if (confirmed != true) return false;
              await controller.remove(note.id);
              if (context.mounted) {
                final l10n = AppLocalizations.of(context);
                ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                  SnackBar(
                    content: Text(l10n.noteDeleted),
                    action: SnackBarAction(
                      label: l10n.undo,
                      onPressed: controller.undoRemove,
                    ),
                  ),
                );
              }
              return false; // Never let Dismissible remove the widget
            } else if (direction == DismissDirection.startToEnd) {
              // Pin action - toggle pin
              unawaited(controller.setPinned(note.id, !note.pinned));
              return false;
            }
            return false;
          },
          // Background for Pin Action (Left to Right)
          background: Container(
            color: Theme.of(context).colorScheme.tertiary,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Icon(
                  note.pinned ? Icons.push_pin_outlined : Icons.push_pin,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Text(
                  note.pinned ? l10n.unpin : l10n.pin,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Background for Delete Action (Right to Left)
          secondaryBackground: Container(
            color: Theme.of(context).colorScheme.error,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  l10n.delete,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.delete, color: Colors.white),
              ],
            ),
          ),
          child: Semantics(
            label: '${l10n.note}: ${note.title.isEmpty ? l10n.untitled : note.title}',
            child: InkWell(
              onTap: () async {
                final result =
                    await Navigator.of(context).push<NoteDetailResult>(
                  MaterialPageRoute(
                    builder: (_) => NoteDetailPage(
                      existing: note,
                      controller: controller,
                    ),
                  ),
                );
                if (result != null && result.deleted && context.mounted) {
                  final l10n = AppLocalizations.of(context);
                  ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                    SnackBar(
                      content: Text(l10n.noteDeleted),
                      action: SnackBarAction(
                        label: l10n.undo,
                        onPressed: controller.undoRemove,
                      ),
                    ),
                  );
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: controller.alternatingColors && index.isEven
                      ? Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withValues(alpha: 0.3)
                      : null,
                  border: noteColor != null
                      ? Border(left: BorderSide(color: noteColor, width: 4))
                      : null,
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            note.title.isEmpty ? l10n.untitled : note.title,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.15,
                                ),
                          ),
                        ),
                        if (note.pinned) ...[
                          const SizedBox(width: 8),
                          Icon(
                            Icons.push_pin,
                            size: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ],
                      ],
                    ),
                    if (showContent && trimmedText.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        trimmedText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                              height: 1.2,
                            ),
                      ),
                    ],
                    if (showTags && note.tags.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: note.tags.map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .secondaryContainer
                                  .withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              tag,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSecondaryContainer,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          _formatDate(note.updatedAt, l10n),
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                        ),
                        if (note.folderId != null) ...[
                          const SizedBox(width: 8),
                          Icon(
                            Icons.folder_outlined,
                            size: 12,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            controller.getFolderName(note.folderId) ??
                                l10n.unknown,
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
