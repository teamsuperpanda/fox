import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fox/home_page.dart';
import 'package:fox/models/note_colors.dart';
import 'package:fox/services/notes_controller.dart';
import 'package:fox/services/settings_service.dart';
import 'package:fox/theme/app_theme.dart';
import 'package:fox/widgets/folders_dialog.dart';
import 'package:fox/widgets/note_list.dart';
import 'package:fox/widgets/view_options_sheet.dart';

import 'test_helpers.dart';

/// WCAG 2.x relative luminance.
double _luminance(Color color) {
  double channel(double value) {
    final c = value;
    return c <= 0.03928
        ? c / 12.92
        : math.pow((c + 0.055) / 1.055, 2.4).toDouble();
  }

  return 0.2126 * channel(color.r) +
      0.7152 * channel(color.g) +
      0.0722 * channel(color.b);
}

double _contrast(Color foreground, Color background) {
  final a = _luminance(foreground);
  final b = _luminance(background);
  return (math.max(a, b) + 0.05) / (math.min(a, b) + 0.05);
}

List<Color> get _accents => accentColorOptions;

void main() {
  group('theme contrast', () {
    for (final brightness in Brightness.values) {
      test('$brightness text pairs meet WCAG AA', () {
        final theme = brightness == Brightness.light
            ? AppTheme.light(_accents.first)
            : AppTheme.dark(_accents.first);
        final scheme = theme.colorScheme;
        final background = theme.scaffoldBackgroundColor;
        const minimum = 4.5;

        expect(
          _contrast(scheme.onSurface, background),
          greaterThanOrEqualTo(minimum),
          reason: 'onSurface on the scaffold background',
        );
        expect(
          _contrast(scheme.onSurfaceVariant, background),
          greaterThanOrEqualTo(minimum),
          reason: 'onSurfaceVariant on the scaffold background',
        );
        expect(
          _contrast(scheme.onPrimary, scheme.primary),
          greaterThanOrEqualTo(minimum),
          reason: 'onPrimary on primary',
        );
        expect(
          _contrast(scheme.onError, scheme.error),
          greaterThanOrEqualTo(minimum),
          reason: 'onError on error',
        );
        expect(
          _contrast(scheme.error, scheme.surface),
          greaterThanOrEqualTo(minimum),
          reason: 'error on surface',
        );
        expect(
          _contrast(scheme.onTertiary, scheme.tertiary),
          greaterThanOrEqualTo(minimum),
          reason: 'onTertiary on tertiary',
        );
      });
    }

    test('every accent keeps onPrimary readable', () {
      for (final accent in _accents) {
        for (final theme in [AppTheme.light(accent), AppTheme.dark(accent)]) {
          final scheme = theme.colorScheme;
          expect(
            _contrast(scheme.onPrimary, scheme.primary),
            greaterThanOrEqualTo(4.5),
            reason: 'accent $accent',
          );
        }
      }
    });
  });

  group('screen reader labels', () {
    late NotesController controller;

    setUp(() async {
      controller = NotesController(MockRepository());
      await controller.load();
    });

    testWidgets('note tiles are announced once', (tester) async {
      final note = makeNote(title: 'Shopping list');
      await tester.pumpWidget(
        buildTestApp(
          Scaffold(
            body: NoteList(controller: controller, notes: [note]),
          ),
        ),
      );

      final handle = tester.ensureSemantics();
      expect(find.bySemanticsLabel(RegExp('Note:')), findsNothing);
      final node = tester.getSemantics(find.text('Shopping list').first);
      expect(node.label, startsWith('Shopping list'));
      expect('Shopping list'.allMatches(node.label).length, 1);
      handle.dispose();
    });

    testWidgets('folder tiles are announced once', (tester) async {
      await controller.addFolder('Work');
      await tester.pumpWidget(
        buildTestApp(
          Scaffold(
            body: FoldersDialog(controller: controller),
          ),
        ),
      );

      final handle = tester.ensureSemantics();
      expect(find.bySemanticsLabel(RegExp('Folder:')), findsNothing);
      final node = tester.getSemantics(find.text('Work').first);
      expect(node.label, 'Work');
      expect('Work'.allMatches(node.label).length, 1);
      handle.dispose();
    });

    testWidgets('home page actions are labelled', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          HomePage(
            controller: controller,
            settingsService: SettingsService(),
          ),
        ),
      );
      await tester.pump();

      expect(find.byTooltip('Folders'), findsOneWidget);
      expect(find.byTooltip('View options'), findsOneWidget);
      expect(find.byTooltip('Toggle theme'), findsOneWidget);
      expect(find.byTooltip('Add note'), findsOneWidget);
    });
  });

  group('tap targets', () {
    testWidgets('folder filter clear button is at least 48x48', (tester) async {
      final controller = NotesController(MockRepository());
      await controller.load();
      await controller.addFolder('Work');
      controller.setSelectedFolder(controller.folders.first.id);

      await tester.pumpWidget(
        buildTestApp(
          HomePage(
            controller: controller,
            settingsService: SettingsService(),
          ),
        ),
      );
      await tester.pump();

      final button = find.ancestor(
        of: find.byIcon(Icons.close),
        matching: find.byType(IconButton),
      );
      final size = tester.getSize(button);
      expect(size.width, greaterThanOrEqualTo(48));
      expect(size.height, greaterThanOrEqualTo(48));
    });

    testWidgets('accent swatches are at least 48x48', (tester) async {
      final controller = NotesController(MockRepository());
      await controller.load();
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(
        buildTestApp(
          Scaffold(
            body: ViewOptionsSheet(
              controller: controller,
              settingsService: SettingsService(),
              accentColorOptions: accentColorOptions,
            ),
          ),
        ),
      );
      await tester.pump();

      final swatch = find
          .ancestor(
            of: find.byType(AnimatedContainer).first,
            matching: find.byType(SizedBox),
          )
          .first;
      final size = tester.getSize(swatch);
      expect(size.width, greaterThanOrEqualTo(48));
      expect(size.height, greaterThanOrEqualTo(48));
      handle.dispose();
    });
  });

  group('text scaling', () {
    testWidgets('home page does not overflow at 200 percent', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final controller = NotesController(MockRepository());
      await controller.load();
      await controller.addFolder('A very long folder name that could overflow');
      final folderId = controller.folders.first.id;
      controller.setSelectedFolder(folderId);
      await controller.addOrUpdate(
        title: 'A note with a very long title that should wrap instead of clip',
        content: Document.fromJson([
          {
            'insert':
                'Body copy that is long enough to fill the preview line.\n'
          }
        ]),
        folderId: folderId,
        tags: const ['work', 'a-very-long-tag-that-should-wrap'],
      );

      await tester.pumpWidget(
        buildTestApp(
          HomePage(
            controller: controller,
            settingsService: SettingsService(),
          ),
          textScaler: const TextScaler.linear(2),
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(
        find.text('A very long folder name that could overflow'),
        findsWidgets,
      );
    });
  });

  group('RTL', () {
    testWidgets('home page renders right to left without errors',
        (tester) async {
      final controller = NotesController(MockRepository());
      await controller.load();
      await controller.addOrUpdate(
        title: 'ملاحظة',
        content: Document.fromJson([
          {'insert': 'مرحبا\n'}
        ]),
      );

      await tester.pumpWidget(
        buildTestApp(
          HomePage(
            controller: controller,
            settingsService: SettingsService(),
          ),
          locale: const Locale('ar'),
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
      final context = tester.element(find.byType(HomePage));
      expect(Directionality.of(context), TextDirection.rtl);
      expect(find.text('ملاحظة'), findsOneWidget);
    });
  });

  group('reduced motion', () {
    testWidgets('the FAB wiggle does not run when animations are disabled',
        (tester) async {
      final controller = NotesController(MockRepository());
      await controller.load();

      await tester.pumpWidget(
        buildTestApp(
          HomePage(
            controller: controller,
            settingsService: SettingsService(),
          ),
          disableAnimations: true,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final transform = tester.widget<Transform>(
        find
            .ancestor(
              of: find.byType(FloatingActionButton),
              matching: find.byType(Transform),
            )
            .first,
      );
      expect(transform.transform.entry(1, 0), closeTo(0, 1e-6));
    });
  });
}
