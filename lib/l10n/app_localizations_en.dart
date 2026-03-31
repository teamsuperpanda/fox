// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Fox';

  @override
  String get search => 'Search...';

  @override
  String get noNotesYet => 'No notes yet...';

  @override
  String get noNotesMatchSearch => 'No notes match your search.';

  @override
  String get folders => 'Folders';

  @override
  String get viewOptions => 'View options';

  @override
  String get toggleTheme => 'Toggle theme';

  @override
  String get clearFolderFilter => 'Clear folder filter';

  @override
  String get unfiled => 'Unfiled';

  @override
  String get unknown => 'Unknown';

  @override
  String get allNotes => 'All Notes';

  @override
  String get newFolderName => 'New folder name...';

  @override
  String get renameFolder => 'Rename Folder';

  @override
  String get folderName => 'Folder name';

  @override
  String get deleteFolder => 'Delete Folder?';

  @override
  String get deleteFolderMessage =>
      'Notes in this folder will not be deleted, they will become unfiled.';

  @override
  String get rename => 'Rename';

  @override
  String get delete => 'Delete';

  @override
  String get cancel => 'Cancel';

  @override
  String get close => 'Close';

  @override
  String get deleteNote => 'Delete Note?';

  @override
  String get deleteNoteMessage => 'Are you sure you want to delete this note?';

  @override
  String get noteDeleted => 'Note deleted';

  @override
  String get undo => 'Undo';

  @override
  String get noteTitle => 'Note Title...';

  @override
  String get back => 'Back';

  @override
  String get folder => 'Folder';

  @override
  String get tags => 'Tags';

  @override
  String get noteColour => 'Note Colour';

  @override
  String get hideFormattingToolbar => 'Hide formatting toolbar';

  @override
  String get showFormattingToolbar => 'Show formatting toolbar';

  @override
  String get unpin => 'Unpin';

  @override
  String get pin => 'Pin';

  @override
  String get startTyping => 'Start typing...';

  @override
  String get manageTags => 'Manage Tags';

  @override
  String get newTag => 'New tag...';

  @override
  String get moveToFolder => 'Move to Folder';

  @override
  String get noFolder => 'No Folder';

  @override
  String get noteCannotBeEmpty => 'Note cannot be empty';

  @override
  String get savingTitleOnly => 'Saving note with title only';

  @override
  String errorSavingNote(String error) {
    return 'Error saving note: $error';
  }

  @override
  String errorDeletingNote(String error) {
    return 'Error deleting note: $error';
  }

  @override
  String get sortBy => 'Sort By';

  @override
  String get dateNewestFirst => 'Date (Newest First)';

  @override
  String get dateOldestFirst => 'Date (Oldest First)';

  @override
  String get titleAZ => 'Title (A-Z)';

  @override
  String get titleZA => 'Title (Z-A)';

  @override
  String get showTags => 'Show Tags';

  @override
  String get showNotePreviews => 'Show Note Previews';

  @override
  String get alternatingRowColors => 'Alternating Row Colors';

  @override
  String get animateAddButton => 'Animate Add Button';

  @override
  String get untitled => '(Untitled)';

  @override
  String get today => 'Today';

  @override
  String get language => 'Language';

  @override
  String get accentColor => 'Accent Colour';

  @override
  String get systemDefault => 'System Default';

  @override
  String startupError(String error) {
    return 'Something went wrong starting Fox.\n\nPlease try clearing app data or reinstalling.\n\nError: $error';
  }
}
