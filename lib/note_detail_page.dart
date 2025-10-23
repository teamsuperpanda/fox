import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'models/note.dart';
import 'services/notes_controller.dart';

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
  late QuillController _contentCtrl;
  late bool _pinned;
  late bool _showToolbar;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.existing?.title ?? '');
    _contentCtrl = QuillController(
      document: widget.existing?.document ?? Document(),
      selection: const TextSelection.collapsed(offset: 0),
    );
    _pinned = widget.existing?.pinned ?? false;
    _showToolbar = true; // Toolbar visible by default
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  void _saveAndPop() {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.maybeOf(context);
    
    // Get trimmed values
    final title = _titleCtrl.text.trim();
    final content = _contentCtrl.document;
    final plainText = content.toPlainText().trim();
    
    // Validation: reject empty notes
    if (title.isEmpty && plainText.isEmpty) {
      messenger?.showSnackBar(
        SnackBar(
          content: const Text('Note cannot be empty'),
          backgroundColor: Theme.of(context).colorScheme.error,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }
    
    // Validation: warn about title-only notes (optional)
    if (title.isNotEmpty && plainText.isEmpty) {
      messenger?.showSnackBar(
        SnackBar(
          content: const Text('Saving note with title only'),
          duration: const Duration(seconds: 1),
        ),
      );
    }

    try {
      widget.controller.addOrUpdate(
        id: widget.existing?.id,
        title: title,
        content: content,
        pinned: _pinned,
      );
      navigator.pop(true);
    } catch (e) {
      messenger?.showSnackBar(
        SnackBar(
          content: Text('Error saving note: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
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
              tooltip: _showToolbar ? 'Hide formatting toolbar' : 'Show formatting toolbar',
              icon: Icon(_showToolbar ? Icons.format_size : Icons.format_size_outlined),
              onPressed: () => setState(() => _showToolbar = !_showToolbar),
            ),
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
              // Conditionally show toolbar
              if (_showToolbar)
                QuillSimpleToolbar(
                  controller: _contentCtrl,
                  config: QuillSimpleToolbarConfig(
                    color: Theme.of(context).appBarTheme.backgroundColor,
                    multiRowsDisplay: false,
                    toolbarIconAlignment: WrapAlignment.start,
                    showDividers: false,
                    showFontFamily: false,
                    showFontSize: false,
                    showBoldButton: true,
                    showItalicButton: true,
                    showUnderLineButton: true,
                    showStrikeThrough: false,
                    showInlineCode: false,
                    showColorButton: false,
                    showBackgroundColorButton: false,
                    showClearFormat: true,
                    showAlignmentButtons: false,
                    showLeftAlignment: false,
                    showCenterAlignment: false,
                    showRightAlignment: false,
                    showJustifyAlignment: false,
                    showHeaderStyle: false,
                    showListNumbers: true,
                    showListBullets: true,
                    showListCheck: false,
                    showCodeBlock: false,
                    showQuote: true,
                    showIndent: false,
                    showLink: false,
                    showUndo: true,
                    showRedo: true,
                    buttonOptions: QuillSimpleToolbarButtonOptions(
                      base: QuillToolbarBaseButtonOptions(
                        iconTheme: QuillIconTheme(
                          iconButtonSelectedData: IconButtonData(
                            style: IconButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              if (_showToolbar) const SizedBox(height: 8),
              Expanded(
                child: QuillEditor.basic(
                  controller: _contentCtrl,
                  config: QuillEditorConfig(
                    placeholder: 'Start typing...',
                    padding: EdgeInsets.zero,
                    autoFocus: widget.existing?.title.isNotEmpty ?? false,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
