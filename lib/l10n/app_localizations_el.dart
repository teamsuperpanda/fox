// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Modern Greek (`el`).
class AppLocalizationsEl extends AppLocalizations {
  AppLocalizationsEl([String locale = 'el']) : super(locale);

  @override
  String get appTitle => 'Fox';

  @override
  String get search => 'Αναζήτηση...';

  @override
  String get noNotesYet => 'Δεν υπάρχουν σημειώσεις ακόμα...';

  @override
  String get noNotesMatchSearch =>
      'Καμία σημείωση δεν ταιριάζει με την αναζήτησή σας.';

  @override
  String get folders => 'Φάκελοι';

  @override
  String get viewOptions => 'Επιλογές Προβολής';

  @override
  String get toggleTheme => 'Εναλλαγή Θέματος';

  @override
  String get clearFolderFilter => 'Εκκαθάριση φίλτρου φακέλου';

  @override
  String get unfiled => 'Χωρίς φάκελο';

  @override
  String get unknown => 'Άγνωστο';

  @override
  String get allNotes => 'Όλες οι Σημειώσεις';

  @override
  String get newFolderName => 'Νέο όνομα φακέλου...';

  @override
  String get renameFolder => 'Μετονομασία φακέλου';

  @override
  String get folderName => 'Όνομα φακέλου';

  @override
  String get deleteFolder => 'Διαγραφή φακέλου;';

  @override
  String get deleteFolderMessage =>
      'Οι σημειώσεις σε αυτόν τον φάκελο δεν θα διαγραφούν, θα αρχειοθετηθούν χωρίς φάκελο.';

  @override
  String get rename => 'Μετονομασία';

  @override
  String get delete => 'Διαγραφή';

  @override
  String get cancel => 'Ακύρωση';

  @override
  String get close => 'Κλείσιμο';

  @override
  String get deleteNote => 'Διαγραφή σημείωσης;';

  @override
  String get deleteNoteMessage =>
      'Είστε σίγουροι ότι θέλετε να διαγράψετε αυτή τη σημείωση;';

  @override
  String get noteDeleted => 'Η σημείωση διαγράφηκε';

  @override
  String get undo => 'Αναίρεση';

  @override
  String get noteTitle => 'Τίτλος σημείωσης...';

  @override
  String get back => 'Πίσω';

  @override
  String get folder => 'Φάκελος';

  @override
  String get tags => 'Ετικέτες';

  @override
  String get noteColour => 'Χρώμα Σημείωσης';

  @override
  String get hideFormattingToolbar => 'Απόκρυψη γραμμής μορφοποίησης';

  @override
  String get showFormattingToolbar => 'Εμφάνιση γραμμής μορφοποίησης';

  @override
  String get unpin => 'Ξεκαρφίτσωμα';

  @override
  String get pin => 'Καρφίτσωμα';

  @override
  String get startTyping => 'Ξεκινήστε να πληκτρολογείτε...';

  @override
  String get manageTags => 'Διαχείριση ετικετών';

  @override
  String get newTag => 'Νέα ετικέτα...';

  @override
  String get moveToFolder => 'Μετακίνηση σε φάκελο';

  @override
  String get noFolder => 'Χωρίς φάκελο';

  @override
  String get noteCannotBeEmpty => 'Η σημείωση δεν μπορεί να είναι κενή';

  @override
  String get savingTitleOnly => 'Αποθήκευση σημείωσης μόνο με τίτλο';

  @override
  String errorSavingNote(String error) {
    return 'Σφάλμα κατά την αποθήκευση: $error';
  }

  @override
  String errorDeletingNote(String error) {
    return 'Σφάλμα κατά τη διαγραφή: $error';
  }

  @override
  String get sortBy => 'Ταξινόμηση κατά';

  @override
  String get dateNewestFirst => 'Ημερομηνία (νεότερα πρώτα)';

  @override
  String get dateOldestFirst => 'Ημερομηνία (παλαιότερα πρώτα)';

  @override
  String get titleAZ => 'Τίτλος (Α-Ω)';

  @override
  String get titleZA => 'Τίτλος (Ω-Α)';

  @override
  String get showTags => 'Εμφάνιση ετικετών';

  @override
  String get showNotePreviews => 'Εμφάνιση προεπισκόπησης';

  @override
  String get alternatingRowColors => 'Εναλλασσόμενα χρώματα γραμμών';

  @override
  String get animateAddButton => 'Κινούμενο κουμπί προσθήκης';

  @override
  String get untitled => '(Χωρίς τίτλο)';

  @override
  String get today => 'Σήμερα';

  @override
  String get language => 'Γλώσσα';

  @override
  String get accentColor => 'Χρώμα Τονισμού';

  @override
  String get systemDefault => 'Προεπιλογή συστήματος';

  @override
  String startupError(String error) {
    return 'Παρουσιάστηκε σφάλμα κατά την εκκίνηση του Fox.\n\nΔοκιμάστε να εκκαθαρίσετε τα δεδομένα εφαρμογής ή να επανεγκαταστήσετε.\n\nΣφάλμα: $error';
  }
}
