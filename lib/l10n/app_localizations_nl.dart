// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class AppLocalizationsNl extends AppLocalizations {
  AppLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String get appTitle => 'Fox';

  @override
  String get search => 'Zoeken...';

  @override
  String get noNotesYet => 'Nog geen notities...';

  @override
  String get noNotesMatchSearch =>
      'Geen notities komen overeen met uw zoekopdracht.';

  @override
  String get folders => 'Mappen';

  @override
  String get viewOptions => 'Weergaveopties';

  @override
  String get toggleTheme => 'Thema wisselen';

  @override
  String get clearFolderFilter => 'Mapfilter wissen';

  @override
  String get unfiled => 'Niet gearchiveerd';

  @override
  String get unknown => 'Onbekend';

  @override
  String get allNotes => 'Alle notities';

  @override
  String get newFolderName => 'Nieuwe mapnaam...';

  @override
  String get renameFolder => 'Map hernoemen';

  @override
  String get folderName => 'Mapnaam';

  @override
  String get deleteFolder => 'Map verwijderen?';

  @override
  String get deleteFolderMessage =>
      'Notities in deze map worden niet verwijderd, ze worden niet gearchiveerd.';

  @override
  String get rename => 'Hernoemen';

  @override
  String get delete => 'Verwijderen';

  @override
  String get cancel => 'Annuleren';

  @override
  String get close => 'Sluiten';

  @override
  String get deleteNote => 'Notitie verwijderen?';

  @override
  String get deleteNoteMessage =>
      'Weet u zeker dat u deze notitie wilt verwijderen?';

  @override
  String get noteDeleted => 'Notitie verwijderd';

  @override
  String get undo => 'Ongedaan maken';

  @override
  String get noteTitle => 'Notitietitel...';

  @override
  String get back => 'Terug';

  @override
  String get folder => 'Map';

  @override
  String get tags => 'Tags';

  @override
  String get noteColour => 'Notitiekleur';

  @override
  String get hideFormattingToolbar => 'Opmaakwerkbalk verbergen';

  @override
  String get showFormattingToolbar => 'Opmaakwerkbalk tonen';

  @override
  String get unpin => 'Losmaken';

  @override
  String get pin => 'Vastmaken';

  @override
  String get startTyping => 'Begin met typen...';

  @override
  String get manageTags => 'Tags beheren';

  @override
  String get newTag => 'Nieuwe tag...';

  @override
  String get moveToFolder => 'Verplaatsen naar map';

  @override
  String get noFolder => 'Geen map';

  @override
  String get noteCannotBeEmpty => 'Notitie kan niet leeg zijn';

  @override
  String get savingTitleOnly => 'Notitie opslaan met alleen titel';

  @override
  String errorSavingNote(String error) {
    return 'Fout bij opslaan: $error';
  }

  @override
  String errorDeletingNote(String error) {
    return 'Fout bij verwijderen: $error';
  }

  @override
  String get sortBy => 'Sorteren op';

  @override
  String get dateNewestFirst => 'Datum (nieuwste eerst)';

  @override
  String get dateOldestFirst => 'Datum (oudste eerst)';

  @override
  String get titleAZ => 'Titel (A-Z)';

  @override
  String get titleZA => 'Titel (Z-A)';

  @override
  String get showTags => 'Tags tonen';

  @override
  String get showNotePreviews => 'Voorbeelden tonen';

  @override
  String get alternatingRowColors => 'Afwisselende rijkleuren';

  @override
  String get animateAddButton => 'Toevoegknop animeren';

  @override
  String get untitled => '(Naamloos)';

  @override
  String get today => 'Vandaag';

  @override
  String get language => 'Taal';

  @override
  String get accentColor => 'Accentkleur';

  @override
  String get systemDefault => 'Systeemstandaard';

  @override
  String startupError(String error) {
    return 'Er is iets misgegaan bij het starten van Fox.\n\nProbeer de app-gegevens te wissen of opnieuw te installeren.\n\nFout: $error';
  }
}
