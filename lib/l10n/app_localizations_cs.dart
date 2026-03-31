// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Czech (`cs`).
class AppLocalizationsCs extends AppLocalizations {
  AppLocalizationsCs([String locale = 'cs']) : super(locale);

  @override
  String get appTitle => 'Fox';

  @override
  String get search => 'Hledat...';

  @override
  String get noNotesYet => 'Zatím žádné poznámky...';

  @override
  String get noNotesMatchSearch =>
      'Žádné poznámky neodpovídají vašemu hledání.';

  @override
  String get folders => 'Složky';

  @override
  String get viewOptions => 'Možnosti zobrazení';

  @override
  String get toggleTheme => 'Přepnout motiv';

  @override
  String get clearFolderFilter => 'Zrušit filtr složky';

  @override
  String get unfiled => 'Nezařazené';

  @override
  String get unknown => 'Neznámé';

  @override
  String get allNotes => 'Všechny poznámky';

  @override
  String get newFolderName => 'Název nové složky...';

  @override
  String get renameFolder => 'Přejmenovat složku';

  @override
  String get folderName => 'Název složky';

  @override
  String get deleteFolder => 'Smazat složku?';

  @override
  String get deleteFolderMessage =>
      'Poznámky v této složce nebudou smazány, budou nezařazené.';

  @override
  String get rename => 'Přejmenovat';

  @override
  String get delete => 'Smazat';

  @override
  String get cancel => 'Zrušit';

  @override
  String get close => 'Zavřít';

  @override
  String get deleteNote => 'Smazat poznámku?';

  @override
  String get deleteNoteMessage => 'Opravdu chcete smazat tuto poznámku?';

  @override
  String get noteDeleted => 'Poznámka smazána';

  @override
  String get undo => 'Zpět';

  @override
  String get noteTitle => 'Název poznámky...';

  @override
  String get back => 'Zpět';

  @override
  String get folder => 'Složka';

  @override
  String get tags => 'Štítky';

  @override
  String get noteColour => 'Barva poznámky';

  @override
  String get hideFormattingToolbar => 'Skrýt panel formátování';

  @override
  String get showFormattingToolbar => 'Zobrazit panel formátování';

  @override
  String get unpin => 'Odepnout';

  @override
  String get pin => 'Připnout';

  @override
  String get startTyping => 'Začněte psát...';

  @override
  String get manageTags => 'Spravovat štítky';

  @override
  String get newTag => 'Nový štítek...';

  @override
  String get moveToFolder => 'Přesunout do složky';

  @override
  String get noFolder => 'Žádná složka';

  @override
  String get noteCannotBeEmpty => 'Poznámka nesmí být prázdná';

  @override
  String get savingTitleOnly => 'Ukládání poznámky pouze s názvem';

  @override
  String errorSavingNote(String error) {
    return 'Chyba při ukládání: $error';
  }

  @override
  String errorDeletingNote(String error) {
    return 'Chyba při mazání: $error';
  }

  @override
  String get sortBy => 'Řadit podle';

  @override
  String get dateNewestFirst => 'Datum (nejnovější)';

  @override
  String get dateOldestFirst => 'Datum (nejstarší)';

  @override
  String get titleAZ => 'Název (A-Z)';

  @override
  String get titleZA => 'Název (Z-A)';

  @override
  String get showTags => 'Zobrazit štítky';

  @override
  String get showNotePreviews => 'Zobrazit náhled';

  @override
  String get alternatingRowColors => 'Střídavé barvy řádků';

  @override
  String get animateAddButton => 'Animovat tlačítko přidání';

  @override
  String get untitled => '(Bez názvu)';

  @override
  String get today => 'Dnes';

  @override
  String get language => 'Jazyk';

  @override
  String get accentColor => 'Barva akcentu';

  @override
  String get systemDefault => 'Výchozí systémový';

  @override
  String startupError(String error) {
    return 'Při spuštění Fox došlo k chybě.\n\nZkuste vymazat data aplikace nebo ji znovu nainstalovat.\n\nChyba: $error';
  }
}
