import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../note_detail_page.dart';
import '../services/notes_controller.dart';
import '../models/note.dart';

class NoteList extends StatelessWidget {
  final NotesController controller;
  final List<Note> notes;
  final bool showTags;
  final bool showContent;

  const NoteList({
    super.key,
    required this.controller,
    required this.notes,
    this.showTags = true,
    this.showContent = true,
  });

  Future<void> _editNote(BuildContext context, Note note) async {
    await Navigator.of(context).push<bool>(MaterialPageRoute(
      builder: (_) => NoteDetailPage(
        existing: note,
        controller: controller,
      ),
    ));
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final sameDay =
        dt.year == now.year && dt.month == now.month && dt.day == now.day;
    if (sameDay) {
      return 'Today • ${DateFormat.jm().format(dt)}';
    }
    return DateFormat.yMMMd().add_jm().format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return Dismissible(
          key: ValueKey(note.id),
          // Allow swipe both ways: left-to-right (pin) and right-to-left (delete)
          direction: DismissDirection.horizontal,
          confirmDismiss: (direction) async {
            if (direction == DismissDirection.endToStart) {
              // Delete confirmation
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Delete Note?'),
                    content: const Text('Are you sure you want to delete this note?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: Text(
                          'Delete',
                          style: TextStyle(color: Theme.of(context).colorScheme.error),
                        ),
                      ),
                    ],
                  );
                },
              );
              return confirmed ?? false;
            } else if (direction == DismissDirection.startToEnd) {
              // Pin action - toggle pin
              controller.setPinned(note.id, !note.pinned);
              // Don't actually dismiss the item, just return false to snap back
              return false;
            }
            return false;
          },
          // Background for Pin Action (Left to Right)
          background: Container(
            color: Colors.amber[800],
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
                  note.pinned ? 'Unpin' : 'Pin',
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
            color: Colors.red.shade400,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Delete',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.delete, color: Colors.white),
              ],
            ),
          ),
          onDismissed: (direction) {
            if (direction == DismissDirection.endToStart) {
              controller.remove(note.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Note deleted'),
                  action: SnackBarAction(
                    label: 'Undo',
                    onPressed: () => controller.undoRemove(),
                  ),
                ),
              );
            }
          },
          child: InkWell(
            onTap: () => _editNote(context, note),
            child: Container(
              color: controller.alternatingColors && index.isOdd
                  ? Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
                  : null,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          note.title.isEmpty ? '(Untitled)' : note.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
                  if (showContent && note.plainText.trim().isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      note.plainText.trim(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  ],
                  if (showTags && note.tags.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: note.tags.map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            tag,
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSecondaryContainer,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                  const SizedBox(height: 10),
                  Text(
                    _formatDate(note.updatedAt),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
