// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Malay (`ms`).
class AppLocalizationsMs extends AppLocalizations {
  AppLocalizationsMs([String locale = 'ms']) : super(locale);

  @override
  String get appTitle => 'Fox';

  @override
  String get search => 'Cari...';

  @override
  String get noNotesYet => 'Tiada nota lagi...';

  @override
  String get noNotesMatchSearch => 'Tiada nota sepadan dengan carian anda.';

  @override
  String get folders => 'Folder';

  @override
  String get viewOptions => 'Pilihan Paparan';

  @override
  String get toggleTheme => 'Tukar Tema';

  @override
  String get clearFolderFilter => 'Kosongkan penapis folder';

  @override
  String get unfiled => 'Tiada folder';

  @override
  String get unknown => 'Tidak diketahui';

  @override
  String get allNotes => 'Semua Nota';

  @override
  String get newFolderName => 'Nama folder baharu...';

  @override
  String get renameFolder => 'Namakan semula folder';

  @override
  String get folderName => 'Nama folder';

  @override
  String get deleteFolder => 'Padam folder?';

  @override
  String get deleteFolderMessage =>
      'Nota dalam folder ini tidak akan dipadam, ia akan difailkan tanpa folder.';

  @override
  String get rename => 'Namakan semula';

  @override
  String get delete => 'Padam';

  @override
  String get cancel => 'Batal';

  @override
  String get close => 'Tutup';

  @override
  String get deleteNote => 'Padam nota?';

  @override
  String get deleteNoteMessage => 'Adakah anda pasti mahu memadamkan nota ini?';

  @override
  String get noteDeleted => 'Nota dipadam';

  @override
  String get undo => 'Buat asal';

  @override
  String get noteTitle => 'Tajuk nota...';

  @override
  String get back => 'Kembali';

  @override
  String get folder => 'Folder';

  @override
  String get tags => 'Tag';

  @override
  String get noteColour => 'Warna Nota';

  @override
  String get hideFormattingToolbar => 'Sembunyikan bar alat pemformatan';

  @override
  String get showFormattingToolbar => 'Tunjukkan bar alat pemformatan';

  @override
  String get unpin => 'Nyahsemat';

  @override
  String get pin => 'Semat';

  @override
  String get startTyping => 'Mula menaip...';

  @override
  String get manageTags => 'Urus tag';

  @override
  String get newTag => 'Tag baharu...';

  @override
  String get moveToFolder => 'Pindah ke folder';

  @override
  String get noFolder => 'Tiada folder';

  @override
  String get noteCannotBeEmpty => 'Nota tidak boleh kosong';

  @override
  String get savingTitleOnly => 'Menyimpan nota dengan tajuk sahaja';

  @override
  String errorSavingNote(String error) {
    return 'Ralat semasa menyimpan: $error';
  }

  @override
  String errorDeletingNote(String error) {
    return 'Ralat semasa memadam: $error';
  }

  @override
  String get sortBy => 'Isih mengikut';

  @override
  String get dateNewestFirst => 'Tarikh (terbaharu dahulu)';

  @override
  String get dateOldestFirst => 'Tarikh (terlama dahulu)';

  @override
  String get titleAZ => 'Tajuk (A-Z)';

  @override
  String get titleZA => 'Tajuk (Z-A)';

  @override
  String get showTags => 'Tunjukkan tag';

  @override
  String get showNotePreviews => 'Tunjukkan pratonton';

  @override
  String get alternatingRowColors => 'Warna baris berselang';

  @override
  String get animateAddButton => 'Animasikan butang tambah';

  @override
  String get untitled => '(Tanpa tajuk)';

  @override
  String get today => 'Hari ini';

  @override
  String get language => 'Bahasa';

  @override
  String get accentColor => 'Warna Aksen';

  @override
  String get systemDefault => 'Lalai sistem';

  @override
  String startupError(String error) {
    return 'Ralat berlaku semasa memulakan Fox.\n\nSila cuba kosongkan data apl atau pasang semula.\n\nRalat: $error';
  }
}
