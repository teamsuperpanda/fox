import 'package:flutter/material.dart';
import 'package:fox/l10n/app_localizations.dart';

/// Tag editor used by the note detail page.
class NoteTagsDialog extends StatefulWidget {
  const NoteTagsDialog({
    required this.tags,
    required this.onChanged,
    super.key,
  });

  final List<String> tags;
  final ValueChanged<List<String>> onChanged;

  @override
  State<NoteTagsDialog> createState() => _NoteTagsDialogState();
}

class _NoteTagsDialogState extends State<NoteTagsDialog> {
  final _tagCtrl = TextEditingController();
  late List<String> _tags = List.of(widget.tags);

  @override
  void dispose() {
    _tagCtrl.dispose();
    super.dispose();
  }

  String? _normalizeTag(String raw) {
    final normalized = raw.trim().toLowerCase();
    if (normalized.isEmpty || _tags.contains(normalized)) return null;
    return normalized;
  }

  void _addTag(String? raw) {
    final tag = _normalizeTag(raw ?? _tagCtrl.text);
    if (tag == null) return;
    _tags = [..._tags, tag];
    widget.onChanged(_tags);
    _tagCtrl.clear();
    setState(() {});
  }

  void _removeTag(String tag) {
    _tags = _tags.where((t) => t != tag).toList();
    widget.onChanged(_tags);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.manageTags),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _tagCtrl,
              decoration: InputDecoration(
                hintText: l10n.newTag,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _addTag(null),
                ),
              ),
              onSubmitted: _addTag,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: _tags.map((tag) {
                return Chip(
                  label: Text(tag),
                  onDeleted: () => _removeTag(tag),
                );
              }).toList(),
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
