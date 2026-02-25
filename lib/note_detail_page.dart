import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'models/note.dart';
import 'services/notes_controller.dart';

/// Result returned when popping the detail page so the caller can act on it.
class NoteDetailResult {
  final bool changed;
  final bool deleted;
  const NoteDetailResult({this.changed = false, this.deleted = false});
}

/// Predefined note color palette.
const List<String?> noteColorOptions = [
  null,       // No color (default)
  '#FF5252',  // Red
  '#FF7043',  // Deep Orange
  '#FFCA28',  // Amber
  '#66BB6A',  // Green
  '#42A5F5',  // Blue
  '#AB47BC',  // Purple
  '#8D6E63',  // Brown
  '#78909C',  // Blue Grey
];

class NoteDetailPage extends StatefulWidget {
  final Note? existing;
  final NotesController controller;
  final bool showToolbar;

  const NoteDetailPage({
    super.key,
    this.existing,
    required this.controller,
    this.showToolbar = true,
  });

  @override
  State<NoteDetailPage> createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends State<NoteDetailPage> {
  late final TextEditingController _titleCtrl;
  late QuillController _contentCtrl;
  late bool _pinned;
  late bool _showToolbar;
  late List<String> _tags;
  late String? _folderId;
  late String? _color;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.existing?.title ?? '');
    _contentCtrl = QuillController(
      document: widget.existing?.document ?? Document(),
      selection: const TextSelection.collapsed(offset: 0),
    );
    _pinned = widget.existing?.pinned ?? false;
    _showToolbar = widget.showToolbar;
    _tags = List.from(widget.existing?.tags ?? []);
    _folderId = widget.existing?.folderId;
    _color = widget.existing?.color;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  /// Normalizes tag input — trims whitespace, lowercases, and rejects duplicates.
  String? _normalizeTag(String raw) {
    final normalized = raw.trim().toLowerCase();
    if (normalized.isEmpty || _tags.contains(normalized)) return null;
    return normalized;
  }

  void _showTagsDialog() async {
    final tagCtrl = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: const Text('Manage Tags'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: tagCtrl,
                      decoration: InputDecoration(
                        hintText: 'New tag...',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            final tag = _normalizeTag(tagCtrl.text);
                            if (tag != null) {
                              setState(() => _tags.add(tag));
                              setDialogState(() {});
                              tagCtrl.clear();
                            }
                          },
                        ),
                      ),
                      onSubmitted: (text) {
                        final tag = _normalizeTag(text);
                        if (tag != null) {
                          setState(() => _tags.add(tag));
                          setDialogState(() {});
                          tagCtrl.clear();
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      children: _tags.map((tag) {
                        return Chip(
                          label: Text(tag),
                          onDeleted: () {
                            setState(() {
                              _tags.remove(tag);
                            });
                            setDialogState(() {});
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showColorPicker() async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Note Colour'),
          content: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: noteColorOptions.map((hex) {
              final isSelected = _color == hex;
              final displayColor = hex != null
                  ? Color(int.parse('FF${hex.substring(1)}', radix: 16))
                  : null;
              return GestureDetector(
                onTap: () {
                  setState(() => _color = hex);
                  Navigator.of(context).pop();
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: displayColor ?? Theme.of(context).colorScheme.surfaceContainerHighest,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.transparent,
                      width: 3,
                    ),
                  ),
                  child: hex == null
                      ? Icon(Icons.block, size: 20, color: Theme.of(context).colorScheme.onSurfaceVariant)
                      : isSelected
                          ? const Icon(Icons.check, size: 20, color: Colors.white)
                          : null,
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _showFolderPicker() async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Move to Folder'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(
                    Icons.notes,
                    color: _folderId == null
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                  title: const Text('No Folder'),
                  selected: _folderId == null,
                  contentPadding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  onTap: () {
                    setState(() => _folderId = null);
                    Navigator.of(context).pop();
                  },
                ),
                ...widget.controller.folders.map((folder) {
                  return ListTile(
                    leading: Icon(
                      Icons.folder,
                      color: _folderId == folder.id
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                    title: Text(folder.name),
                    selected: _folderId == folder.id,
                    contentPadding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                    onTap: () {
                      setState(() => _folderId = folder.id);
                      Navigator.of(context).pop();
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _saveAndPop() async {
    if (_saving) return;
    _saving = true;

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.maybeOf(context);
    final errorColor = Theme.of(context).colorScheme.error;
    
    // Get trimmed values
    final title = _titleCtrl.text.trim();
    final content = _contentCtrl.document;
    final plainText = content.toPlainText().trim();
    
    // If new note is empty, discard it silently
    if (title.isEmpty && plainText.isEmpty && widget.existing == null) {
      navigator.pop(const NoteDetailResult());
      return;
    }
    
    // Validation: reject empty notes (for existing notes)
    if (title.isEmpty && plainText.isEmpty) {
      _saving = false;
      messenger?.showSnackBar(
        SnackBar(
          content: const Text('Note cannot be empty'),
          backgroundColor: errorColor,
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
      await widget.controller.addOrUpdate(
        id: widget.existing?.id,
        title: title,
        content: content,
        pinned: _pinned,
        tags: _tags,
        folderId: _folderId,
        color: _color,
      );
      navigator.pop(const NoteDetailResult(changed: true));
    } catch (e) {
      _saving = false;
      messenger?.showSnackBar(
        SnackBar(
          content: Text('Error saving note: $e'),
          backgroundColor: errorColor,
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
              tooltip: 'Folder',
              icon: Icon(_folderId != null ? Icons.folder : Icons.folder_outlined),
              onPressed: _showFolderPicker,
            ),
            IconButton(
              tooltip: 'Tags',
              icon: const Icon(Icons.label_outline),
              onPressed: _showTagsDialog,
            ),
            IconButton(
              tooltip: 'Note colour',
              icon: _color != null
                  ? Icon(Icons.circle, color: Color(int.parse('FF${_color!.substring(1)}', radix: 16)))
                  : const Icon(Icons.palette_outlined),
              onPressed: _showColorPicker,
            ),
            IconButton(
              tooltip: _showToolbar ? 'Hide formatting toolbar' : 'Show formatting toolbar',
              icon: Icon(_showToolbar ? Icons.text_format : Icons.text_format_outlined),
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
            mainAxisAlignment: widget.existing != null
                ? MainAxisAlignment.spaceBetween
                : MainAxisAlignment.end,
            children: [
              if (widget.existing != null)
                FloatingActionButton(
                  heroTag: 'delete',
                  backgroundColor: Theme.of(context).colorScheme.error,
                  onPressed: () async {
                    final navigator = Navigator.of(context);
                    final messenger = ScaffoldMessenger.maybeOf(context);
                    final theme = Theme.of(context);
                    final errorColor = theme.colorScheme.error;

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
                      try {
                        await widget.controller.remove(widget.existing!.id);
                        navigator.pop(const NoteDetailResult(changed: true, deleted: true));
                      } catch (e) {
                        messenger?.showSnackBar(
                          SnackBar(
                            content: Text('Error deleting note: $e'),
                            backgroundColor: errorColor,
                          ),
                        );
                      }
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
