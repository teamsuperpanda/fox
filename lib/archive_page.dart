import 'package:flutter/material.dart';
import 'package:fox/l10n/app_localizations.dart';
import 'package:fox/services/notes_controller.dart';

/// Lists archived notes and lets the user move them back to the main list.
class ArchivePage extends StatelessWidget {
  const ArchivePage({required this.controller, super.key});

  final NotesController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.archive)),
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final archived = controller.archivedNotes;
          if (archived.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  l10n.archiveEmpty,
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
                  l10n.archiveInfo,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: archived.length,
                  itemBuilder: (context, index) {
                    final note = archived[index];
                    return ListTile(
                      title: Text(
                        note.title.isEmpty ? l10n.untitled : note.title,
                      ),
                      subtitle: Text(
                        controller.getFolderName(note.folderId) ?? l10n.unfiled,
                      ),
                      trailing: IconButton(
                        tooltip: l10n.restore,
                        icon: const Icon(Icons.unarchive),
                        onPressed: () => controller.unarchive(note.id),
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
