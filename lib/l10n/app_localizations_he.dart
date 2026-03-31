// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hebrew (`he`).
class AppLocalizationsHe extends AppLocalizations {
  AppLocalizationsHe([String locale = 'he']) : super(locale);

  @override
  String get appTitle => 'Fox';

  @override
  String get search => 'חיפוש...';

  @override
  String get noNotesYet => 'אין פתקים עדיין...';

  @override
  String get noNotesMatchSearch => 'אין פתקים התואמים לחיפוש שלך.';

  @override
  String get folders => 'תיקיות';

  @override
  String get viewOptions => 'אפשרויות תצוגה';

  @override
  String get toggleTheme => 'החלף ערכת נושא';

  @override
  String get clearFolderFilter => 'נקה סינון תיקיות';

  @override
  String get unfiled => 'ללא תיקיה';

  @override
  String get unknown => 'לא ידוע';

  @override
  String get allNotes => 'כל הפתקים';

  @override
  String get newFolderName => 'שם תיקיה חדש...';

  @override
  String get renameFolder => 'שנה שם תיקיה';

  @override
  String get folderName => 'שם תיקיה';

  @override
  String get deleteFolder => 'למחוק תיקיה?';

  @override
  String get deleteFolderMessage =>
      'הפתקים בתיקיה זו לא יימחקו, הם יישמרו ללא תיקיה.';

  @override
  String get rename => 'שנה שם';

  @override
  String get delete => 'מחק';

  @override
  String get cancel => 'ביטול';

  @override
  String get close => 'סגור';

  @override
  String get deleteNote => 'למחוק פתק?';

  @override
  String get deleteNoteMessage => 'האם אתה בטוח שברצונך למחוק פתק זה?';

  @override
  String get noteDeleted => 'הפתק נמחק';

  @override
  String get undo => 'בטל';

  @override
  String get noteTitle => 'כותרת הפתק...';

  @override
  String get back => 'חזרה';

  @override
  String get folder => 'תיקיה';

  @override
  String get tags => 'תגיות';

  @override
  String get noteColour => 'צבע הפתק';

  @override
  String get hideFormattingToolbar => 'הסתר סרגל עיצוב';

  @override
  String get showFormattingToolbar => 'הצג סרגל עיצוב';

  @override
  String get unpin => 'בטל הצמדה';

  @override
  String get pin => 'הצמד';

  @override
  String get startTyping => 'התחל להקליד...';

  @override
  String get manageTags => 'נהל תגיות';

  @override
  String get newTag => 'תגית חדשה...';

  @override
  String get moveToFolder => 'העבר לתיקיה';

  @override
  String get noFolder => 'ללא תיקיה';

  @override
  String get noteCannotBeEmpty => 'הפתק לא יכול להיות ריק';

  @override
  String get savingTitleOnly => 'שומר פתק עם כותרת בלבד';

  @override
  String errorSavingNote(String error) {
    return 'שגיאה בשמירה: $error';
  }

  @override
  String errorDeletingNote(String error) {
    return 'שגיאה במחיקה: $error';
  }

  @override
  String get sortBy => 'מיין לפי';

  @override
  String get dateNewestFirst => 'תאריך (החדש ביותר)';

  @override
  String get dateOldestFirst => 'תאריך (הישן ביותר)';

  @override
  String get titleAZ => 'כותרת (א-ת)';

  @override
  String get titleZA => 'כותרת (ת-א)';

  @override
  String get showTags => 'הצג תגיות';

  @override
  String get showNotePreviews => 'הצג תצוגה מקדימה';

  @override
  String get alternatingRowColors => 'צבעי שורות מתחלפים';

  @override
  String get animateAddButton => 'הנפש כפתור הוספה';

  @override
  String get untitled => '(ללא כותרת)';

  @override
  String get today => 'היום';

  @override
  String get language => 'שפה';

  @override
  String get accentColor => 'צבע הדגשה';

  @override
  String get systemDefault => 'ברירת מחדל של המערכת';

  @override
  String startupError(String error) {
    return 'אירעה שגיאה בהפעלת Fox.\n\nנסה לנקות את נתוני האפליקציה או להתקין מחדש.\n\nשגיאה: $error';
  }
}
