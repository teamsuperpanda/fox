// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'Fox';

  @override
  String get search => 'Cerca...';

  @override
  String get noNotesYet => 'Nessuna nota ancora...';

  @override
  String get noNotesMatchSearch => 'Nessuna nota corrisponde alla ricerca.';

  @override
  String get folders => 'Cartelle';

  @override
  String get viewOptions => 'Opzioni di visualizzazione';

  @override
  String get toggleTheme => 'Cambia tema';

  @override
  String get clearFolderFilter => 'Rimuovi filtro cartella';

  @override
  String get unfiled => 'Non archiviato';

  @override
  String get unknown => 'Sconosciuto';

  @override
  String get allNotes => 'Tutte le note';

  @override
  String get newFolderName => 'Nome nuova cartella...';

  @override
  String get renameFolder => 'Rinomina cartella';

  @override
  String get folderName => 'Nome cartella';

  @override
  String get deleteFolder => 'Eliminare cartella?';

  @override
  String get deleteFolderMessage =>
      'Le note in questa cartella non verranno eliminate, diventeranno non archiviate.';

  @override
  String get rename => 'Rinomina';

  @override
  String get delete => 'Elimina';

  @override
  String get cancel => 'Annulla';

  @override
  String get close => 'Chiudi';

  @override
  String get deleteNote => 'Eliminare nota?';

  @override
  String get deleteNoteMessage => 'Sei sicuro di voler eliminare questa nota?';

  @override
  String get noteDeleted => 'Nota eliminata';

  @override
  String get undo => 'Annulla';

  @override
  String get noteTitle => 'Titolo della nota...';

  @override
  String get back => 'Indietro';

  @override
  String get folder => 'Cartella';

  @override
  String get tags => 'Tag';

  @override
  String get noteColour => 'Colore nota';

  @override
  String get hideFormattingToolbar => 'Nascondi barra di formattazione';

  @override
  String get showFormattingToolbar => 'Mostra barra di formattazione';

  @override
  String get unpin => 'Sblocca';

  @override
  String get pin => 'Fissa';

  @override
  String get startTyping => 'Inizia a scrivere...';

  @override
  String get manageTags => 'Gestisci tag';

  @override
  String get newTag => 'Nuovo tag...';

  @override
  String get moveToFolder => 'Sposta in cartella';

  @override
  String get noFolder => 'Nessuna cartella';

  @override
  String get noteCannotBeEmpty => 'La nota non può essere vuota';

  @override
  String get savingTitleOnly => 'Salvataggio nota con solo titolo';

  @override
  String errorSavingNote(String error) {
    return 'Errore nel salvataggio: $error';
  }

  @override
  String errorDeletingNote(String error) {
    return 'Errore nell\'eliminazione: $error';
  }

  @override
  String get sortBy => 'Ordina per';

  @override
  String get dateNewestFirst => 'Data (più recente)';

  @override
  String get dateOldestFirst => 'Data (più vecchia)';

  @override
  String get titleAZ => 'Titolo (A-Z)';

  @override
  String get titleZA => 'Titolo (Z-A)';

  @override
  String get showTags => 'Mostra tag';

  @override
  String get showNotePreviews => 'Mostra anteprime';

  @override
  String get alternatingRowColors => 'Colori riga alternati';

  @override
  String get animateAddButton => 'Anima pulsante aggiungi';

  @override
  String get untitled => '(Senza titolo)';

  @override
  String get today => 'Oggi';

  @override
  String get language => 'Lingua';

  @override
  String get accentColor => 'Colore di evidenziazione';

  @override
  String get systemDefault => 'Predefinito di sistema';

  @override
  String startupError(String error) {
    return 'Qualcosa è andato storto all\'avvio di Fox.\n\nProva a cancellare i dati dell\'app o reinstallarla.\n\nErrore: $error';
  }
}
