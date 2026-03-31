// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Thai (`th`).
class AppLocalizationsTh extends AppLocalizations {
  AppLocalizationsTh([String locale = 'th']) : super(locale);

  @override
  String get appTitle => 'Fox';

  @override
  String get search => 'ค้นหา...';

  @override
  String get noNotesYet => 'ยังไม่มีบันทึก...';

  @override
  String get noNotesMatchSearch => 'ไม่มีบันทึกที่ตรงกับการค้นหา';

  @override
  String get folders => 'โฟลเดอร์';

  @override
  String get viewOptions => 'ตัวเลือกมุมมอง';

  @override
  String get toggleTheme => 'สลับธีม';

  @override
  String get clearFolderFilter => 'ล้างตัวกรองโฟลเดอร์';

  @override
  String get unfiled => 'ไม่อยู่ในโฟลเดอร์';

  @override
  String get unknown => 'ไม่ทราบ';

  @override
  String get allNotes => 'บันทึกทั้งหมด';

  @override
  String get newFolderName => 'ชื่อโฟลเดอร์ใหม่...';

  @override
  String get renameFolder => 'เปลี่ยนชื่อโฟลเดอร์';

  @override
  String get folderName => 'ชื่อโฟลเดอร์';

  @override
  String get deleteFolder => 'ลบโฟลเดอร์?';

  @override
  String get deleteFolderMessage =>
      'บันทึกในโฟลเดอร์นี้จะไม่ถูกลบ แต่จะถูกยกเลิกการจัดหมวดหมู่';

  @override
  String get rename => 'เปลี่ยนชื่อ';

  @override
  String get delete => 'ลบ';

  @override
  String get cancel => 'ยกเลิก';

  @override
  String get close => 'ปิด';

  @override
  String get deleteNote => 'ลบบันทึก?';

  @override
  String get deleteNoteMessage => 'คุณแน่ใจหรือไม่ว่าต้องการลบบันทึกนี้?';

  @override
  String get noteDeleted => 'ลบบันทึกแล้ว';

  @override
  String get undo => 'เลิกทำ';

  @override
  String get noteTitle => 'ชื่อบันทึก...';

  @override
  String get back => 'กลับ';

  @override
  String get folder => 'โฟลเดอร์';

  @override
  String get tags => 'แท็ก';

  @override
  String get noteColour => 'สีบันทึก';

  @override
  String get hideFormattingToolbar => 'ซ่อนแถบจัดรูปแบบ';

  @override
  String get showFormattingToolbar => 'แสดงแถบจัดรูปแบบ';

  @override
  String get unpin => 'เลิกปักหมุด';

  @override
  String get pin => 'ปักหมุด';

  @override
  String get startTyping => 'เริ่มพิมพ์...';

  @override
  String get manageTags => 'จัดการแท็ก';

  @override
  String get newTag => 'แท็กใหม่...';

  @override
  String get moveToFolder => 'ย้ายไปยังโฟลเดอร์';

  @override
  String get noFolder => 'ไม่มีโฟลเดอร์';

  @override
  String get noteCannotBeEmpty => 'บันทึกต้องไม่ว่างเปล่า';

  @override
  String get savingTitleOnly => 'บันทึกเฉพาะชื่อเรื่อง';

  @override
  String errorSavingNote(String error) {
    return 'เกิดข้อผิดพลาดในการบันทึก: $error';
  }

  @override
  String errorDeletingNote(String error) {
    return 'เกิดข้อผิดพลาดในการลบ: $error';
  }

  @override
  String get sortBy => 'เรียงตาม';

  @override
  String get dateNewestFirst => 'วันที่ (ใหม่สุดก่อน)';

  @override
  String get dateOldestFirst => 'วันที่ (เก่าสุดก่อน)';

  @override
  String get titleAZ => 'ชื่อ (ก-ฮ)';

  @override
  String get titleZA => 'ชื่อ (ฮ-ก)';

  @override
  String get showTags => 'แสดงแท็ก';

  @override
  String get showNotePreviews => 'แสดงตัวอย่างบันทึก';

  @override
  String get alternatingRowColors => 'สีแถวสลับ';

  @override
  String get animateAddButton => 'เคลื่อนไหวปุ่มเพิ่ม';

  @override
  String get untitled => '(ไม่มีชื่อ)';

  @override
  String get today => 'วันนี้';

  @override
  String get language => 'ภาษา';

  @override
  String get accentColor => 'สีเน้น';

  @override
  String get systemDefault => 'ค่าเริ่มต้นระบบ';

  @override
  String startupError(String error) {
    return 'เกิดข้อผิดพลาดในการเริ่มต้น Fox\n\nกรุณาลองล้างข้อมูลแอปหรือติดตั้งใหม่\n\nข้อผิดพลาด: $error';
  }
}
