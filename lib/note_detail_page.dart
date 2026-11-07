import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:fox/l10n/app_localizations.dart';
import 'package:fox/models/note.dart';
import 'package:fox/services/notes_controller.dart';
import 'package:fox/widgets/dialogs.dart';
import 'package:fox/widgets/note_action_bar.dart';
import 'package:fox/widgets/note_color_picker_dialog.dart';
import 'package:fox/widgets/note_editor_form.dart';
import 'package:fox/widgets/note_folder_picker_dialog.dart';
import 'package:fox/widgets/tags_dialog.dart';

class NoteDetailResult {
  const NoteDetailResult({this.changed = false, this.deleted = false});
  final bool changed;
  final bool deleted;
}

class NoteDetailPage extends StatefulWidget {
  const NoteDetailPage({
    required this.controller,
    super.key,
    this.existing,
    this.showToolbar = true,
  });
  final Note? existing;
  final NotesController controller;
  final bool showToolbar;

  @override
  State<NoteDetailPage> createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends State<NoteDetailPage> {
  static const _snackBarDuration = Duration(seconds: 5);

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

  Future<void> _showTagsDialog() async {
    await showDialog<void>(
      context: context,
      builder: (context) => NoteTagsDialog(
        tags: _tags,
        onChanged: (tags) => setState(() => _tags = tags),
      ),
    );
  }

  Future<void> _showColorPicker() async {
    await showDialog<void>(
      context: context,
      builder: (context) => NoteColorPickerDialog(
        selected: _color,
        onSelected: (color) => setState(() => _color = color),
      ),
    );
  }

  Future<void> _showFolderPicker() async {
    await showDialog<void>(
      context: context,
      builder: (context) => NoteFolderPickerDialog(
        folders: widget.controller.folders,
        selectedFolderId: _folderId,
        onSelected: (folderId) => setState(() => _folderId = folderId),
      ),
    );
  }

  Future<void> _saveAndPop() async {
    if (_saving) return;
    _saving = true;

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.maybeOf(context);
    final errorColor = Theme.of(context).colorScheme.error;
    final l10n = AppLocalizations.of(context);

    final title = _titleCtrl.text.trim();
    final content = _contentCtrl.document;
    final plainText = content.toPlainText().trim();

    if (title.isEmpty && plainText.isEmpty && widget.existing == null) {
      messenger?.showSnackBar(
        SnackBar(content: Text(l10n.emptyNoteDiscarded)),
      );
      navigator.pop(const NoteDetailResult());
      return;
    }

    if (title.isEmpty && plainText.isEmpty && widget.existing != null) {
      _saving = false;
      messenger?.showSnackBar(
        SnackBar(
          content: Text(l10n.noteCannotBeEmpty),
          backgroundColor: errorColor,
        ),
      );
      return;
    }

    if (title.isNotEmpty && plainText.isEmpty) {
      messenger?.showSnackBar(
        SnackBar(
          content: Text(l10n.savingTitleOnly),
          duration: _snackBarDuration,
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

  Future<void> _confirmDelete() async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.maybeOf(context);
    final errorColor = Theme.of(context).colorScheme.error;
    final l10n = AppLocalizations.of(context);

    final confirmed = await showDeleteConfirmDialog(context);
    if (confirmed != true || !mounted) return;
    try {
      await widget.controller.remove(widget.existing!.id);
      if (!mounted) return;
      navigator.pop(const NoteDetailResult(changed: true, deleted: true));
    } catch (e) {
      messenger?.showSnackBar(
        SnackBar(
          content: Text(l10n.errorDeletingNote(e.toString())),
          backgroundColor: errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final navigator = Navigator.of(context);
        var timedOut = false;
        try {
          await _saveAndPop().timeout(_snackBarDuration);
        } catch (_) {
          timedOut = true;
        }
        if (timedOut && mounted) {
          navigator.pop();
        }
      },
      child: Scaffold(
        appBar: NoteEditorAppBar(
          pinned: _pinned,
          color: _color,
          folderId: _folderId,
          showToolbar: _showToolbar,
          onBack: _saveAndPop,
          onFolder: _showFolderPicker,
          onTags: _showTagsDialog,
          onColor: _showColorPicker,
          onToggleToolbar: () => setState(() => _showToolbar = !_showToolbar),
          onTogglePin: () => setState(() => _pinned = !_pinned),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: NoteActionBar(
          showDelete: widget.existing != null,
          onDelete: _confirmDelete,
          onSave: _saveAndPop,
        ),
        body: NoteEditorForm(
          titleController: _titleCtrl,
          contentController: _contentCtrl,
          showToolbar: _showToolbar,
          autofocusTitle: widget.existing?.title.isEmpty ?? true,
          autofocusContent: widget.existing?.title.isNotEmpty ?? false,
        ),
      ),
    );
  }
}
