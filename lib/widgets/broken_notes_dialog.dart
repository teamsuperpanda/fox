import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fox/l10n/app_localizations.dart';
import 'package:fox/models/note.dart';
import 'package:fox/services/notes_controller.dart';

/// Lists notes whose stored content cannot be parsed and lets the user copy
/// the raw stored JSON out before deleting or repairing them.
Future<void> showBrokenNotesDialog(
  BuildContext context,
  NotesController controller,
) {
  return showDialog<void>(
    context: context,
    builder: (context) => _BrokenNotesDialog(controller: controller),
  );
}

class _BrokenNotesDialog extends StatefulWidget {
  const _BrokenNotesDialog({required this.controller});
  final NotesController controller;

  @override
  State<_BrokenNotesDialog> createState() => _BrokenNotesDialogState();
}

class _BrokenNotesDialogState extends State<_BrokenNotesDialog> {
  late List<Note> _notes = widget.controller.brokenNotes;

  Future<void> _copy(Note note) async {
    await Clipboard.setData(ClipboardData(text: note.content));
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(content: Text(l10n.rawContentCopied)),
    );
    setState(() => _notes = widget.controller.brokenNotes);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.repairNotes),
      content: SizedBox(
        width: double.maxFinite,
        child: _notes.isEmpty
            ? Text(l10n.noBrokenNotes)
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.repairNotesMessage),
                  const SizedBox(height: 12),
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _notes.length,
                      itemBuilder: (context, index) {
                        final note = _notes[index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.report_outlined),
                          title: Text(
                            note.title.isEmpty ? l10n.untitled : note.title,
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.copy),
                            tooltip: l10n.copyRawContent,
                            onPressed: () => _copy(note),
                          ),
                        );
                      },
                    ),
                  ),
                ],
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
