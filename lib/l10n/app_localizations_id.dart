// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appTitle => 'Fox';

  @override
  String get search => 'Cari...';

  @override
  String get noNotesYet => 'Belum ada catatan...';

  @override
  String get noNotesMatchSearch =>
      'Tidak ada catatan yang cocok dengan pencarian Anda.';

  @override
  String get folders => 'Folder';

  @override
  String get viewOptions => 'Opsi tampilan';

  @override
  String get toggleTheme => 'Ganti tema';

  @override
  String get clearFolderFilter => 'Hapus filter folder';

  @override
  String get unfiled => 'Tidak dikategorikan';

  @override
  String get unknown => 'Tidak diketahui';

  @override
  String get allNotes => 'Semua catatan';

  @override
  String get newFolderName => 'Nama folder baru...';

  @override
  String get renameFolder => 'Ubah nama folder';

  @override
  String get folderName => 'Nama folder';

  @override
  String get deleteFolder => 'Hapus folder?';

  @override
  String get deleteFolderMessage =>
      'Catatan di folder ini tidak akan dihapus, akan menjadi tidak dikategorikan.';

  @override
  String get rename => 'Ubah Nama';

  @override
  String get delete => 'Hapus';

  @override
  String get cancel => 'Batal';

  @override
  String get close => 'Tutup';

  @override
  String get deleteNote => 'Hapus catatan?';

  @override
  String get deleteNoteMessage =>
      'Apakah Anda yakin ingin menghapus catatan ini?';

  @override
  String get noteDeleted => 'Catatan dihapus';

  @override
  String get undo => 'Urungkan';

  @override
  String get noteTitle => 'Judul catatan...';

  @override
  String get back => 'Kembali';

  @override
  String get folder => 'Folder';

  @override
  String get tags => 'Tag';

  @override
  String get noteColour => 'Warna catatan';

  @override
  String get hideFormattingToolbar => 'Sembunyikan bilah pemformatan';

  @override
  String get showFormattingToolbar => 'Tampilkan bilah pemformatan';

  @override
  String get unpin => 'Lepas pin';

  @override
  String get pin => 'Sematkan';

  @override
  String get startTyping => 'Mulai mengetik...';

  @override
  String get manageTags => 'Kelola tag';

  @override
  String get newTag => 'Tag baru...';

  @override
  String get moveToFolder => 'Pindahkan ke folder';

  @override
  String get noFolder => 'Tanpa folder';

  @override
  String get noteCannotBeEmpty => 'Catatan tidak boleh kosong';

  @override
  String get savingTitleOnly => 'Menyimpan catatan dengan judul saja';

  @override
  String errorSavingNote(String error) {
    return 'Kesalahan menyimpan: $error';
  }

  @override
  String errorDeletingNote(String error) {
    return 'Kesalahan menghapus: $error';
  }

  @override
  String get sortBy => 'Urutkan berdasarkan';

  @override
  String get dateNewestFirst => 'Tanggal (terbaru)';

  @override
  String get dateOldestFirst => 'Tanggal (terlama)';

  @override
  String get titleAZ => 'Judul (A-Z)';

  @override
  String get titleZA => 'Judul (Z-A)';

  @override
  String get showTags => 'Tampilkan tag';

  @override
  String get showNotePreviews => 'Tampilkan pratinjau';

  @override
  String get alternatingRowColors => 'Warna baris bergantian';

  @override
  String get animateAddButton => 'Animasi tombol tambah';

  @override
  String get untitled => '(Tanpa judul)';

  @override
  String get today => 'Hari ini';

  @override
  String get language => 'Bahasa';

  @override
  String get accentColor => 'Warna Aksen';

  @override
  String get systemDefault => 'Default sistem';

  @override
  String startupError(String error) {
    return 'Terjadi kesalahan saat memulai Fox.\n\nCoba hapus data aplikasi atau instal ulang.\n\nKesalahan: $error';
  }
}
