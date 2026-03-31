// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'Fox';

  @override
  String get search => 'खोजें...';

  @override
  String get noNotesYet => 'अभी तक कोई नोट नहीं...';

  @override
  String get noNotesMatchSearch => 'आपकी खोज से मेल खाने वाला कोई नोट नहीं।';

  @override
  String get folders => 'फ़ोल्डर';

  @override
  String get viewOptions => 'दृश्य विकल्प';

  @override
  String get toggleTheme => 'थीम बदलें';

  @override
  String get clearFolderFilter => 'फ़ोल्डर फ़िल्टर हटाएं';

  @override
  String get unfiled => 'अवर्गीकृत';

  @override
  String get unknown => 'अज्ञात';

  @override
  String get allNotes => 'सभी नोट्स';

  @override
  String get newFolderName => 'नया फ़ोल्डर नाम...';

  @override
  String get renameFolder => 'फ़ोल्डर का नाम बदलें';

  @override
  String get folderName => 'फ़ोल्डर का नाम';

  @override
  String get deleteFolder => 'फ़ोल्डर हटाएं?';

  @override
  String get deleteFolderMessage =>
      'इस फ़ोल्डर के नोट्स हटाए नहीं जाएंगे, वे अवर्गीकृत हो जाएंगे।';

  @override
  String get rename => 'नाम बदलें';

  @override
  String get delete => 'हटाएं';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get close => 'बंद करें';

  @override
  String get deleteNote => 'नोट हटाएं?';

  @override
  String get deleteNoteMessage => 'क्या आप वाकई इस नोट को हटाना चाहते हैं?';

  @override
  String get noteDeleted => 'नोट हटाया गया';

  @override
  String get undo => 'पूर्ववत करें';

  @override
  String get noteTitle => 'नोट शीर्षक...';

  @override
  String get back => 'वापस';

  @override
  String get folder => 'फ़ोल्डर';

  @override
  String get tags => 'टैग';

  @override
  String get noteColour => 'नोट का रंग';

  @override
  String get hideFormattingToolbar => 'फ़ॉर्मेटिंग टूलबार छुपाएं';

  @override
  String get showFormattingToolbar => 'फ़ॉर्मेटिंग टूलबार दिखाएं';

  @override
  String get unpin => 'अनपिन करें';

  @override
  String get pin => 'पिन करें';

  @override
  String get startTyping => 'लिखना शुरू करें...';

  @override
  String get manageTags => 'टैग प्रबंधित करें';

  @override
  String get newTag => 'नया टैग...';

  @override
  String get moveToFolder => 'फ़ोल्डर में ले जाएं';

  @override
  String get noFolder => 'कोई फ़ोल्डर नहीं';

  @override
  String get noteCannotBeEmpty => 'नोट खाली नहीं हो सकता';

  @override
  String get savingTitleOnly => 'केवल शीर्षक वाला नोट सहेजा जा रहा है';

  @override
  String errorSavingNote(String error) {
    return 'सहेजने में त्रुटि: $error';
  }

  @override
  String errorDeletingNote(String error) {
    return 'हटाने में त्रुटि: $error';
  }

  @override
  String get sortBy => 'इसके अनुसार क्रमबद्ध करें';

  @override
  String get dateNewestFirst => 'तिथि (नवीनतम पहले)';

  @override
  String get dateOldestFirst => 'तिथि (पुराना पहले)';

  @override
  String get titleAZ => 'शीर्षक (अ-ह)';

  @override
  String get titleZA => 'शीर्षक (ह-अ)';

  @override
  String get showTags => 'टैग दिखाएं';

  @override
  String get showNotePreviews => 'पूर्वावलोकन दिखाएं';

  @override
  String get alternatingRowColors => 'वैकल्पिक पंक्ति रंग';

  @override
  String get animateAddButton => 'जोड़ें बटन एनिमेट करें';

  @override
  String get untitled => '(शीर्षकहीन)';

  @override
  String get today => 'आज';

  @override
  String get language => 'भाषा';

  @override
  String get accentColor => 'एक्सेंट रंग';

  @override
  String get systemDefault => 'सिस्टम डिफ़ॉल्ट';

  @override
  String startupError(String error) {
    return 'Fox शुरू करते समय कुछ गलत हो गया।\n\nऐप डेटा साफ़ करने या पुनः इंस्टॉल करने का प्रयास करें।\n\nत्रुटि: $error';
  }
}
