import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fox/about_page.dart';
import 'package:fox/models/note_colors.dart';
import 'package:fox/services/app_info.dart';
import 'package:fox/services/notes_controller.dart';
import 'package:fox/services/settings_service.dart';
import 'package:fox/widgets/view_options_sheet.dart';

import 'test_helpers.dart';

void main() {
  group('AppInfo', () {
    test('version and build match pubspec.yaml', () {
      final pubspec = File('pubspec.yaml').readAsStringSync();
      final match =
          RegExp(r'^version:\s*(\S+)$', multiLine: true).firstMatch(pubspec);
      expect(match, isNotNull, reason: 'pubspec.yaml must declare a version');
      final version = match!.group(1)!.split('+');
      expect(AppInfo.version, version.first);
      expect(AppInfo.buildNumber, version.length > 1 ? version[1] : '0');
    });

    test('repository and licence point at the real project', () {
      expect(AppInfo.repositoryUrl, 'https://github.com/teamsuperpanda/fox');
      expect(AppInfo.licenseName, 'PolyForm Noncommercial 1.0.0');
    });
  });

  group('AboutPage', () {
    testWidgets('shows version, licence, source and privacy', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(buildTestApp(const AboutPage()));
      await tester.pump();

      expect(find.text('Fox'), findsOneWidget);
      expect(
        find.text('Version ${AppInfo.version} (${AppInfo.buildNumber})'),
        findsOneWidget,
      );
      expect(find.text(AppInfo.repositoryUrl), findsOneWidget);
      expect(find.text(AppInfo.licenseName), findsOneWidget);
      expect(
        find.textContaining('Everything stays on this device'),
        findsOneWidget,
      );
      expect(find.text('Made by Team Super Panda'), findsOneWidget);
      expect(find.text('Open source licences'), findsOneWidget);
    });

    testWidgets('copy button copies the repository link', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(buildTestApp(const AboutPage()));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.copy));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Link copied'), findsOneWidget);
    });

    testWidgets('opens the bundled licence registry', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(buildTestApp(const AboutPage()));
      await tester.pump();

      await tester.tap(find.text('Open source licences'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(const Duration(seconds: 1));

      expect(find.byType(LicensePage), findsOneWidget);
    });
  });

  group('View options', () {
    testWidgets('offers About and asks the caller to open it', (tester) async {
      final controller = NotesController(MockRepository());
      await controller.load();
      Object? result;

      await tester.pumpWidget(
        buildTestApp(
          Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  result = await showModalBottomSheet<Object?>(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => ViewOptionsSheet(
                      controller: controller,
                      settingsService: SettingsService(),
                      accentColorOptions: accentColorOptions,
                    ),
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.drag(
        find.byType(SingleChildScrollView).first,
        const Offset(0, -800),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('About'));
      await tester.pumpAndSettle();

      expect(result, ViewOptionsSheet.aboutRequest);
    });
  });
}
