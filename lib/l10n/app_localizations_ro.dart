// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Romanian Moldavian Moldovan (`ro`).
class AppLocalizationsRo extends AppLocalizations {
  AppLocalizationsRo([String locale = 'ro']) : super(locale);

  @override
  String get appTitle => 'Fox';

  @override
  String get search => 'Caută...';

  @override
  String get noNotesYet => 'Nicio notă încă...';

  @override
  String get noNotesMatchSearch => 'Nicio notă nu corespunde căutării.';

  @override
  String get folders => 'Dosare';

  @override
  String get viewOptions => 'Opțiuni de vizualizare';

  @override
  String get toggleTheme => 'Schimbă tema';

  @override
  String get clearFolderFilter => 'Șterge filtrul de dosar';

  @override
  String get unfiled => 'Fără dosar';

  @override
  String get unknown => 'Necunoscut';

  @override
  String get allNotes => 'Toate notele';

  @override
  String get newFolderName => 'Nume dosar nou...';

  @override
  String get renameFolder => 'Redenumește dosarul';

  @override
  String get folderName => 'Numele dosarului';

  @override
  String get deleteFolder => 'Ștergi dosarul?';

  @override
  String get deleteFolderMessage =>
      'Notele din acest dosar nu vor fi șterse, vor deveni neclasificate.';

  @override
  String get rename => 'Redenumește';

  @override
  String get delete => 'Șterge';

  @override
  String get cancel => 'Anulează';

  @override
  String get close => 'Închide';

  @override
  String get deleteNote => 'Ștergi nota?';

  @override
  String get deleteNoteMessage => 'Ești sigur că vrei să ștergi această notă?';

  @override
  String get noteDeleted => 'Notă ștearsă';

  @override
  String get undo => 'Anulează';

  @override
  String get noteTitle => 'Titlul notei...';

  @override
  String get back => 'Înapoi';

  @override
  String get folder => 'Dosar';

  @override
  String get tags => 'Etichete';

  @override
  String get noteColour => 'Culoarea notei';

  @override
  String get hideFormattingToolbar => 'Ascunde bara de formatare';

  @override
  String get showFormattingToolbar => 'Afișează bara de formatare';

  @override
  String get unpin => 'Anulează fixarea';

  @override
  String get pin => 'Fixează';

  @override
  String get startTyping => 'Începe să scrii...';

  @override
  String get manageTags => 'Gestionează etichetele';

  @override
  String get newTag => 'Etichetă nouă...';

  @override
  String get moveToFolder => 'Mută în dosar';

  @override
  String get noFolder => 'Fără dosar';

  @override
  String get noteCannotBeEmpty => 'Nota nu poate fi goală';

  @override
  String get savingTitleOnly => 'Se salvează nota doar cu titlul';

  @override
  String errorSavingNote(String error) {
    return 'Eroare la salvare: $error';
  }

  @override
  String errorDeletingNote(String error) {
    return 'Eroare la ștergere: $error';
  }

  @override
  String get sortBy => 'Sortare după';

  @override
  String get dateNewestFirst => 'Dată (cele mai noi)';

  @override
  String get dateOldestFirst => 'Dată (cele mai vechi)';

  @override
  String get titleAZ => 'Titlu (A-Z)';

  @override
  String get titleZA => 'Titlu (Z-A)';

  @override
  String get showTags => 'Afișează etichetele';

  @override
  String get showNotePreviews => 'Afișează previzualizarea';

  @override
  String get alternatingRowColors => 'Culori alternante ale rândurilor';

  @override
  String get animateAddButton => 'Animează butonul de adăugare';

  @override
  String get untitled => '(Fără titlu)';

  @override
  String get today => 'Astăzi';

  @override
  String get language => 'Limbă';

  @override
  String get accentColor => 'Culoare de accent';

  @override
  String get systemDefault => 'Implicit sistem';

  @override
  String startupError(String error) {
    return 'A apărut o eroare la pornirea Fox.\n\nÎncercați să ștergeți datele aplicației sau să o reinstalați.\n\nEroare: $error';
  }
}
