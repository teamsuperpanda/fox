// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Danish (`da`).
class AppLocalizationsDa extends AppLocalizations {
  AppLocalizationsDa([String locale = 'da']) : super(locale);

  @override
  String get appTitle => 'Fox';

  @override
  String get search => 'Søg...';

  @override
  String get noNotesYet => 'Ingen noter endnu...';

  @override
  String get noNotesMatchSearch => 'Ingen noter matcher din søgning.';

  @override
  String get folders => 'Mapper';

  @override
  String get viewOptions => 'Visningsmuligheder';

  @override
  String get toggleTheme => 'Skift tema';

  @override
  String get clearFolderFilter => 'Ryd mappefilter';

  @override
  String get unfiled => 'Uden mappe';

  @override
  String get unknown => 'Ukendt';

  @override
  String get allNotes => 'Alle noter';

  @override
  String get newFolderName => 'Nyt mappenavn...';

  @override
  String get renameFolder => 'Omdøb mappe';

  @override
  String get folderName => 'Mappenavn';

  @override
  String get deleteFolder => 'Slet mappe?';

  @override
  String get deleteFolderMessage =>
      'Noter i denne mappe slettes ikke, de bliver arkiveret uden mappe.';

  @override
  String get rename => 'Omdøb';

  @override
  String get delete => 'Slet';

  @override
  String get cancel => 'Annuller';

  @override
  String get close => 'Luk';

  @override
  String get deleteNote => 'Slet note?';

  @override
  String get deleteNoteMessage =>
      'Er du sikker på, at du vil slette denne note?';

  @override
  String get noteDeleted => 'Note slettet';

  @override
  String get undo => 'Fortryd';

  @override
  String get noteTitle => 'Notetitel...';

  @override
  String get back => 'Tilbage';

  @override
  String get folder => 'Mappe';

  @override
  String get tags => 'Tags';

  @override
  String get noteColour => 'Notefarve';

  @override
  String get hideFormattingToolbar => 'Skjul formateringsværktøjslinje';

  @override
  String get showFormattingToolbar => 'Vis formateringsværktøjslinje';

  @override
  String get unpin => 'Frigør';

  @override
  String get pin => 'Fastgør';

  @override
  String get startTyping => 'Begynd at skrive...';

  @override
  String get manageTags => 'Administrer tags';

  @override
  String get newTag => 'Nyt tag...';

  @override
  String get moveToFolder => 'Flyt til mappe';

  @override
  String get noFolder => 'Ingen mappe';

  @override
  String get noteCannotBeEmpty => 'Noten må ikke være tom';

  @override
  String get savingTitleOnly => 'Gemmer note kun med titel';

  @override
  String errorSavingNote(String error) {
    return 'Fejl ved lagring: $error';
  }

  @override
  String errorDeletingNote(String error) {
    return 'Fejl ved sletning: $error';
  }

  @override
  String get sortBy => 'Sorter efter';

  @override
  String get dateNewestFirst => 'Dato (nyeste først)';

  @override
  String get dateOldestFirst => 'Dato (ældste først)';

  @override
  String get titleAZ => 'Titel (A-Z)';

  @override
  String get titleZA => 'Titel (Z-A)';

  @override
  String get showTags => 'Vis tags';

  @override
  String get showNotePreviews => 'Vis forhåndsvisning';

  @override
  String get alternatingRowColors => 'Skiftende rækkefarver';

  @override
  String get animateAddButton => 'Animer tilføj-knap';

  @override
  String get untitled => '(Uden titel)';

  @override
  String get today => 'I dag';

  @override
  String get language => 'Sprog';

  @override
  String get accentColor => 'Accentfarve';

  @override
  String get systemDefault => 'Systemstandard';

  @override
  String startupError(String error) {
    return 'Der opstod en fejl ved start af Fox.\n\nPrøv at rydde appdata eller geninstaller.\n\nFejl: $error';
  }
}
