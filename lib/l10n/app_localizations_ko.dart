// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => 'Fox';

  @override
  String get search => '검색...';

  @override
  String get noNotesYet => '아직 노트가 없습니다...';

  @override
  String get noNotesMatchSearch => '검색과 일치하는 노트가 없습니다.';

  @override
  String get folders => '폴더';

  @override
  String get viewOptions => '보기 옵션';

  @override
  String get toggleTheme => '테마 전환';

  @override
  String get clearFolderFilter => '폴더 필터 해제';

  @override
  String get unfiled => '미분류';

  @override
  String get unknown => '알 수 없음';

  @override
  String get allNotes => '모든 노트';

  @override
  String get newFolderName => '새 폴더 이름...';

  @override
  String get renameFolder => '폴더 이름 변경';

  @override
  String get folderName => '폴더 이름';

  @override
  String get deleteFolder => '폴더를 삭제하시겠습니까?';

  @override
  String get deleteFolderMessage => '이 폴더의 노트는 삭제되지 않고 미분류 상태가 됩니다.';

  @override
  String get rename => '이름 변경';

  @override
  String get delete => '삭제';

  @override
  String get cancel => '취소';

  @override
  String get close => '닫기';

  @override
  String get deleteNote => '노트를 삭제하시겠습니까?';

  @override
  String get deleteNoteMessage => '이 노트를 정말 삭제하시겠습니까?';

  @override
  String get noteDeleted => '노트가 삭제되었습니다';

  @override
  String get undo => '실행 취소';

  @override
  String get noteTitle => '노트 제목...';

  @override
  String get back => '뒤로';

  @override
  String get folder => '폴더';

  @override
  String get tags => '태그';

  @override
  String get noteColour => '노트 색상';

  @override
  String get hideFormattingToolbar => '서식 도구 모음 숨기기';

  @override
  String get showFormattingToolbar => '서식 도구 모음 표시';

  @override
  String get unpin => '고정 해제';

  @override
  String get pin => '고정';

  @override
  String get startTyping => '입력 시작...';

  @override
  String get manageTags => '태그 관리';

  @override
  String get newTag => '새 태그...';

  @override
  String get moveToFolder => '폴더로 이동';

  @override
  String get noFolder => '폴더 없음';

  @override
  String get noteCannotBeEmpty => '노트는 비어 있을 수 없습니다';

  @override
  String get savingTitleOnly => '제목만으로 노트 저장';

  @override
  String errorSavingNote(String error) {
    return '저장 오류: $error';
  }

  @override
  String errorDeletingNote(String error) {
    return '삭제 오류: $error';
  }

  @override
  String get sortBy => '정렬 기준';

  @override
  String get dateNewestFirst => '날짜 (최신순)';

  @override
  String get dateOldestFirst => '날짜 (오래된순)';

  @override
  String get titleAZ => '제목 (가-하)';

  @override
  String get titleZA => '제목 (하-가)';

  @override
  String get showTags => '태그 표시';

  @override
  String get showNotePreviews => '미리보기 표시';

  @override
  String get alternatingRowColors => '행 색상 교대';

  @override
  String get animateAddButton => '추가 버튼 애니메이션';

  @override
  String get untitled => '(제목 없음)';

  @override
  String get today => '오늘';

  @override
  String get language => '언어';

  @override
  String get accentColor => '강조 색상';

  @override
  String get systemDefault => '시스템 기본값';

  @override
  String startupError(String error) {
    return 'Fox 시작 중 문제가 발생했습니다.\n\n앱 데이터를 지우거나 다시 설치해 보세요.\n\n오류: $error';
  }
}
