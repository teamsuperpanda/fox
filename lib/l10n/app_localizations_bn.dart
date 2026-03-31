// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String get appTitle => 'Fox';

  @override
  String get search => 'অনুসন্ধান...';

  @override
  String get noNotesYet => 'এখনো কোনো নোট নেই...';

  @override
  String get noNotesMatchSearch => 'আপনার অনুসন্ধানের সাথে কোনো নোট মেলেনি।';

  @override
  String get folders => 'ফোল্ডার';

  @override
  String get viewOptions => 'দর্শন বিকল্প';

  @override
  String get toggleTheme => 'থিম পরিবর্তন';

  @override
  String get clearFolderFilter => 'ফোল্ডার ফিল্টার মুছুন';

  @override
  String get unfiled => 'ফোল্ডারবিহীন';

  @override
  String get unknown => 'অজানা';

  @override
  String get allNotes => 'সমস্ত নোট';

  @override
  String get newFolderName => 'নতুন ফোল্ডারের নাম...';

  @override
  String get renameFolder => 'ফোল্ডার পুনঃনামকরণ';

  @override
  String get folderName => 'ফোল্ডারের নাম';

  @override
  String get deleteFolder => 'ফোল্ডার মুছবেন?';

  @override
  String get deleteFolderMessage =>
      'এই ফোল্ডারের নোটগুলো মুছে যাবে না, সেগুলো ফোল্ডারবিহীন হিসেবে সংরক্ষিত থাকবে।';

  @override
  String get rename => 'পুনঃনামকরণ';

  @override
  String get delete => 'মুছুন';

  @override
  String get cancel => 'বাতিল';

  @override
  String get close => 'বন্ধ';

  @override
  String get deleteNote => 'নোট মুছবেন?';

  @override
  String get deleteNoteMessage => 'আপনি কি নিশ্চিত যে এই নোটটি মুছতে চান?';

  @override
  String get noteDeleted => 'নোট মুছে ফেলা হয়েছে';

  @override
  String get undo => 'পূর্বাবস্থায় ফেরান';

  @override
  String get noteTitle => 'নোটের শিরোনাম...';

  @override
  String get back => 'পেছনে';

  @override
  String get folder => 'ফোল্ডার';

  @override
  String get tags => 'ট্যাগ';

  @override
  String get noteColour => 'নোটের রঙ';

  @override
  String get hideFormattingToolbar => 'ফরম্যাটিং টুলবার লুকান';

  @override
  String get showFormattingToolbar => 'ফরম্যাটিং টুলবার দেখান';

  @override
  String get unpin => 'আনপিন';

  @override
  String get pin => 'পিন';

  @override
  String get startTyping => 'লেখা শুরু করুন...';

  @override
  String get manageTags => 'ট্যাগ পরিচালনা';

  @override
  String get newTag => 'নতুন ট্যাগ...';

  @override
  String get moveToFolder => 'ফোল্ডারে সরান';

  @override
  String get noFolder => 'কোনো ফোল্ডার নেই';

  @override
  String get noteCannotBeEmpty => 'নোট খালি থাকতে পারে না';

  @override
  String get savingTitleOnly => 'শুধু শিরোনাম সহ নোট সংরক্ষণ করা হচ্ছে';

  @override
  String errorSavingNote(String error) {
    return 'সংরক্ষণে ত্রুটি: $error';
  }

  @override
  String errorDeletingNote(String error) {
    return 'মুছতে ত্রুটি: $error';
  }

  @override
  String get sortBy => 'সাজানোর ক্রম';

  @override
  String get dateNewestFirst => 'তারিখ (নতুন আগে)';

  @override
  String get dateOldestFirst => 'তারিখ (পুরানো আগে)';

  @override
  String get titleAZ => 'শিরোনাম (অ-য)';

  @override
  String get titleZA => 'শিরোনাম (য-অ)';

  @override
  String get showTags => 'ট্যাগ দেখান';

  @override
  String get showNotePreviews => 'প্রিভিউ দেখান';

  @override
  String get alternatingRowColors => 'বিকল্প সারির রঙ';

  @override
  String get animateAddButton => 'যোগ বোতাম অ্যানিমেট করুন';

  @override
  String get untitled => '(শিরোনামহীন)';

  @override
  String get today => 'আজ';

  @override
  String get language => 'ভাষা';

  @override
  String get accentColor => 'অ্যাকসেন্ট রঙ';

  @override
  String get systemDefault => 'সিস্টেম ডিফল্ট';

  @override
  String startupError(String error) {
    return 'Fox শুরু করতে সমস্যা হয়েছে।\n\nঅনুগ্রহ করে অ্যাপ ডেটা মুছে আবার চেষ্টা করুন বা পুনরায় ইনস্টল করুন।\n\nত্রুটি: $error';
  }
}
