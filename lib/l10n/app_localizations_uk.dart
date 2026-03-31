// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class AppLocalizationsUk extends AppLocalizations {
  AppLocalizationsUk([String locale = 'uk']) : super(locale);

  @override
  String get appTitle => 'Fox';

  @override
  String get search => 'Пошук...';

  @override
  String get noNotesYet => 'Ще немає нотаток...';

  @override
  String get noNotesMatchSearch => 'Жодна нотатка не відповідає вашому пошуку.';

  @override
  String get folders => 'Папки';

  @override
  String get viewOptions => 'Параметри перегляду';

  @override
  String get toggleTheme => 'Змінити тему';

  @override
  String get clearFolderFilter => 'Очистити фільтр папок';

  @override
  String get unfiled => 'Без папки';

  @override
  String get unknown => 'Невідомо';

  @override
  String get allNotes => 'Усі нотатки';

  @override
  String get newFolderName => 'Назва нової папки...';

  @override
  String get renameFolder => 'Перейменувати папку';

  @override
  String get folderName => 'Назва папки';

  @override
  String get deleteFolder => 'Видалити папку?';

  @override
  String get deleteFolderMessage =>
      'Нотатки в цій папці не будуть видалені, вони стануть без папки.';

  @override
  String get rename => 'Перейменувати';

  @override
  String get delete => 'Видалити';

  @override
  String get cancel => 'Скасувати';

  @override
  String get close => 'Закрити';

  @override
  String get deleteNote => 'Видалити нотатку?';

  @override
  String get deleteNoteMessage => 'Ви впевнені, що хочете видалити цю нотатку?';

  @override
  String get noteDeleted => 'Нотатку видалено';

  @override
  String get undo => 'Скасувати';

  @override
  String get noteTitle => 'Назва нотатки...';

  @override
  String get back => 'Назад';

  @override
  String get folder => 'Папка';

  @override
  String get tags => 'Теги';

  @override
  String get noteColour => 'Колір нотатки';

  @override
  String get hideFormattingToolbar => 'Приховати панель форматування';

  @override
  String get showFormattingToolbar => 'Показати панель форматування';

  @override
  String get unpin => 'Відкріпити';

  @override
  String get pin => 'Закріпити';

  @override
  String get startTyping => 'Почніть писати...';

  @override
  String get manageTags => 'Керувати тегами';

  @override
  String get newTag => 'Новий тег...';

  @override
  String get moveToFolder => 'Перемістити в папку';

  @override
  String get noFolder => 'Без папки';

  @override
  String get noteCannotBeEmpty => 'Нотатка не може бути порожньою';

  @override
  String get savingTitleOnly => 'Збереження нотатки лише з назвою';

  @override
  String errorSavingNote(String error) {
    return 'Помилка збереження: $error';
  }

  @override
  String errorDeletingNote(String error) {
    return 'Помилка видалення: $error';
  }

  @override
  String get sortBy => 'Сортувати за';

  @override
  String get dateNewestFirst => 'Дата (спочатку нові)';

  @override
  String get dateOldestFirst => 'Дата (спочатку старі)';

  @override
  String get titleAZ => 'Назва (А-Я)';

  @override
  String get titleZA => 'Назва (Я-А)';

  @override
  String get showTags => 'Показувати теги';

  @override
  String get showNotePreviews => 'Показувати попередній перегляд';

  @override
  String get alternatingRowColors => 'Чергування кольорів рядків';

  @override
  String get animateAddButton => 'Анімація кнопки додавання';

  @override
  String get untitled => '(Без назви)';

  @override
  String get today => 'Сьогодні';

  @override
  String get language => 'Мова';

  @override
  String get accentColor => 'Колір акценту';

  @override
  String get systemDefault => 'Системна за замовчуванням';

  @override
  String startupError(String error) {
    return 'Помилка запуску Fox.\n\nСпробуйте очистити дані додатку або перевстановити.\n\nПомилка: $error';
  }
}
