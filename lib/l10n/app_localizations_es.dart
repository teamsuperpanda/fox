// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Fox';

  @override
  String get search => 'Buscar...';

  @override
  String get noNotesYet => 'Aún no hay notas...';

  @override
  String get noNotesMatchSearch => 'Ninguna nota coincide con tu búsqueda.';

  @override
  String get folders => 'Carpetas';

  @override
  String get viewOptions => 'Opciones de vista';

  @override
  String get toggleTheme => 'Cambiar tema';

  @override
  String get clearFolderFilter => 'Quitar filtro de carpeta';

  @override
  String get unfiled => 'Sin carpeta';

  @override
  String get unknown => 'Desconocido';

  @override
  String get allNotes => 'Todas las notas';

  @override
  String get newFolderName => 'Nombre de nueva carpeta...';

  @override
  String get renameFolder => 'Renombrar carpeta';

  @override
  String get folderName => 'Nombre de carpeta';

  @override
  String get deleteFolder => '¿Eliminar carpeta?';

  @override
  String get deleteFolderMessage =>
      'Las notas de esta carpeta no se eliminarán, quedarán sin carpeta.';

  @override
  String get rename => 'Renombrar';

  @override
  String get delete => 'Eliminar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get close => 'Cerrar';

  @override
  String get deleteNote => '¿Eliminar nota?';

  @override
  String get deleteNoteMessage =>
      '¿Estás seguro de que quieres eliminar esta nota?';

  @override
  String get noteDeleted => 'Nota eliminada';

  @override
  String get undo => 'Deshacer';

  @override
  String get noteTitle => 'Título de la nota...';

  @override
  String get back => 'Atrás';

  @override
  String get folder => 'Carpeta';

  @override
  String get tags => 'Etiquetas';

  @override
  String get noteColour => 'Color de nota';

  @override
  String get hideFormattingToolbar => 'Ocultar barra de formato';

  @override
  String get showFormattingToolbar => 'Mostrar barra de formato';

  @override
  String get unpin => 'Desanclar';

  @override
  String get pin => 'Anclar';

  @override
  String get startTyping => 'Empieza a escribir...';

  @override
  String get manageTags => 'Gestionar etiquetas';

  @override
  String get newTag => 'Nueva etiqueta...';

  @override
  String get moveToFolder => 'Mover a carpeta';

  @override
  String get noFolder => 'Sin carpeta';

  @override
  String get noteCannotBeEmpty => 'La nota no puede estar vacía';

  @override
  String get savingTitleOnly => 'Guardando nota solo con título';

  @override
  String errorSavingNote(String error) {
    return 'Error al guardar nota: $error';
  }

  @override
  String errorDeletingNote(String error) {
    return 'Error al eliminar nota: $error';
  }

  @override
  String get sortBy => 'Ordenar por';

  @override
  String get dateNewestFirst => 'Fecha (más reciente)';

  @override
  String get dateOldestFirst => 'Fecha (más antigua)';

  @override
  String get titleAZ => 'Título (A-Z)';

  @override
  String get titleZA => 'Título (Z-A)';

  @override
  String get showTags => 'Mostrar etiquetas';

  @override
  String get showNotePreviews => 'Mostrar vista previa';

  @override
  String get alternatingRowColors => 'Colores de fila alternados';

  @override
  String get animateAddButton => 'Animar botón de añadir';

  @override
  String get untitled => '(Sin título)';

  @override
  String get today => 'Hoy';

  @override
  String get language => 'Idioma';

  @override
  String get accentColor => 'Color de acento';

  @override
  String get systemDefault => 'Predeterminado del sistema';

  @override
  String startupError(String error) {
    return 'Algo salió mal al iniciar Fox.\n\nIntenta borrar los datos de la app o reinstalarla.\n\nError: $error';
  }
}

/// The translations for Spanish Castilian, as used in Latin America and the Caribbean (`es_419`).
class AppLocalizationsEs419 extends AppLocalizationsEs {
  AppLocalizationsEs419() : super('es_419');

  @override
  String get appTitle => 'Fox';

  @override
  String get search => 'Buscar...';

  @override
  String get noNotesYet => 'Aún no hay notas...';

  @override
  String get noNotesMatchSearch =>
      'No hay notas que coincidan con tu búsqueda.';

  @override
  String get folders => 'Carpetas';

  @override
  String get viewOptions => 'Opciones de vista';

  @override
  String get toggleTheme => 'Cambiar tema';

  @override
  String get clearFolderFilter => 'Borrar filtro de carpeta';

  @override
  String get unfiled => 'Sin carpeta';

  @override
  String get unknown => 'Desconocido';

  @override
  String get allNotes => 'Todas las notas';

  @override
  String get newFolderName => 'Nombre de la nueva carpeta...';

  @override
  String get renameFolder => 'Renombrar carpeta';

  @override
  String get folderName => 'Nombre de carpeta';

  @override
  String get deleteFolder => '¿Eliminar carpeta?';

  @override
  String get deleteFolderMessage =>
      'Las notas en esta carpeta no se eliminarán, quedarán sin carpeta.';

  @override
  String get rename => 'Renombrar';

  @override
  String get delete => 'Eliminar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get close => 'Cerrar';

  @override
  String get deleteNote => '¿Eliminar nota?';

  @override
  String get deleteNoteMessage =>
      '¿Estás seguro de que quieres eliminar esta nota?';

  @override
  String get noteDeleted => 'Nota eliminada';

  @override
  String get undo => 'Deshacer';

  @override
  String get noteTitle => 'Título de la nota...';

  @override
  String get back => 'Atrás';

  @override
  String get folder => 'Carpeta';

  @override
  String get tags => 'Etiquetas';

  @override
  String get noteColour => 'Color de nota';

  @override
  String get hideFormattingToolbar => 'Ocultar barra de formato';

  @override
  String get showFormattingToolbar => 'Mostrar barra de formato';

  @override
  String get unpin => 'Desfijar';

  @override
  String get pin => 'Fijar';

  @override
  String get startTyping => 'Empieza a escribir...';

  @override
  String get manageTags => 'Administrar etiquetas';

  @override
  String get newTag => 'Nueva etiqueta...';

  @override
  String get moveToFolder => 'Mover a carpeta';

  @override
  String get noFolder => 'Sin carpeta';

  @override
  String get noteCannotBeEmpty => 'La nota no puede estar vacía';

  @override
  String get savingTitleOnly => 'Guardando nota solo con título';

  @override
  String errorSavingNote(String error) {
    return 'Error al guardar: $error';
  }

  @override
  String errorDeletingNote(String error) {
    return 'Error al eliminar: $error';
  }

  @override
  String get sortBy => 'Ordenar por';

  @override
  String get dateNewestFirst => 'Fecha (más reciente)';

  @override
  String get dateOldestFirst => 'Fecha (más antigua)';

  @override
  String get titleAZ => 'Título (A-Z)';

  @override
  String get titleZA => 'Título (Z-A)';

  @override
  String get showTags => 'Mostrar etiquetas';

  @override
  String get showNotePreviews => 'Mostrar vista previa';

  @override
  String get alternatingRowColors => 'Colores de fila alternados';

  @override
  String get animateAddButton => 'Animar botón de agregar';

  @override
  String get untitled => '(Sin título)';

  @override
  String get today => 'Hoy';

  @override
  String get language => 'Idioma';

  @override
  String get accentColor => 'Color de acento';

  @override
  String get systemDefault => 'Predeterminado del sistema';

  @override
  String startupError(String error) {
    return 'Algo salió mal al iniciar Fox.\n\nIntenta borrar los datos de la app o reinstalarla.\n\nError: $error';
  }
}
