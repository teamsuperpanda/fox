import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fox/l10n/app_localizations.dart';
import 'package:fox/models/note.dart';
import 'package:fox/services/notes_controller.dart';

/// A horizontal strip of folder chips that accept dropped notes.
///
/// The editor's folder picker remains the keyboard and screen reader path for
/// the same move; this strip only adds the drag gesture.
class FolderDropBar extends StatelessWidget {
  const FolderDropBar({
    required this.controller,
    required this.onMove,
    super.key,
  });

  final NotesController controller;
  final Future<void> Function(Note note, String? folderId) onMove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final folders = controller.rootFolders;
    if (folders.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          _FolderDropChip(
            label: l10n.unfiled,
            folderId: null,
            onMove: onMove,
          ),
          for (final folder in folders) ...[
            _FolderDropChip(
              label: folder.name,
              folderId: folder.id,
              onMove: onMove,
            ),
            for (final child in controller.childFolders(folder.id))
              _FolderDropChip(
                label: controller.folderPath(child.id),
                folderId: child.id,
                onMove: onMove,
              ),
          ],
        ],
      ),
    );
  }
}

class _FolderDropChip extends StatelessWidget {
  const _FolderDropChip({
    required this.label,
    required this.folderId,
    required this.onMove,
  });

  final String label;
  final String? folderId;
  final Future<void> Function(Note note, String? folderId) onMove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    return DragTarget<Note>(
      onWillAcceptWithDetails: (_) => true,
      onAcceptWithDetails: (details) {
        unawaited(HapticFeedback.selectionClick());
        unawaited(onMove(details.data, folderId));
      },
      builder: (context, candidates, rejected) {
        final active = candidates.isNotEmpty;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Semantics(
            label: '${l10n.moveToFolder}: $label',
            button: true,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: active
                    ? colorScheme.primaryContainer
                    : colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color:
                      active ? colorScheme.primary : colorScheme.outlineVariant,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    folderId == null ? Icons.notes : Icons.folder,
                    size: 16,
                    color: active
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: active
                              ? colorScheme.onPrimaryContainer
                              : colorScheme.onSurfaceVariant,
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
