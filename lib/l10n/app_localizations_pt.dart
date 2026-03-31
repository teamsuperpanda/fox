// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Fox';

  @override
  String get search => 'Pesquisar...';

  @override
  String get noNotesYet => 'Nenhuma nota ainda...';

  @override
  String get noNotesMatchSearch => 'Nenhuma nota corresponde à sua pesquisa.';

  @override
  String get folders => 'Pastas';

  @override
  String get viewOptions => 'Opções de visualização';

  @override
  String get toggleTheme => 'Alternar tema';

  @override
  String get clearFolderFilter => 'Limpar filtro de pasta';

  @override
  String get unfiled => 'Sem pasta';

  @override
  String get unknown => 'Desconhecido';

  @override
  String get allNotes => 'Todas as notas';

  @override
  String get newFolderName => 'Nome da nova pasta...';

  @override
  String get renameFolder => 'Renomear pasta';

  @override
  String get folderName => 'Nome da pasta';

  @override
  String get deleteFolder => 'Excluir pasta?';

  @override
  String get deleteFolderMessage =>
      'As notas desta pasta não serão excluídas, ficarão sem pasta.';

  @override
  String get rename => 'Renomear';

  @override
  String get delete => 'Excluir';

  @override
  String get cancel => 'Cancelar';

  @override
  String get close => 'Fechar';

  @override
  String get deleteNote => 'Excluir nota?';

  @override
  String get deleteNoteMessage =>
      'Tem certeza de que deseja excluir esta nota?';

  @override
  String get noteDeleted => 'Nota excluída';

  @override
  String get undo => 'Desfazer';

  @override
  String get noteTitle => 'Título da nota...';

  @override
  String get back => 'Voltar';

  @override
  String get folder => 'Pasta';

  @override
  String get tags => 'Tags';

  @override
  String get noteColour => 'Cor da nota';

  @override
  String get hideFormattingToolbar => 'Ocultar barra de formatação';

  @override
  String get showFormattingToolbar => 'Mostrar barra de formatação';

  @override
  String get unpin => 'Desafixar';

  @override
  String get pin => 'Fixar';

  @override
  String get startTyping => 'Comece a digitar...';

  @override
  String get manageTags => 'Gerenciar tags';

  @override
  String get newTag => 'Nova tag...';

  @override
  String get moveToFolder => 'Mover para pasta';

  @override
  String get noFolder => 'Sem pasta';

  @override
  String get noteCannotBeEmpty => 'A nota não pode estar vazia';

  @override
  String get savingTitleOnly => 'Salvando nota apenas com título';

  @override
  String errorSavingNote(String error) {
    return 'Erro ao salvar nota: $error';
  }

  @override
  String errorDeletingNote(String error) {
    return 'Erro ao excluir nota: $error';
  }

  @override
  String get sortBy => 'Ordenar por';

  @override
  String get dateNewestFirst => 'Data (mais recente)';

  @override
  String get dateOldestFirst => 'Data (mais antiga)';

  @override
  String get titleAZ => 'Título (A-Z)';

  @override
  String get titleZA => 'Título (Z-A)';

  @override
  String get showTags => 'Mostrar tags';

  @override
  String get showNotePreviews => 'Mostrar pré-visualização';

  @override
  String get alternatingRowColors => 'Cores de linha alternadas';

  @override
  String get animateAddButton => 'Animar botão de adicionar';

  @override
  String get untitled => '(Sem título)';

  @override
  String get today => 'Hoje';

  @override
  String get language => 'Idioma';

  @override
  String get accentColor => 'Cor de destaque';

  @override
  String get systemDefault => 'Padrão do sistema';

  @override
  String startupError(String error) {
    return 'Algo deu errado ao iniciar o Fox.\n\nTente limpar os dados do app ou reinstalá-lo.\n\nErro: $error';
  }
}

/// The translations for Portuguese, as used in Portugal (`pt_PT`).
class AppLocalizationsPtPt extends AppLocalizationsPt {
  AppLocalizationsPtPt() : super('pt_PT');

  @override
  String get appTitle => 'Fox';

  @override
  String get search => 'Pesquisar...';

  @override
  String get noNotesYet => 'Ainda sem notas...';

  @override
  String get noNotesMatchSearch => 'Nenhuma nota corresponde à sua pesquisa.';

  @override
  String get folders => 'Pastas';

  @override
  String get viewOptions => 'Opções de visualização';

  @override
  String get toggleTheme => 'Alternar tema';

  @override
  String get clearFolderFilter => 'Limpar filtro de pasta';

  @override
  String get unfiled => 'Sem pasta';

  @override
  String get unknown => 'Desconhecido';

  @override
  String get allNotes => 'Todas as notas';

  @override
  String get newFolderName => 'Nome da nova pasta...';

  @override
  String get renameFolder => 'Renomear pasta';

  @override
  String get folderName => 'Nome da pasta';

  @override
  String get deleteFolder => 'Eliminar pasta?';

  @override
  String get deleteFolderMessage =>
      'As notas nesta pasta não serão eliminadas, ficarão sem pasta.';

  @override
  String get rename => 'Renomear';

  @override
  String get delete => 'Eliminar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get close => 'Fechar';

  @override
  String get deleteNote => 'Eliminar nota?';

  @override
  String get deleteNoteMessage =>
      'Tem a certeza de que pretende eliminar esta nota?';

  @override
  String get noteDeleted => 'Nota eliminada';

  @override
  String get undo => 'Anular';

  @override
  String get noteTitle => 'Título da nota...';

  @override
  String get back => 'Voltar';

  @override
  String get folder => 'Pasta';

  @override
  String get tags => 'Etiquetas';

  @override
  String get noteColour => 'Cor da nota';

  @override
  String get hideFormattingToolbar => 'Ocultar barra de formatação';

  @override
  String get showFormattingToolbar => 'Mostrar barra de formatação';

  @override
  String get unpin => 'Desafixar';

  @override
  String get pin => 'Fixar';

  @override
  String get startTyping => 'Comece a escrever...';

  @override
  String get manageTags => 'Gerir etiquetas';

  @override
  String get newTag => 'Nova etiqueta...';

  @override
  String get moveToFolder => 'Mover para pasta';

  @override
  String get noFolder => 'Sem pasta';

  @override
  String get noteCannotBeEmpty => 'A nota não pode estar vazia';

  @override
  String get savingTitleOnly => 'A guardar nota apenas com título';

  @override
  String errorSavingNote(String error) {
    return 'Erro ao guardar nota: $error';
  }

  @override
  String errorDeletingNote(String error) {
    return 'Erro ao eliminar nota: $error';
  }

  @override
  String get sortBy => 'Ordenar por';

  @override
  String get dateNewestFirst => 'Data (mais recente)';

  @override
  String get dateOldestFirst => 'Data (mais antiga)';

  @override
  String get titleAZ => 'Título (A-Z)';

  @override
  String get titleZA => 'Título (Z-A)';

  @override
  String get showTags => 'Mostrar etiquetas';

  @override
  String get showNotePreviews => 'Mostrar pré-visualização';

  @override
  String get alternatingRowColors => 'Cores de linha alternadas';

  @override
  String get animateAddButton => 'Animar botão de adicionar';

  @override
  String get untitled => '(Sem título)';

  @override
  String get today => 'Hoje';

  @override
  String get language => 'Idioma';

  @override
  String get accentColor => 'Cor de destaque';

  @override
  String get systemDefault => 'Predefinição do sistema';

  @override
  String startupError(String error) {
    return 'Algo correu mal ao iniciar o Fox.\n\nTente limpar os dados da aplicação ou reinstalá-la.\n\nErro: $error';
  }
}
