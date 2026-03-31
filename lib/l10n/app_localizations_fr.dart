// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Fox';

  @override
  String get search => 'Rechercher...';

  @override
  String get noNotesYet => 'Aucune note pour l\'instant...';

  @override
  String get noNotesMatchSearch =>
      'Aucune note ne correspond à votre recherche.';

  @override
  String get folders => 'Dossiers';

  @override
  String get viewOptions => 'Options d\'affichage';

  @override
  String get toggleTheme => 'Changer le thème';

  @override
  String get clearFolderFilter => 'Supprimer le filtre de dossier';

  @override
  String get unfiled => 'Non classé';

  @override
  String get unknown => 'Inconnu';

  @override
  String get allNotes => 'Toutes les notes';

  @override
  String get newFolderName => 'Nom du nouveau dossier...';

  @override
  String get renameFolder => 'Renommer le dossier';

  @override
  String get folderName => 'Nom du dossier';

  @override
  String get deleteFolder => 'Supprimer le dossier ?';

  @override
  String get deleteFolderMessage =>
      'Les notes de ce dossier ne seront pas supprimées, elles deviendront non classées.';

  @override
  String get rename => 'Renommer';

  @override
  String get delete => 'Supprimer';

  @override
  String get cancel => 'Annuler';

  @override
  String get close => 'Fermer';

  @override
  String get deleteNote => 'Supprimer la note ?';

  @override
  String get deleteNoteMessage =>
      'Êtes-vous sûr de vouloir supprimer cette note ?';

  @override
  String get noteDeleted => 'Note supprimée';

  @override
  String get undo => 'Annuler';

  @override
  String get noteTitle => 'Titre de la note...';

  @override
  String get back => 'Retour';

  @override
  String get folder => 'Dossier';

  @override
  String get tags => 'Étiquettes';

  @override
  String get noteColour => 'Couleur de la note';

  @override
  String get hideFormattingToolbar => 'Masquer la barre de mise en forme';

  @override
  String get showFormattingToolbar => 'Afficher la barre de mise en forme';

  @override
  String get unpin => 'Désépingler';

  @override
  String get pin => 'Épingler';

  @override
  String get startTyping => 'Commencez à écrire...';

  @override
  String get manageTags => 'Gérer les étiquettes';

  @override
  String get newTag => 'Nouvelle étiquette...';

  @override
  String get moveToFolder => 'Déplacer vers un dossier';

  @override
  String get noFolder => 'Aucun dossier';

  @override
  String get noteCannotBeEmpty => 'La note ne peut pas être vide';

  @override
  String get savingTitleOnly =>
      'Enregistrement de la note avec titre uniquement';

  @override
  String errorSavingNote(String error) {
    return 'Erreur lors de l\'enregistrement : $error';
  }

  @override
  String errorDeletingNote(String error) {
    return 'Erreur lors de la suppression : $error';
  }

  @override
  String get sortBy => 'Trier par';

  @override
  String get dateNewestFirst => 'Date (plus récente)';

  @override
  String get dateOldestFirst => 'Date (plus ancienne)';

  @override
  String get titleAZ => 'Titre (A-Z)';

  @override
  String get titleZA => 'Titre (Z-A)';

  @override
  String get showTags => 'Afficher les étiquettes';

  @override
  String get showNotePreviews => 'Afficher les aperçus';

  @override
  String get alternatingRowColors => 'Couleurs de lignes alternées';

  @override
  String get animateAddButton => 'Animer le bouton d\'ajout';

  @override
  String get untitled => '(Sans titre)';

  @override
  String get today => 'Aujourd\'hui';

  @override
  String get language => 'Langue';

  @override
  String get accentColor => 'Couleur d\'accentuation';

  @override
  String get systemDefault => 'Par défaut du système';

  @override
  String startupError(String error) {
    return 'Une erreur est survenue au lancement de Fox.\n\nEssayez de vider les données de l\'application ou de la réinstaller.\n\nErreur : $error';
  }
}
