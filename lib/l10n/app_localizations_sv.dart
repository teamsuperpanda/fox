// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Swedish (`sv`).
class AppLocalizationsSv extends AppLocalizations {
  AppLocalizationsSv([String locale = 'sv']) : super(locale);

  @override
  String get appTitle => 'Fox';

  @override
  String get search => 'Sök...';

  @override
  String get noNotesYet => 'Inga anteckningar ännu...';

  @override
  String get noNotesMatchSearch => 'Inga anteckningar matchar din sökning.';

  @override
  String get folders => 'Mappar';

  @override
  String get viewOptions => 'Visningsalternativ';

  @override
  String get toggleTheme => 'Växla tema';

  @override
  String get clearFolderFilter => 'Rensa mappfilter';

  @override
  String get unfiled => 'Oarkiverad';

  @override
  String get unknown => 'Okänd';

  @override
  String get allNotes => 'Alla anteckningar';

  @override
  String get newFolderName => 'Nytt mappnamn...';

  @override
  String get renameFolder => 'Byt namn på mapp';

  @override
  String get folderName => 'Mappnamn';

  @override
  String get deleteFolder => 'Ta bort mapp?';

  @override
  String get deleteFolderMessage =>
      'Anteckningar i denna mapp kommer inte att tas bort, de blir oarkiverade.';

  @override
  String get rename => 'Byt namn';

  @override
  String get delete => 'Ta bort';

  @override
  String get cancel => 'Avbryt';

  @override
  String get close => 'Stäng';

  @override
  String get deleteNote => 'Ta bort anteckning?';

  @override
  String get deleteNoteMessage =>
      'Är du säker på att du vill ta bort denna anteckning?';

  @override
  String get noteDeleted => 'Anteckning borttagen';

  @override
  String get undo => 'Ångra';

  @override
  String get noteTitle => 'Anteckningstitel...';

  @override
  String get back => 'Tillbaka';

  @override
  String get folder => 'Mapp';

  @override
  String get tags => 'Taggar';

  @override
  String get noteColour => 'Anteckningsfärg';

  @override
  String get hideFormattingToolbar => 'Dölj formateringsverktygsfält';

  @override
  String get showFormattingToolbar => 'Visa formateringsverktygsfält';

  @override
  String get unpin => 'Lossa';

  @override
  String get pin => 'Fäst';

  @override
  String get startTyping => 'Börja skriva...';

  @override
  String get manageTags => 'Hantera taggar';

  @override
  String get newTag => 'Ny tagg...';

  @override
  String get moveToFolder => 'Flytta till mapp';

  @override
  String get noFolder => 'Ingen mapp';

  @override
  String get noteCannotBeEmpty => 'Anteckningen kan inte vara tom';

  @override
  String get savingTitleOnly => 'Sparar anteckning med enbart titel';

  @override
  String errorSavingNote(String error) {
    return 'Fel vid sparning: $error';
  }

  @override
  String errorDeletingNote(String error) {
    return 'Fel vid borttagning: $error';
  }

  @override
  String get sortBy => 'Sortera efter';

  @override
  String get dateNewestFirst => 'Datum (nyast först)';

  @override
  String get dateOldestFirst => 'Datum (äldst först)';

  @override
  String get titleAZ => 'Titel (A-Ö)';

  @override
  String get titleZA => 'Titel (Ö-A)';

  @override
  String get showTags => 'Visa taggar';

  @override
  String get showNotePreviews => 'Visa förhandsvisningar';

  @override
  String get alternatingRowColors => 'Alternerande radfärger';

  @override
  String get animateAddButton => 'Animera lägg till-knapp';

  @override
  String get untitled => '(Namnlös)';

  @override
  String get today => 'Idag';

  @override
  String get language => 'Språk';

  @override
  String get accentColor => 'Accentfärg';

  @override
  String get systemDefault => 'Systemstandard';

  @override
  String startupError(String error) {
    return 'Något gick fel vid start av Fox.\n\nFörsök rensa appdata eller installera om.\n\nFel: $error';
  }
}
