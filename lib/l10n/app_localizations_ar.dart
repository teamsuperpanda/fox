// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'Fox';

  @override
  String get search => 'بحث...';

  @override
  String get noNotesYet => 'لا توجد ملاحظات بعد...';

  @override
  String get noNotesMatchSearch => 'لا توجد ملاحظات تطابق بحثك.';

  @override
  String get folders => 'المجلدات';

  @override
  String get viewOptions => 'خيارات العرض';

  @override
  String get toggleTheme => 'تبديل المظهر';

  @override
  String get clearFolderFilter => 'مسح تصفية المجلد';

  @override
  String get unfiled => 'غير مصنف';

  @override
  String get unknown => 'غير معروف';

  @override
  String get allNotes => 'جميع الملاحظات';

  @override
  String get newFolderName => 'اسم المجلد الجديد...';

  @override
  String get renameFolder => 'إعادة تسمية المجلد';

  @override
  String get folderName => 'اسم المجلد';

  @override
  String get deleteFolder => 'حذف المجلد؟';

  @override
  String get deleteFolderMessage =>
      'لن يتم حذف الملاحظات في هذا المجلد، ستصبح غير مصنفة.';

  @override
  String get rename => 'إعادة تسمية';

  @override
  String get delete => 'حذف';

  @override
  String get cancel => 'إلغاء';

  @override
  String get close => 'إغلاق';

  @override
  String get deleteNote => 'حذف الملاحظة؟';

  @override
  String get deleteNoteMessage => 'هل أنت متأكد من حذف هذه الملاحظة؟';

  @override
  String get noteDeleted => 'تم حذف الملاحظة';

  @override
  String get undo => 'تراجع';

  @override
  String get noteTitle => 'عنوان الملاحظة...';

  @override
  String get back => 'رجوع';

  @override
  String get folder => 'مجلد';

  @override
  String get tags => 'الوسوم';

  @override
  String get noteColour => 'لون الملاحظة';

  @override
  String get hideFormattingToolbar => 'إخفاء شريط التنسيق';

  @override
  String get showFormattingToolbar => 'إظهار شريط التنسيق';

  @override
  String get unpin => 'إلغاء التثبيت';

  @override
  String get pin => 'تثبيت';

  @override
  String get startTyping => 'ابدأ بالكتابة...';

  @override
  String get manageTags => 'إدارة الوسوم';

  @override
  String get newTag => 'وسم جديد...';

  @override
  String get moveToFolder => 'نقل إلى مجلد';

  @override
  String get noFolder => 'بدون مجلد';

  @override
  String get noteCannotBeEmpty => 'لا يمكن أن تكون الملاحظة فارغة';

  @override
  String get savingTitleOnly => 'حفظ الملاحظة بالعنوان فقط';

  @override
  String errorSavingNote(String error) {
    return 'خطأ في الحفظ: $error';
  }

  @override
  String errorDeletingNote(String error) {
    return 'خطأ في الحذف: $error';
  }

  @override
  String get sortBy => 'ترتيب حسب';

  @override
  String get dateNewestFirst => 'التاريخ (الأحدث أولاً)';

  @override
  String get dateOldestFirst => 'التاريخ (الأقدم أولاً)';

  @override
  String get titleAZ => 'العنوان (أ-ي)';

  @override
  String get titleZA => 'العنوان (ي-أ)';

  @override
  String get showTags => 'إظهار الوسوم';

  @override
  String get showNotePreviews => 'إظهار المعاينات';

  @override
  String get alternatingRowColors => 'ألوان صفوف متبادلة';

  @override
  String get animateAddButton => 'تحريك زر الإضافة';

  @override
  String get untitled => '(بدون عنوان)';

  @override
  String get today => 'اليوم';

  @override
  String get language => 'اللغة';

  @override
  String get accentColor => 'لون التمييز';

  @override
  String get analytics => 'تحليلات';

  @override
  String get systemDefault => 'الافتراضي للنظام';

  @override
  String startupError(String error) {
    return 'حدث خطأ أثناء بدء تشغيل Fox.\n\nحاول مسح بيانات التطبيق أو إعادة تثبيته.\n\nخطأ: $error';
  }

  @override
  String get nativeName => 'العربية';

  @override
  String get screenshotLightTagline => 'ملاحظاتك، بطريقتك';

  @override
  String get screenshotLightMarketing1 => 'نظم أفكارك بالنص المنسق';

  @override
  String get screenshotLightMarketing2 => 'سريع، خاص، يعمل بدون إنترنت';

  @override
  String get screenshotDarkTagline => 'جميل في الوضع الفاتح أو الداكن';

  @override
  String get screenshotDarkMarketing1 => 'دعم كامل للوضع الداكن';

  @override
  String get screenshotDarkMarketing2 => 'مريح للعينين، دائماً';

  @override
  String get screenshotNewNoteTagline => 'التقط الأفكار فوراً';

  @override
  String get screenshotNewNoteMarketing1 => 'نص منسق • قوائم مراجعة • ألوان';

  @override
  String get screenshotNewNoteMarketing2 => 'كل ما تحتاجه';

  @override
  String get screenshotSettingsTagline => 'خصص التطبيق بطريقتك';

  @override
  String get screenshotSettingsMarketing1 =>
      'ألوان مميزة • خيارات الفرز • اللغة';

  @override
  String get screenshotSettingsMarketing2 => 'اجعله ملكك حقاً';
}
