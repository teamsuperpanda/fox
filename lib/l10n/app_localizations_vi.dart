// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => 'Fox';

  @override
  String get search => 'Tìm kiếm...';

  @override
  String get noNotesYet => 'Chưa có ghi chú nào...';

  @override
  String get noNotesMatchSearch =>
      'Không có ghi chú nào phù hợp với tìm kiếm của bạn.';

  @override
  String get folders => 'Thư mục';

  @override
  String get viewOptions => 'Tùy chọn hiển thị';

  @override
  String get toggleTheme => 'Đổi giao diện';

  @override
  String get clearFolderFilter => 'Xóa bộ lọc thư mục';

  @override
  String get unfiled => 'Chưa phân loại';

  @override
  String get unknown => 'Không xác định';

  @override
  String get allNotes => 'Tất cả ghi chú';

  @override
  String get newFolderName => 'Tên thư mục mới...';

  @override
  String get renameFolder => 'Đổi tên thư mục';

  @override
  String get folderName => 'Tên thư mục';

  @override
  String get deleteFolder => 'Xóa thư mục?';

  @override
  String get deleteFolderMessage =>
      'Các ghi chú trong thư mục này sẽ không bị xóa, chúng sẽ trở thành chưa phân loại.';

  @override
  String get rename => 'Đổi tên';

  @override
  String get delete => 'Xóa';

  @override
  String get cancel => 'Hủy';

  @override
  String get close => 'Đóng';

  @override
  String get deleteNote => 'Xóa ghi chú?';

  @override
  String get deleteNoteMessage => 'Bạn có chắc muốn xóa ghi chú này không?';

  @override
  String get noteDeleted => 'Đã xóa ghi chú';

  @override
  String get undo => 'Hoàn tác';

  @override
  String get noteTitle => 'Tiêu đề ghi chú...';

  @override
  String get back => 'Quay lại';

  @override
  String get folder => 'Thư mục';

  @override
  String get tags => 'Thẻ';

  @override
  String get noteColour => 'Màu ghi chú';

  @override
  String get hideFormattingToolbar => 'Ẩn thanh định dạng';

  @override
  String get showFormattingToolbar => 'Hiện thanh định dạng';

  @override
  String get unpin => 'Bỏ ghim';

  @override
  String get pin => 'Ghim';

  @override
  String get startTyping => 'Bắt đầu nhập...';

  @override
  String get manageTags => 'Quản lý thẻ';

  @override
  String get newTag => 'Thẻ mới...';

  @override
  String get moveToFolder => 'Chuyển đến thư mục';

  @override
  String get noFolder => 'Không có thư mục';

  @override
  String get noteCannotBeEmpty => 'Ghi chú không được để trống';

  @override
  String get savingTitleOnly => 'Lưu ghi chú chỉ có tiêu đề';

  @override
  String errorSavingNote(String error) {
    return 'Lỗi khi lưu: $error';
  }

  @override
  String errorDeletingNote(String error) {
    return 'Lỗi khi xóa: $error';
  }

  @override
  String get sortBy => 'Sắp xếp theo';

  @override
  String get dateNewestFirst => 'Ngày (mới nhất)';

  @override
  String get dateOldestFirst => 'Ngày (cũ nhất)';

  @override
  String get titleAZ => 'Tiêu đề (A-Z)';

  @override
  String get titleZA => 'Tiêu đề (Z-A)';

  @override
  String get showTags => 'Hiện thẻ';

  @override
  String get showNotePreviews => 'Hiện xem trước';

  @override
  String get alternatingRowColors => 'Màu hàng xen kẽ';

  @override
  String get animateAddButton => 'Hiệu ứng nút thêm';

  @override
  String get untitled => '(Chưa đặt tên)';

  @override
  String get today => 'Hôm nay';

  @override
  String get language => 'Ngôn ngữ';

  @override
  String get accentColor => 'Màu nhấn';

  @override
  String get systemDefault => 'Mặc định hệ thống';

  @override
  String startupError(String error) {
    return 'Đã xảy ra lỗi khi khởi động Fox.\n\nHãy thử xóa dữ liệu ứng dụng hoặc cài đặt lại.\n\nLỗi: $error';
  }
}
