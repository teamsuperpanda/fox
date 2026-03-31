// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get appTitle => 'Fox';

  @override
  String get search => 'Szukaj...';

  @override
  String get noNotesYet => 'Brak notatek...';

  @override
  String get noNotesMatchSearch => 'Brak notatek pasujących do wyszukiwania.';

  @override
  String get folders => 'Foldery';

  @override
  String get viewOptions => 'Opcje widoku';

  @override
  String get toggleTheme => 'Zmień motyw';

  @override
  String get clearFolderFilter => 'Wyczyść filtr folderów';

  @override
  String get unfiled => 'Nieskatalogowane';

  @override
  String get unknown => 'Nieznany';

  @override
  String get allNotes => 'Wszystkie notatki';

  @override
  String get newFolderName => 'Nazwa nowego folderu...';

  @override
  String get renameFolder => 'Zmień nazwę folderu';

  @override
  String get folderName => 'Nazwa folderu';

  @override
  String get deleteFolder => 'Usunąć folder?';

  @override
  String get deleteFolderMessage =>
      'Notatki w tym folderze nie zostaną usunięte, staną się nieskatalogowane.';

  @override
  String get rename => 'Zmień nazwę';

  @override
  String get delete => 'Usuń';

  @override
  String get cancel => 'Anuluj';

  @override
  String get close => 'Zamknij';

  @override
  String get deleteNote => 'Usunąć notatkę?';

  @override
  String get deleteNoteMessage => 'Czy na pewno chcesz usunąć tę notatkę?';

  @override
  String get noteDeleted => 'Notatka usunięta';

  @override
  String get undo => 'Cofnij';

  @override
  String get noteTitle => 'Tytuł notatki...';

  @override
  String get back => 'Wstecz';

  @override
  String get folder => 'Folder';

  @override
  String get tags => 'Tagi';

  @override
  String get noteColour => 'Kolor notatki';

  @override
  String get hideFormattingToolbar => 'Ukryj pasek formatowania';

  @override
  String get showFormattingToolbar => 'Pokaż pasek formatowania';

  @override
  String get unpin => 'Odepnij';

  @override
  String get pin => 'Przypnij';

  @override
  String get startTyping => 'Zacznij pisać...';

  @override
  String get manageTags => 'Zarządzaj tagami';

  @override
  String get newTag => 'Nowy tag...';

  @override
  String get moveToFolder => 'Przenieś do folderu';

  @override
  String get noFolder => 'Brak folderu';

  @override
  String get noteCannotBeEmpty => 'Notatka nie może być pusta';

  @override
  String get savingTitleOnly => 'Zapisywanie notatki tylko z tytułem';

  @override
  String errorSavingNote(String error) {
    return 'Błąd zapisu: $error';
  }

  @override
  String errorDeletingNote(String error) {
    return 'Błąd usuwania: $error';
  }

  @override
  String get sortBy => 'Sortuj według';

  @override
  String get dateNewestFirst => 'Data (najnowsze)';

  @override
  String get dateOldestFirst => 'Data (najstarsze)';

  @override
  String get titleAZ => 'Tytuł (A-Z)';

  @override
  String get titleZA => 'Tytuł (Z-A)';

  @override
  String get showTags => 'Pokaż tagi';

  @override
  String get showNotePreviews => 'Pokaż podglądy';

  @override
  String get alternatingRowColors => 'Naprzemienne kolory wierszy';

  @override
  String get animateAddButton => 'Animuj przycisk dodawania';

  @override
  String get untitled => '(Bez tytułu)';

  @override
  String get today => 'Dzisiaj';

  @override
  String get language => 'Język';

  @override
  String get accentColor => 'Kolor akcentu';

  @override
  String get systemDefault => 'Domyślny systemowy';

  @override
  String startupError(String error) {
    return 'Coś poszło nie tak podczas uruchamiania Fox.\n\nSpróbuj wyczyścić dane aplikacji lub zainstalować ją ponownie.\n\nBłąd: $error';
  }
}
