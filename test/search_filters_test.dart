import 'package:flutter_test/flutter_test.dart';
import 'package:fox/models/search_filters.dart';

void main() {
  group('SearchFilters', () {
    test('is inactive when empty', () {
      expect(const SearchFilters().isActive, isFalse);
    });

    test('is active with any single filter', () {
      expect(const SearchFilters(pinnedOnly: true).isActive, isTrue);
      expect(const SearchFilters(tag: 'work').isActive, isTrue);
      expect(const SearchFilters(color: '#FF5252').isActive, isTrue);
      expect(
        SearchFilters(from: DateTime(2025)).isActive,
        isTrue,
      );
      expect(SearchFilters(to: DateTime(2025)).isActive, isTrue);
    });

    test('copyWith clears individual filters', () {
      final base = SearchFilters(
        tag: 'work',
        pinnedOnly: true,
        color: '#FF5252',
        from: DateTime(2025),
        to: DateTime(2026),
      );

      expect(base.copyWith(clearTag: true).tag, isNull);
      expect(base.copyWith(clearTag: true).pinnedOnly, isTrue);
      expect(base.copyWith(clearColor: true).color, isNull);
      final cleared = base.copyWith(clearDates: true);
      expect(cleared.from, isNull);
      expect(cleared.to, isNull);
      expect(cleared.tag, 'work');
    });

    test('copyWith sets values', () {
      final updated = const SearchFilters()
          .copyWith(tag: 'travel', pinnedOnly: true, color: '#66BB6A');
      expect(updated.tag, 'travel');
      expect(updated.pinnedOnly, isTrue);
      expect(updated.color, '#66BB6A');
    });

    test('equality compares every field', () {
      expect(
        const SearchFilters(tag: 'work', pinnedOnly: true),
        const SearchFilters(tag: 'work', pinnedOnly: true),
      );
      expect(
        const SearchFilters(tag: 'work'),
        isNot(const SearchFilters(tag: 'home')),
      );
    });
  });
}
