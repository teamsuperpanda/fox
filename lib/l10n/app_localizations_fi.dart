// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Finnish (`fi`).
class AppLocalizationsFi extends AppLocalizations {
  AppLocalizationsFi([String locale = 'fi']) : super(locale);

  @override
  String get appTitle => 'Fox';

  @override
  String get search => 'Hae...';

  @override
  String get noNotesYet => 'Ei muistiinpanoja vielä...';

  @override
  String get noNotesMatchSearch =>
      'Hakuasi vastaavia muistiinpanoja ei löytynyt.';

  @override
  String get folders => 'Kansiot';

  @override
  String get viewOptions => 'Näkymäasetukset';

  @override
  String get toggleTheme => 'Vaihda teemaa';

  @override
  String get clearFolderFilter => 'Tyhjennä kansiosuodatin';

  @override
  String get unfiled => 'Ei kansiossa';

  @override
  String get unknown => 'Tuntematon';

  @override
  String get allNotes => 'Kaikki muistiinpanot';

  @override
  String get newFolderName => 'Uuden kansion nimi...';

  @override
  String get renameFolder => 'Nimeä kansio uudelleen';

  @override
  String get folderName => 'Kansion nimi';

  @override
  String get deleteFolder => 'Poista kansio?';

  @override
  String get deleteFolderMessage =>
      'Kansion muistiinpanoja ei poisteta, ne siirretään kansioimattomiin.';

  @override
  String get rename => 'Nimeä uudelleen';

  @override
  String get delete => 'Poista';

  @override
  String get cancel => 'Peruuta';

  @override
  String get close => 'Sulje';

  @override
  String get deleteNote => 'Poista muistiinpano?';

  @override
  String get deleteNoteMessage =>
      'Haluatko varmasti poistaa tämän muistiinpanon?';

  @override
  String get noteDeleted => 'Muistiinpano poistettu';

  @override
  String get undo => 'Kumoa';

  @override
  String get noteTitle => 'Muistiinpanon otsikko...';

  @override
  String get back => 'Takaisin';

  @override
  String get folder => 'Kansio';

  @override
  String get tags => 'Tunnisteet';

  @override
  String get noteColour => 'Muistiinpanon väri';

  @override
  String get hideFormattingToolbar => 'Piilota muotoilutyökalurivi';

  @override
  String get showFormattingToolbar => 'Näytä muotoilutyökalurivi';

  @override
  String get unpin => 'Irrota';

  @override
  String get pin => 'Kiinnitä';

  @override
  String get startTyping => 'Ala kirjoittaa...';

  @override
  String get manageTags => 'Hallitse tunnisteita';

  @override
  String get newTag => 'Uusi tunniste...';

  @override
  String get moveToFolder => 'Siirrä kansioon';

  @override
  String get noFolder => 'Ei kansiota';

  @override
  String get noteCannotBeEmpty => 'Muistiinpano ei voi olla tyhjä';

  @override
  String get savingTitleOnly => 'Tallennetaan muistiinpano vain otsikolla';

  @override
  String errorSavingNote(String error) {
    return 'Virhe tallennuksessa: $error';
  }

  @override
  String errorDeletingNote(String error) {
    return 'Virhe poistamisessa: $error';
  }

  @override
  String get sortBy => 'Lajittele';

  @override
  String get dateNewestFirst => 'Päivämäärä (uusin ensin)';

  @override
  String get dateOldestFirst => 'Päivämäärä (vanhin ensin)';

  @override
  String get titleAZ => 'Otsikko (A-Ö)';

  @override
  String get titleZA => 'Otsikko (Ö-A)';

  @override
  String get showTags => 'Näytä tunnisteet';

  @override
  String get showNotePreviews => 'Näytä esikatselut';

  @override
  String get alternatingRowColors => 'Vuorottelevat rivivärit';

  @override
  String get animateAddButton => 'Animoi lisäyspainike';

  @override
  String get untitled => '(Nimetön)';

  @override
  String get today => 'Tänään';

  @override
  String get language => 'Kieli';

  @override
  String get accentColor => 'Korostusväri';

  @override
  String get systemDefault => 'Järjestelmän oletus';

  @override
  String startupError(String error) {
    return 'Fox-sovelluksen käynnistämisessä tapahtui virhe.\n\nYritä tyhjentää sovellustiedot tai asenna uudelleen.\n\nVirhe: $error';
  }
}
