// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Fox';

  @override
  String get search => 'Suchen...';

  @override
  String get noNotesYet => 'Noch keine Notizen...';

  @override
  String get noNotesMatchSearch =>
      'Keine Notizen stimmen mit deiner Suche überein.';

  @override
  String get folders => 'Ordner';

  @override
  String get viewOptions => 'Ansichtsoptionen';

  @override
  String get toggleTheme => 'Design wechseln';

  @override
  String get clearFolderFilter => 'Ordnerfilter entfernen';

  @override
  String get unfiled => 'Ohne Ordner';

  @override
  String get unknown => 'Unbekannt';

  @override
  String get allNotes => 'Alle Notizen';

  @override
  String get newFolderName => 'Neuer Ordnername...';

  @override
  String get renameFolder => 'Ordner umbenennen';

  @override
  String get folderName => 'Ordnername';

  @override
  String get deleteFolder => 'Ordner löschen?';

  @override
  String get deleteFolderMessage =>
      'Notizen in diesem Ordner werden nicht gelöscht, sie werden keinem Ordner zugeordnet.';

  @override
  String get rename => 'Umbenennen';

  @override
  String get delete => 'Löschen';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get close => 'Schließen';

  @override
  String get deleteNote => 'Notiz löschen?';

  @override
  String get deleteNoteMessage =>
      'Bist du sicher, dass du diese Notiz löschen möchtest?';

  @override
  String get noteDeleted => 'Notiz gelöscht';

  @override
  String get undo => 'Rückgängig';

  @override
  String get noteTitle => 'Notiztitel...';

  @override
  String get back => 'Zurück';

  @override
  String get folder => 'Ordner';

  @override
  String get tags => 'Tags';

  @override
  String get noteColour => 'Notizfarbe';

  @override
  String get hideFormattingToolbar => 'Formatierungsleiste ausblenden';

  @override
  String get showFormattingToolbar => 'Formatierungsleiste einblenden';

  @override
  String get unpin => 'Lösen';

  @override
  String get pin => 'Anheften';

  @override
  String get startTyping => 'Beginne zu schreiben...';

  @override
  String get manageTags => 'Tags verwalten';

  @override
  String get newTag => 'Neues Tag...';

  @override
  String get moveToFolder => 'In Ordner verschieben';

  @override
  String get noFolder => 'Kein Ordner';

  @override
  String get noteCannotBeEmpty => 'Notiz darf nicht leer sein';

  @override
  String get savingTitleOnly => 'Notiz nur mit Titel speichern';

  @override
  String errorSavingNote(String error) {
    return 'Fehler beim Speichern: $error';
  }

  @override
  String errorDeletingNote(String error) {
    return 'Fehler beim Löschen: $error';
  }

  @override
  String get sortBy => 'Sortieren nach';

  @override
  String get dateNewestFirst => 'Datum (neueste zuerst)';

  @override
  String get dateOldestFirst => 'Datum (älteste zuerst)';

  @override
  String get titleAZ => 'Titel (A-Z)';

  @override
  String get titleZA => 'Titel (Z-A)';

  @override
  String get showTags => 'Tags anzeigen';

  @override
  String get showNotePreviews => 'Vorschau anzeigen';

  @override
  String get alternatingRowColors => 'Abwechselnde Zeilenfarben';

  @override
  String get animateAddButton => 'Hinzufügen-Button animieren';

  @override
  String get untitled => '(Ohne Titel)';

  @override
  String get today => 'Heute';

  @override
  String get language => 'Sprache';

  @override
  String get accentColor => 'Akzentfarbe';

  @override
  String get systemDefault => 'Systemstandard';

  @override
  String startupError(String error) {
    return 'Beim Starten von Fox ist ein Fehler aufgetreten.\n\nVersuche, die App-Daten zu löschen oder die App neu zu installieren.\n\nFehler: $error';
  }
}
