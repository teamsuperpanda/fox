import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fox/home_page.dart';
import 'package:fox/note_detail_page.dart';
import 'package:fox/services/notes_controller.dart';
import 'package:fox/services/settings_service.dart';

import 'test_helpers.dart';

Widget _buildHome(
    {required NotesController controller, SettingsService? settingsService}) {
  return HomePage(
    controller: controller,
    settingsService: settingsService ?? SettingsService(),
  );
}

/// Rotation applied to the FAB, in radians, read from its [Transform].
double _fabAngle(WidgetTester tester) {
  final transform = tester.widget<Transform>(
    find
        .ancestor(
          of: find.byType(FloatingActionButton),
          matching: find.byType(Transform),
        )
        .first,
  );
  final matrix = transform.transform;
  return math.atan2(matrix.entry(1, 0), matrix.entry(0, 0));
}

void main() {
  group('HomePage', () {
    late MockRepository mockRepo;
    late NotesController controller;

    setUp(() {
      mockRepo = MockRepository();
      controller = NotesController(mockRepo);
    });

    testWidgets('shows empty state when no notes exist', (tester) async {
      await tester.pumpWidget(buildTestApp(_buildHome(controller: controller)));
      await tester.pump();
      expect(find.text('No notes yet...'), findsOneWidget);
    });

    testWidgets('shows note in list when note exists', (tester) async {
      await controller.load();
      await controller.addOrUpdate(title: 'Test Note', content: Document());

      await tester.pumpWidget(buildTestApp(_buildHome(controller: controller)));
      await tester.pump();
      expect(find.text('Test Note'), findsOneWidget);
    });

    testWidgets('FAB opens note detail page', (tester) async {
      await tester.pumpWidget(buildTestApp(_buildHome(controller: controller)));
      await tester.pump();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(NoteDetailPage), findsOneWidget);
    });

    testWidgets('Search icon toggles search bar when notes exist',
        (tester) async {
      await controller.load();
      await controller.addOrUpdate(title: 'Test', content: Document());

      await tester.pumpWidget(buildTestApp(_buildHome(controller: controller)));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.search));
      await tester.pump();

      expect(find.byType(TextField), findsWidgets);
    });

    testWidgets('Folder icon opens folders dialog', (tester) async {
      await tester.pumpWidget(buildTestApp(_buildHome(controller: controller)));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.folder_outlined));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Folders'), findsOneWidget);
    });

    testWidgets('Tune icon is present on home page', (tester) async {
      await tester.pumpWidget(buildTestApp(_buildHome(controller: controller)));
      await tester.pump();

      expect(find.byIcon(Icons.tune), findsOneWidget);
    });

    testWidgets('FAB starts upright when its animation is disabled',
        (tester) async {
      controller.setFabAnimation(false);

      await tester.pumpWidget(buildTestApp(_buildHome(controller: controller)));
      await tester.pump();

      expect(_fabAngle(tester), closeTo(0, 1e-6));

      // It must stay upright while idle as well.
      await tester.pump(const Duration(seconds: 2));
      expect(_fabAngle(tester), closeTo(0, 1e-6));
    });

    testWidgets('FAB animates from upright when its animation is enabled',
        (tester) async {
      expect(controller.fabAnimation, isTrue);

      await tester.pumpWidget(buildTestApp(_buildHome(controller: controller)));
      expect(_fabAngle(tester), closeTo(0, 1e-6));

      // The repeating ticker records its zero point on the following frame.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(_fabAngle(tester).abs(), greaterThan(0.01));
    });
  });
}
