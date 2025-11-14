import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fox/widgets/empty_state.dart';

void main() {
  group('EmptyState Widget', () {
    testWidgets('displays "No notes yet..." message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(),
          ),
        ),
      );

      expect(find.text('No notes yet...'), findsOneWidget);
    });

    testWidgets('centers content on screen', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(),
          ),
        ),
      );

      final centerFinder = find.byType(Center);
      expect(centerFinder, findsOneWidget);
    });

    testWidgets('uses theme text style', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
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

      final textWidget = tester.widget<Text>(find.text('No notes yet...'));
      expect(textWidget.style?.fontSize, equals(20));
    });
  });
}
