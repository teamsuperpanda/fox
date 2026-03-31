import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fox/widgets/empty_state.dart';

import 'test_helpers.dart';

void main() {
  group('EmptyState Widget', () {
    testWidgets('displays "No notes yet..." message by default', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          home: const Scaffold(
            body: EmptyState(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No notes yet...'), findsOneWidget);
    });

    testWidgets('displays search message when isSearching is true', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          home: const Scaffold(
            body: EmptyState(isSearching: true),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No notes match your search.'), findsOneWidget);
      expect(find.text('No notes yet...'), findsNothing);
    });

    testWidgets('centers content on screen', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          home: const Scaffold(
            body: EmptyState(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final centerFinder = find.byType(Center);
      expect(centerFinder, findsOneWidget);
    });

    testWidgets('uses theme text style', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          theme: ThemeData(
            textTheme: const TextTheme(
              titleMedium: TextStyle(fontSize: 20),
            ),
          ),
          home: const Scaffold(
            body: EmptyState(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final textWidget = tester.widget<Text>(find.text('No notes yet...'));
      expect(textWidget.style?.fontSize, equals(20));
    });
  });
}
