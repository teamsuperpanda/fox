// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Fox';

  @override
  String get search => 'Ara...';

  @override
  String get noNotesYet => 'Henüz not yok...';

  @override
  String get noNotesMatchSearch => 'Aramanızla eşleşen not yok.';

  @override
  String get folders => 'Klasörler';

  @override
  String get viewOptions => 'Görünüm seçenekleri';

  @override
  String get toggleTheme => 'Temayı değiştir';

  @override
  String get clearFolderFilter => 'Klasör filtresini temizle';

  @override
  String get unfiled => 'Dosyalanmamış';

  @override
  String get unknown => 'Bilinmeyen';

  @override
  String get allNotes => 'Tüm notlar';

  @override
  String get newFolderName => 'Yeni klasör adı...';

  @override
  String get renameFolder => 'Klasörü yeniden adlandır';

  @override
  String get folderName => 'Klasör adı';

  @override
  String get deleteFolder => 'Klasör silinsin mi?';

  @override
  String get deleteFolderMessage =>
      'Bu klasördeki notlar silinmeyecek, dosyalanmamış olacak.';

  @override
  String get rename => 'Yeniden Adlandır';

  @override
  String get delete => 'Sil';

  @override
  String get cancel => 'İptal';

  @override
  String get close => 'Kapat';

  @override
  String get deleteNote => 'Not silinsin mi?';

  @override
  String get deleteNoteMessage => 'Bu notu silmek istediğinizden emin misiniz?';

  @override
  String get noteDeleted => 'Not silindi';

  @override
  String get undo => 'Geri Al';

  @override
  String get noteTitle => 'Not başlığı...';

  @override
  String get back => 'Geri';

  @override
  String get folder => 'Klasör';

  @override
  String get tags => 'Etiketler';

  @override
  String get noteColour => 'Not rengi';

  @override
  String get hideFormattingToolbar => 'Biçimlendirme araç çubuğunu gizle';

  @override
  String get showFormattingToolbar => 'Biçimlendirme araç çubuğunu göster';

  @override
  String get unpin => 'Sabitlemeyi kaldır';

  @override
  String get pin => 'Sabitle';

  @override
  String get startTyping => 'Yazmaya başlayın...';

  @override
  String get manageTags => 'Etiketleri yönet';

  @override
  String get newTag => 'Yeni etiket...';

  @override
  String get moveToFolder => 'Klasöre taşı';

  @override
  String get noFolder => 'Klasör yok';

  @override
  String get noteCannotBeEmpty => 'Not boş olamaz';

  @override
  String get savingTitleOnly => 'Yalnızca başlıklı not kaydediliyor';

  @override
  String errorSavingNote(String error) {
    return 'Kaydetme hatası: $error';
  }

  @override
  String errorDeletingNote(String error) {
    return 'Silme hatası: $error';
  }

  @override
  String get sortBy => 'Sıralama';

  @override
  String get dateNewestFirst => 'Tarih (en yeni)';

  @override
  String get dateOldestFirst => 'Tarih (en eski)';

  @override
  String get titleAZ => 'Başlık (A-Z)';

  @override
  String get titleZA => 'Başlık (Z-A)';

  @override
  String get showTags => 'Etiketleri göster';

  @override
  String get showNotePreviews => 'Önizlemeleri göster';

  @override
  String get alternatingRowColors => 'Alternatif satır renkleri';

  @override
  String get animateAddButton => 'Ekleme düğmesini canlandır';

  @override
  String get untitled => '(Başlıksız)';

  @override
  String get today => 'Bugün';

  @override
  String get language => 'Dil';

  @override
  String get accentColor => 'Vurgu Rengi';

  @override
  String get systemDefault => 'Sistem varsayılanı';

  @override
  String startupError(String error) {
    return 'Fox başlatılırken bir sorun oluştu.\n\nUygulama verilerini temizlemeyi veya yeniden yüklemeyi deneyin.\n\nHata: $error';
  }
}
