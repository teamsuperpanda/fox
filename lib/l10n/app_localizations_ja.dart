// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'Fox';

  @override
  String get search => '検索...';

  @override
  String get noNotesYet => 'ノートはまだありません...';

  @override
  String get noNotesMatchSearch => '検索に一致するノートがありません。';

  @override
  String get folders => 'フォルダ';

  @override
  String get viewOptions => '表示オプション';

  @override
  String get toggleTheme => 'テーマを切り替え';

  @override
  String get clearFolderFilter => 'フォルダフィルタを解除';

  @override
  String get unfiled => '未分類';

  @override
  String get unknown => '不明';

  @override
  String get allNotes => 'すべてのノート';

  @override
  String get newFolderName => '新しいフォルダ名...';

  @override
  String get renameFolder => 'フォルダ名を変更';

  @override
  String get folderName => 'フォルダ名';

  @override
  String get deleteFolder => 'フォルダを削除しますか？';

  @override
  String get deleteFolderMessage => 'このフォルダのノートは削除されず、未分類になります。';

  @override
  String get rename => '名前を変更';

  @override
  String get delete => '削除';

  @override
  String get cancel => 'キャンセル';

  @override
  String get close => '閉じる';

  @override
  String get deleteNote => 'ノートを削除しますか？';

  @override
  String get deleteNoteMessage => 'このノートを本当に削除しますか？';

  @override
  String get noteDeleted => 'ノートを削除しました';

  @override
  String get undo => '元に戻す';

  @override
  String get noteTitle => 'ノートのタイトル...';

  @override
  String get back => '戻る';

  @override
  String get folder => 'フォルダ';

  @override
  String get tags => 'タグ';

  @override
  String get noteColour => 'ノートの色';

  @override
  String get hideFormattingToolbar => '書式ツールバーを非表示';

  @override
  String get showFormattingToolbar => '書式ツールバーを表示';

  @override
  String get unpin => 'ピンを外す';

  @override
  String get pin => 'ピン留め';

  @override
  String get startTyping => '入力を開始...';

  @override
  String get manageTags => 'タグを管理';

  @override
  String get newTag => '新しいタグ...';

  @override
  String get moveToFolder => 'フォルダに移動';

  @override
  String get noFolder => 'フォルダなし';

  @override
  String get noteCannotBeEmpty => 'ノートは空にできません';

  @override
  String get savingTitleOnly => 'タイトルのみでノートを保存';

  @override
  String errorSavingNote(String error) {
    return '保存エラー: $error';
  }

  @override
  String errorDeletingNote(String error) {
    return '削除エラー: $error';
  }

  @override
  String get sortBy => '並べ替え';

  @override
  String get dateNewestFirst => '日付（新しい順）';

  @override
  String get dateOldestFirst => '日付（古い順）';

  @override
  String get titleAZ => 'タイトル (A-Z)';

  @override
  String get titleZA => 'タイトル (Z-A)';

  @override
  String get showTags => 'タグを表示';

  @override
  String get showNotePreviews => 'プレビューを表示';

  @override
  String get alternatingRowColors => '行の色を交互に表示';

  @override
  String get animateAddButton => '追加ボタンをアニメーション';

  @override
  String get untitled => '（無題）';

  @override
  String get today => '今日';

  @override
  String get language => '言語';

  @override
  String get accentColor => 'アクセントカラー';

  @override
  String get systemDefault => 'システムのデフォルト';

  @override
  String startupError(String error) {
    return 'Foxの起動中にエラーが発生しました。\n\nアプリデータを消去するか再インストールしてください。\n\nエラー: $error';
  }
}
