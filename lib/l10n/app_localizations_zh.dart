// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Fox';

  @override
  String get search => '搜索...';

  @override
  String get noNotesYet => '还没有笔记...';

  @override
  String get noNotesMatchSearch => '没有匹配搜索的笔记。';

  @override
  String get folders => '文件夹';

  @override
  String get viewOptions => '显示选项';

  @override
  String get toggleTheme => '切换主题';

  @override
  String get clearFolderFilter => '清除文件夹筛选';

  @override
  String get unfiled => '未归档';

  @override
  String get unknown => '未知';

  @override
  String get allNotes => '所有笔记';

  @override
  String get newFolderName => '新文件夹名称...';

  @override
  String get renameFolder => '重命名文件夹';

  @override
  String get folderName => '文件夹名称';

  @override
  String get deleteFolder => '删除文件夹？';

  @override
  String get deleteFolderMessage => '此文件夹中的笔记不会被删除，将变为未归档状态。';

  @override
  String get rename => '重命名';

  @override
  String get delete => '删除';

  @override
  String get cancel => '取消';

  @override
  String get close => '关闭';

  @override
  String get deleteNote => '删除笔记？';

  @override
  String get deleteNoteMessage => '确定要删除此笔记吗？';

  @override
  String get noteDeleted => '笔记已删除';

  @override
  String get undo => '撤销';

  @override
  String get noteTitle => '笔记标题...';

  @override
  String get back => '返回';

  @override
  String get folder => '文件夹';

  @override
  String get tags => '标签';

  @override
  String get noteColour => '笔记颜色';

  @override
  String get hideFormattingToolbar => '隐藏格式工具栏';

  @override
  String get showFormattingToolbar => '显示格式工具栏';

  @override
  String get unpin => '取消置顶';

  @override
  String get pin => '置顶';

  @override
  String get startTyping => '开始输入...';

  @override
  String get manageTags => '管理标签';

  @override
  String get newTag => '新标签...';

  @override
  String get moveToFolder => '移至文件夹';

  @override
  String get noFolder => '无文件夹';

  @override
  String get noteCannotBeEmpty => '笔记不能为空';

  @override
  String get savingTitleOnly => '仅保存标题';

  @override
  String errorSavingNote(String error) {
    return '保存出错：$error';
  }

  @override
  String errorDeletingNote(String error) {
    return '删除出错：$error';
  }

  @override
  String get sortBy => '排序方式';

  @override
  String get dateNewestFirst => '日期（最新优先）';

  @override
  String get dateOldestFirst => '日期（最旧优先）';

  @override
  String get titleAZ => '标题 (A-Z)';

  @override
  String get titleZA => '标题 (Z-A)';

  @override
  String get showTags => '显示标签';

  @override
  String get showNotePreviews => '显示预览';

  @override
  String get alternatingRowColors => '交替行颜色';

  @override
  String get animateAddButton => '添加按钮动画';

  @override
  String get untitled => '（无标题）';

  @override
  String get today => '今天';

  @override
  String get language => '语言';

  @override
  String get accentColor => '强调色';

  @override
  String get systemDefault => '系统默认';

  @override
  String startupError(String error) {
    return 'Fox 启动时出现问题。\n\n请尝试清除应用数据或重新安装。\n\n错误：$error';
  }
}

/// The translations for Chinese, as used in Taiwan (`zh_TW`).
class AppLocalizationsZhTw extends AppLocalizationsZh {
  AppLocalizationsZhTw() : super('zh_TW');

  @override
  String get appTitle => 'Fox';

  @override
  String get search => '搜尋...';

  @override
  String get noNotesYet => '還沒有筆記...';

  @override
  String get noNotesMatchSearch => '沒有符合搜尋的筆記。';

  @override
  String get folders => '資料夾';

  @override
  String get viewOptions => '顯示選項';

  @override
  String get toggleTheme => '切換主題';

  @override
  String get clearFolderFilter => '清除資料夾篩選';

  @override
  String get unfiled => '未歸檔';

  @override
  String get unknown => '未知';

  @override
  String get allNotes => '所有筆記';

  @override
  String get newFolderName => '新資料夾名稱...';

  @override
  String get renameFolder => '重新命名資料夾';

  @override
  String get folderName => '資料夾名稱';

  @override
  String get deleteFolder => '刪除資料夾？';

  @override
  String get deleteFolderMessage => '此資料夾中的筆記不會被刪除，將變為未歸檔狀態。';

  @override
  String get rename => '重新命名';

  @override
  String get delete => '刪除';

  @override
  String get cancel => '取消';

  @override
  String get close => '關閉';

  @override
  String get deleteNote => '刪除筆記？';

  @override
  String get deleteNoteMessage => '確定要刪除此筆記嗎？';

  @override
  String get noteDeleted => '筆記已刪除';

  @override
  String get undo => '復原';

  @override
  String get noteTitle => '筆記標題...';

  @override
  String get back => '返回';

  @override
  String get folder => '資料夾';

  @override
  String get tags => '標籤';

  @override
  String get noteColour => '筆記顏色';

  @override
  String get hideFormattingToolbar => '隱藏格式工具列';

  @override
  String get showFormattingToolbar => '顯示格式工具列';

  @override
  String get unpin => '取消釘選';

  @override
  String get pin => '釘選';

  @override
  String get startTyping => '開始輸入...';

  @override
  String get manageTags => '管理標籤';

  @override
  String get newTag => '新標籤...';

  @override
  String get moveToFolder => '移至資料夾';

  @override
  String get noFolder => '無資料夾';

  @override
  String get noteCannotBeEmpty => '筆記不能為空';

  @override
  String get savingTitleOnly => '僅儲存標題';

  @override
  String errorSavingNote(String error) {
    return '儲存出錯：$error';
  }

  @override
  String errorDeletingNote(String error) {
    return '刪除出錯：$error';
  }

  @override
  String get sortBy => '排序方式';

  @override
  String get dateNewestFirst => '日期（最新優先）';

  @override
  String get dateOldestFirst => '日期（最舊優先）';

  @override
  String get titleAZ => '標題 (A-Z)';

  @override
  String get titleZA => '標題 (Z-A)';

  @override
  String get showTags => '顯示標籤';

  @override
  String get showNotePreviews => '顯示預覽';

  @override
  String get alternatingRowColors => '交替列顏色';

  @override
  String get animateAddButton => '新增按鈕動畫';

  @override
  String get untitled => '（無標題）';

  @override
  String get today => '今天';

  @override
  String get language => '語言';

  @override
  String get accentColor => '強調色';

  @override
  String get systemDefault => '系統預設';

  @override
  String startupError(String error) {
    return 'Fox 啟動時出現問題。\n\n請嘗試清除應用程式資料或重新安裝。\n\n錯誤：$error';
  }
}
