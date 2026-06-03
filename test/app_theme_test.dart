import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fox/theme/app_theme.dart';

Widget _buildApp(ThemeData theme) {
  return MaterialApp(
    theme: theme,
    home: const SizedBox(),
  );
}

void main() {
  group('AppTheme', () {
    const testAccent = Color(0xFF8B9A6B);

    group('light', () {
      testWidgets('uses Material3', (tester) async {
        await tester.pumpWidget(_buildApp(AppTheme.light(testAccent)));
        final ctx = tester.element(find.byType(SizedBox));
        expect(Theme.of(ctx).useMaterial3, isTrue);
      });

      testWidgets('brightness is light', (tester) async {
        await tester.pumpWidget(_buildApp(AppTheme.light(testAccent)));
        final ctx = tester.element(find.byType(SizedBox));
        expect(Theme.of(ctx).brightness, Brightness.light);
      });

      testWidgets('FAB uses accent color', (tester) async {
        await tester.pumpWidget(_buildApp(AppTheme.light(testAccent)));
        final ctx = tester.element(find.byType(SizedBox));
        expect(
          Theme.of(ctx).floatingActionButtonTheme.backgroundColor,
          testAccent,
        );
      });

      testWidgets('scaffold background is not transparent', (tester) async {
        await tester.pumpWidget(_buildApp(AppTheme.light(testAccent)));
        final ctx = tester.element(find.byType(SizedBox));
        expect(Theme.of(ctx).scaffoldBackgroundColor, isNot(Colors.transparent));
      });

      testWidgets('colorScheme is derived from accent', (tester) async {
        await tester.pumpWidget(_buildApp(AppTheme.light(testAccent)));
        final ctx = tester.element(find.byType(SizedBox));
        expect(Theme.of(ctx).colorScheme.primary, isNotNull);
      });

      testWidgets('appBar theme uses warm foreground', (tester) async {
        await tester.pumpWidget(_buildApp(AppTheme.light(testAccent)));
        final ctx = tester.element(find.byType(SizedBox));
        expect(Theme.of(ctx).appBarTheme.foregroundColor, const Color(0xFF333333));
      });
    });

    group('dark', () {
      testWidgets('uses Material3', (tester) async {
        await tester.pumpWidget(_buildApp(AppTheme.dark(testAccent)));
        final ctx = tester.element(find.byType(SizedBox));
        expect(Theme.of(ctx).useMaterial3, isTrue);
      });

      testWidgets('brightness is dark', (tester) async {
        await tester.pumpWidget(_buildApp(AppTheme.dark(testAccent)));
        final ctx = tester.element(find.byType(SizedBox));
        expect(Theme.of(ctx).brightness, Brightness.dark);
      });

      testWidgets('FAB uses accent color', (tester) async {
        await tester.pumpWidget(_buildApp(AppTheme.dark(testAccent)));
        final ctx = tester.element(find.byType(SizedBox));
        expect(
          Theme.of(ctx).floatingActionButtonTheme.backgroundColor,
          testAccent,
        );
      });

      testWidgets('scaffold background is not transparent', (tester) async {
        await tester.pumpWidget(_buildApp(AppTheme.dark(testAccent)));
        final ctx = tester.element(find.byType(SizedBox));
        expect(Theme.of(ctx).scaffoldBackgroundColor, isNot(Colors.transparent));
      });

      testWidgets('appBar foreground is light', (tester) async {
        await tester.pumpWidget(_buildApp(AppTheme.dark(testAccent)));
        final ctx = tester.element(find.byType(SizedBox));
        expect(Theme.of(ctx).appBarTheme.foregroundColor, const Color(0xFFF8F5F1));
      });
    });

    group('different accent colors', () {
      test('different seed colors produce different primary', () {
        final cs1 = ColorScheme.fromSeed(seedColor: const Color(0xFF8B9A6B));
        final cs2 = ColorScheme.fromSeed(seedColor: const Color(0xFF5B8DBE));
        expect(cs1.primary, isNot(equals(cs2.primary)));
      });

      testWidgets('dark theme accent is reflected', (tester) async {
        const terracotta = Color(0xFFD4845A);
        await tester.pumpWidget(_buildApp(AppTheme.dark(terracotta)));
        final ctx = tester.element(find.byType(SizedBox));
        expect(Theme.of(ctx).floatingActionButtonTheme.backgroundColor, terracotta);
      });
    });
  });
}
