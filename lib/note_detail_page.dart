import 'package:flutter/material.dart';
import 'services/notes_controller.dart';
import 'services/repository.dart';

class NoteDetailPage extends StatefulWidget {
  final Note? existing;
  final NotesController controller;

  const NoteDetailPage({
    super.key,
    this.existing,
    required this.controller,
  });

  @override
  State<NoteDetailPage> createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends State<NoteDetailPage> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _contentCtrl;
  late bool _pinned;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.existing?.title ?? '');
    _contentCtrl = TextEditingController(text: widget.existing?.content ?? '');
    _pinned = widget.existing?.pinned ?? false;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  void _saveAndPop() {
    final navigator = Navigator.of(context);

    widget.controller.addOrUpdate(
      id: widget.existing?.id,
      title: _titleCtrl.text,
      content: _contentCtrl.text,
      pinned: _pinned,
    );

    navigator
        .pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          return;
        }
        _saveAndPop();
      },
      child: Scaffold(
        appBar: AppBar(
          title: TextField(
            controller: _titleCtrl,
            decoration: const InputDecoration(
              hintText: 'Note Title...',
              border: InputBorder.none,
            ),
            style: Theme.of(context).appBarTheme.titleTextStyle,
            autofocus: widget.existing?.title.isEmpty ?? true,
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _saveAndPop, // auto-save on back arrow
            tooltip: 'Back',
          ),
          actions: [
            IconButton(
              tooltip: _pinned ? 'Unpin' : 'Pin',
              icon: Icon(_pinned ? Icons.push_pin : Icons.push_pin_outlined),
              onPressed: () => setState(() => _pinned = !_pinned),
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (widget.existing != null)
                FloatingActionButton(
                  heroTag: 'delete',
                  backgroundColor: Theme.of(context).colorScheme.error,
                  onPressed: () async {
                    final navigator = Navigator.of(context);
                    final messenger = ScaffoldMessenger.maybeOf(context);
                    final theme = Theme.of(context);

                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Delete Note?'),
                          content: const Text(
                              'Are you sure you want to delete this note?'),
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
                                    color: theme.colorScheme.error),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                    if (confirmed == true) {
                      widget.controller.remove(widget.existing!.id);

                      navigator.pop(true);
                      messenger?.showSnackBar(
                        SnackBar(
                          content: const Text('Note deleted'),
                          action: SnackBarAction(
                            label: 'Undo',
                            textColor: theme.colorScheme.primary,
                            onPressed: () => widget.controller.undoRemove(),
                          ),
                        ),
                      );
                    }
                  },
                  child: Icon(
                    Icons.delete,
                    color: Theme.of(context).colorScheme.onError,
                  ),
                ),
              FloatingActionButton(
                heroTag: 'save',
                onPressed: _saveAndPop,
                child: const Icon(Icons.save),
              ),
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            children: [
              Expanded(
                child: TextField(
                  controller: _contentCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Start typing...',
                    border: InputBorder.none,
                  ),
                  style: Theme.of(context).textTheme.bodyMedium,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  expands: true,
                  autofocus: widget.existing?.title.isNotEmpty ?? false,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
