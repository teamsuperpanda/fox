import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'l10n/app_localizations.dart';
import 'models/note.dart';
import 'models/note_colors.dart';
import 'services/notes_controller.dart';
import 'widgets/dialogs.dart';

/// Result returned when popping the detail page so the caller can act on it.
class NoteDetailResult {
  final bool changed;
  final bool deleted;
  const NoteDetailResult({this.changed = false, this.deleted = false});
}

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
        final l10n = AppLocalizations.of(context);
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: Text(l10n.manageTags),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: tagCtrl,
                      decoration: InputDecoration(
                        hintText: l10n.newTag,
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
                  child: Text(l10n.close),
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
        final l10n = AppLocalizations.of(context);
        return AlertDialog(
          title: Text(l10n.noteColour),
          content: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: noteColorOptions.map((hex) {
              final isSelected = _color == hex;
              final displayColor = parseNoteColor(hex);
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
        final l10n = AppLocalizations.of(context);
        return AlertDialog(
          title: Text(l10n.moveToFolder),
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
                  title: Text(l10n.noFolder),
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
    final l10n = AppLocalizations.of(context);
    
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
          content: Text(l10n.noteCannotBeEmpty),
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
          content: Text(l10n.savingTitleOnly),
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
      if (!mounted) return;
      navigator.pop(const NoteDetailResult(changed: true));
    } catch (e) {
      _saving = false;
      messenger?.showSnackBar(
        SnackBar(
          content: Text(l10n.errorSavingNote(e.toString())),
          backgroundColor: errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
            decoration: InputDecoration(
              hintText: l10n.noteTitle,
              border: InputBorder.none,
            ),
            style: Theme.of(context).appBarTheme.titleTextStyle,
            autofocus: widget.existing?.title.isEmpty ?? true,
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _saveAndPop, // auto-save on back arrow
            tooltip: l10n.back,
          ),
          actions: [
            IconButton(
              tooltip: l10n.folder,
              icon: Icon(_folderId != null ? Icons.folder : Icons.folder_outlined),
              onPressed: _showFolderPicker,
            ),
            IconButton(
              tooltip: l10n.tags,
              icon: const Icon(Icons.label_outline),
              onPressed: _showTagsDialog,
            ),
            IconButton(
              tooltip: l10n.noteColour,
              icon: _color != null
                  ? Icon(Icons.circle, color: parseNoteColor(_color))
                  : const Icon(Icons.palette_outlined),
              onPressed: _showColorPicker,
            ),
            IconButton(
              tooltip: _showToolbar ? l10n.hideFormattingToolbar : l10n.showFormattingToolbar,
              icon: Icon(_showToolbar ? Icons.text_format : Icons.text_format_outlined),
              onPressed: () => setState(() => _showToolbar = !_showToolbar),
            ),
            IconButton(
              tooltip: _pinned ? l10n.unpin : l10n.pin,
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
                    final errorColor = Theme.of(context).colorScheme.error;
                    final l10nLocal = AppLocalizations.of(context);

                    final confirmed = await showDeleteConfirmDialog(context);
                    if (confirmed != true || !mounted) return;
                    try {
                      await widget.controller.remove(widget.existing!.id);
                      if (!mounted) return;
                      navigator.pop(const NoteDetailResult(changed: true, deleted: true));
                    } catch (e) {
                      messenger?.showSnackBar(
                        SnackBar(
                          content: Text(l10nLocal.errorDeletingNote(e.toString())),
                          backgroundColor: errorColor,
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
                    placeholder: l10n.startTyping,
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
