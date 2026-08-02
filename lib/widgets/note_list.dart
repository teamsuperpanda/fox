import 'package:flutter/material.dart';
import 'package:fox/l10n/app_localizations.dart';
import 'package:fox/models/note.dart';
import 'package:fox/models/note_colors.dart';
import 'package:fox/services/notes_controller.dart';
import 'package:fox/widgets/dialogs.dart';
import 'package:intl/intl.dart';

InlineSpan _highlightText(
  String text,
  String query,
  TextStyle? style,
  Color highlightColor,
) {
  if (query.isEmpty) return TextSpan(text: text, style: style);
  final lower = text.toLowerCase();
  final q = query.toLowerCase();
  final spans = <InlineSpan>[];
  var start = 0;
  while (true) {
    final idx = lower.indexOf(q, start);
    if (idx < 0) break;
    if (idx > start) {
      spans.add(TextSpan(text: text.substring(start, idx), style: style));
    }
    spans.add(TextSpan(
      text: text.substring(idx, idx + q.length),
      style: style?.copyWith(
        backgroundColor: highlightColor,
      ),
    ));
    start = idx + q.length;
  }
  if (start < text.length) {
    spans.add(TextSpan(text: text.substring(start), style: style));
  }
  return TextSpan(children: spans);
}

class NoteList extends StatelessWidget {
  const NoteList({
    required this.controller,
    required this.notes,
    this.onNoteTap,
    super.key,
  });
  final NotesController controller;
  final List<Note> notes;
  final void Function(Note note)? onNoteTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final highlightColor = colorScheme.tertiaryContainer.withValues(alpha: 0.5);
    final highlightQuery = controller.searchTerm.toLowerCase();
    final folderNames = {
      for (final folder in controller.folders) folder.id: folder.name,
    };

    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) => _NoteListTile(
        note: notes[index],
        controller: controller,
        index: index,
        onNoteTap: onNoteTap,
        l10n: l10n,
        folderNames: folderNames,
        highlightQuery: highlightQuery,
        highlightColor: highlightColor,
      ),
    );
  }
}

class _NoteListTile extends StatelessWidget {
  const _NoteListTile({
    required this.note,
    required this.controller,
    required this.index,
    required this.onNoteTap,
    required this.l10n,
    required this.folderNames,
    required this.highlightQuery,
    required this.highlightColor,
  });

  static final _timeFormat = DateFormat.jm();
  static final DateFormat _dateTimeFormat = DateFormat.yMMMd().add_jm();
  static const _bullet = '•';

  static String _formatDate(DateTime dt, AppLocalizations l10n) {
    final now = DateTime.now();
    final sameDay =
        dt.year == now.year && dt.month == now.month && dt.day == now.day;
    if (sameDay) {
      return '${l10n.today} $_bullet ${_timeFormat.format(dt)}';
    }
    return _dateTimeFormat.format(dt);
  }

  final Note note;
  final NotesController controller;
  final int index;
  final void Function(Note note)? onNoteTap;
  final AppLocalizations l10n;
  final Map<String, String> folderNames;
  final String highlightQuery;
  final Color highlightColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final noteColor = parseHexColor(note.color);
    final trimmedText = note.plainText.trim();
    return Dismissible(
      key: ValueKey(note.id),
      // Deletion is handled inside confirmDismiss so Dismissible never removes
      // the widget itself — the list updates via notifyListeners instead.
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          final confirmed = await showDeleteConfirmDialog(context);
          if (confirmed != true) return false;
          await controller.remove(note.id);
          if (context.mounted) {
            showUndoDeleteSnackBar(context, controller);
          }
          return false; // Never let Dismissible remove the widget
        } else if (direction == DismissDirection.startToEnd) {
          // Pin action - toggle pin
          await controller.setPinned(note.id, !note.pinned);
          return false;
        }
        return false;
      },
      // Background for Pin Action (Left to Right)
      background: Container(
        color: colorScheme.tertiary,
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
        color: colorScheme.error,
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
        label:
            '${l10n.note}: ${note.title.isEmpty ? l10n.untitled : note.title}',
        child: InkWell(
          onTap: onNoteTap == null ? null : () => onNoteTap!(note),
          child: Container(
            decoration: BoxDecoration(
              color: controller.alternatingColors && index.isEven
                  ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
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
                      child: Text.rich(
                        _highlightText(
                          note.title.isEmpty ? l10n.untitled : note.title,
                          highlightQuery,
                          Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.15,
                              ),
                          highlightColor,
                        ),
                      ),
                    ),
                    if (note.pinned) ...[
                      const SizedBox(width: 8),
                      Icon(
                        Icons.push_pin,
                        size: 16,
                        color: colorScheme.primary,
                      ),
                    ],
                  ],
                ),
                if (controller.showContent && trimmedText.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text.rich(
                    _highlightText(
                      trimmedText,
                      highlightQuery,
                      Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            height: 1.2,
                          ),
                      highlightColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (controller.showTags && note.tags.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: note.tags.map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: colorScheme.secondaryContainer
                              .withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          tag,
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: colorScheme.onSecondaryContainer,
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
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: colorScheme.outline,
                          ),
                    ),
                    if (note.folderId != null) ...[
                      const SizedBox(width: 8),
                      Icon(
                        Icons.folder_outlined,
                        size: 12,
                        color: colorScheme.outline,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        folderNames[note.folderId] ?? l10n.unknown,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: colorScheme.outline,
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
  }
}
