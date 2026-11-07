import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:fox/l10n/app_localizations.dart';

/// Title field plus the optional formatting toolbar and Quill editor.
class NoteEditorForm extends StatelessWidget {
  const NoteEditorForm({
    required this.titleController,
    required this.contentController,
    required this.showToolbar,
    required this.autofocusTitle,
    required this.autofocusContent,
    super.key,
  });

  final TextEditingController titleController;
  final QuillController contentController;
  final bool showToolbar;
  final bool autofocusTitle;
  final bool autofocusContent;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
          child: TextField(
            controller: titleController,
            decoration: InputDecoration(
              hintText: l10n.noteTitle,
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
            style: Theme.of(context).textTheme.headlineSmall,
            autofocus: autofocusTitle,
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              children: [
                if (showToolbar)
                  QuillSimpleToolbar(
                    controller: contentController,
                    config: QuillSimpleToolbarConfig(
                      color: Theme.of(context).appBarTheme.backgroundColor,
                      multiRowsDisplay: false,
                      toolbarIconAlignment: WrapAlignment.start,
                      showDividers: false,
                      showFontFamily: false,
                      showFontSize: false,
                      showStrikeThrough: false,
                      showInlineCode: false,
                      showColorButton: false,
                      showBackgroundColorButton: false,
                      showLeftAlignment: false,
                      showCenterAlignment: false,
                      showRightAlignment: false,
                      showJustifyAlignment: false,
                      showHeaderStyle: false,
                      showListCheck: false,
                      showCodeBlock: false,
                      showIndent: false,
                      showLink: false,
                      buttonOptions: QuillSimpleToolbarButtonOptions(
                        base: QuillToolbarBaseButtonOptions(
                          iconTheme: QuillIconTheme(
                            iconButtonSelectedData: IconButtonData(
                              style: IconButton.styleFrom(
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withValues(alpha: 0.1),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                if (showToolbar) const SizedBox(height: 8),
                Expanded(
                  child: QuillEditor.basic(
                    controller: contentController,
                    config: QuillEditorConfig(
                      placeholder: l10n.startTyping,
                      autoFocus: autofocusContent,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
