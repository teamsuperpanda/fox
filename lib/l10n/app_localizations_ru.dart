// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Fox';

  @override
  String get search => 'Поиск...';

  @override
  String get noNotesYet => 'Заметок пока нет...';

  @override
  String get noNotesMatchSearch => 'Нет заметок, соответствующих поиску.';

  @override
  String get folders => 'Папки';

  @override
  String get viewOptions => 'Параметры отображения';

  @override
  String get toggleTheme => 'Переключить тему';

  @override
  String get clearFolderFilter => 'Сбросить фильтр папки';

  @override
  String get unfiled => 'Без папки';

  @override
  String get unknown => 'Неизвестно';

  @override
  String get allNotes => 'Все заметки';

  @override
  String get newFolderName => 'Имя новой папки...';

  @override
  String get renameFolder => 'Переименовать папку';

  @override
  String get folderName => 'Имя папки';

  @override
  String get deleteFolder => 'Удалить папку?';

  @override
  String get deleteFolderMessage =>
      'Заметки в этой папке не будут удалены, они станут без папки.';

  @override
  String get rename => 'Переименовать';

  @override
  String get delete => 'Удалить';

  @override
  String get cancel => 'Отмена';

  @override
  String get close => 'Закрыть';

  @override
  String get deleteNote => 'Удалить заметку?';

  @override
  String get deleteNoteMessage => 'Вы уверены, что хотите удалить эту заметку?';

  @override
  String get noteDeleted => 'Заметка удалена';

  @override
  String get undo => 'Отменить';

  @override
  String get noteTitle => 'Заголовок заметки...';

  @override
  String get back => 'Назад';

  @override
  String get folder => 'Папка';

  @override
  String get tags => 'Теги';

  @override
  String get noteColour => 'Цвет заметки';

  @override
  String get hideFormattingToolbar => 'Скрыть панель форматирования';

  @override
  String get showFormattingToolbar => 'Показать панель форматирования';

  @override
  String get unpin => 'Открепить';

  @override
  String get pin => 'Закрепить';

  @override
  String get startTyping => 'Начните вводить...';

  @override
  String get manageTags => 'Управление тегами';

  @override
  String get newTag => 'Новый тег...';

  @override
  String get moveToFolder => 'Переместить в папку';

  @override
  String get noFolder => 'Без папки';

  @override
  String get noteCannotBeEmpty => 'Заметка не может быть пустой';

  @override
  String get savingTitleOnly => 'Сохранение заметки только с заголовком';

  @override
  String errorSavingNote(String error) {
    return 'Ошибка сохранения: $error';
  }

  @override
  String errorDeletingNote(String error) {
    return 'Ошибка удаления: $error';
  }

  @override
  String get sortBy => 'Сортировка';

  @override
  String get dateNewestFirst => 'Дата (сначала новые)';

  @override
  String get dateOldestFirst => 'Дата (сначала старые)';

  @override
  String get titleAZ => 'Заголовок (А-Я)';

  @override
  String get titleZA => 'Заголовок (Я-А)';

  @override
  String get showTags => 'Показать теги';

  @override
  String get showNotePreviews => 'Показать предпросмотр';

  @override
  String get alternatingRowColors => 'Чередующиеся цвета строк';

  @override
  String get animateAddButton => 'Анимация кнопки добавления';

  @override
  String get untitled => '(Без заголовка)';

  @override
  String get today => 'Сегодня';

  @override
  String get language => 'Язык';

  @override
  String get accentColor => 'Цвет акцента';

  @override
  String get systemDefault => 'Системный по умолчанию';

  @override
  String startupError(String error) {
    return 'Произошла ошибка при запуске Fox.\n\nПопробуйте очистить данные приложения или переустановить его.\n\nОшибка: $error';
  }
}
