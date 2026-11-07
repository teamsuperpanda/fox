/// Editor-independent note body.
///
/// [deltaJson] is the persisted Delta JSON string (unchanged on disk);
/// [plainText] is the extracted text used for previews and search.
class NoteContent {
  const NoteContent({
    required this.deltaJson,
    required this.plainText,
  });

  /// Empty content, used for new notes and unparseable stored payloads.
  const NoteContent.empty()
      : deltaJson = '',
        plainText = '';

  final String deltaJson;
  final String plainText;
}
