import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../note_detail_page.dart';
import '../services/notes_controller.dart';
import '../services/repository.dart';

class NoteList extends StatelessWidget {
  final NotesController controller;
  final List<Note> notes;

  const NoteList({super.key, required this.controller, required this.notes});

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
          direction: DismissDirection.endToStart,
          confirmDismiss: (direction) async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Delete Note?'),
                  content:
                      const Text('Are you sure you want to delete this note?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Text(
                        'Delete',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error),
                      ),
                    ),
                  ],
                );
              },
            );
            return confirmed ?? false;
          },
          background: Container(
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
          onDismissed: (_) {
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
          },
          child: ListTile(
            leading: IconButton(
              icon: Icon(
                note.pinned ? Icons.push_pin : Icons.push_pin_outlined,
                color: note.pinned ? Colors.amber[800] : Colors.grey[700],
              ),
              onPressed: () => controller.setPinned(note.id, !note.pinned),
              tooltip: note.pinned ? 'Unpin' : 'Pin',
            ),
            title: Text(
              note.title.isEmpty ? '(Untitled)' : note.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Builder(builder: (context) {
              final titleColor = DefaultTextStyle.of(context).style.color;
              return Text(
                _formatDate(note.updatedAt),
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: titleColor),
              );
            }),
            onTap: () => _editNote(context, note),
          ),
        );
      },
    );
  }
}
