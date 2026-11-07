import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fox/models/note_colors.dart';
import 'package:fox/services/notes_controller.dart';
import 'package:fox/services/settings_service.dart';
import 'package:fox/widgets/view_options_sheet.dart';

import 'test_helpers.dart';

/// Settings service whose writes stay pending until [finish] completes, so a
/// test can dispose the sheet in the middle of a write.
///
/// Create it inside the test body: its completers must live in the test's
/// fake-async zone or the continuations never run.
class _BlockingSettingsService extends SettingsService {
  final started = Completer<void>();
  final finish = Completer<void>();

  Future<void> _blockThenApply(Future<void> Function() apply) async {
    if (!started.isCompleted) started.complete();
    await finish.future;
    await apply();
  }

  @override
  Future<void> setSortBy(String value) =>
      _blockThenApply(() => super.setSortBy(value));

  @override
  Future<void> setShowTags(bool show) =>
      _blockThenApply(() => super.setShowTags(show));
}

void main() {
  group('ViewOptionsSheet', () {
    late NotesController controller;

    setUp(() async {
      controller = NotesController(MemoryRepo());
      await controller.load();
    });

    Future<void> openSheet(
      WidgetTester tester,
      _BlockingSettingsService settings,
    ) async {
      await tester.pumpWidget(
        buildTestApp(
          ViewOptionsSheet(
            controller: controller,
            settingsService: settings,
            accentColorOptions: accentColorOptions,
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    /// Disposes the sheet while its write is still pending, then lets the write
    /// finish. Without a mounted guard the `setDialogState` continuation throws.
    Future<void> dismissDuringWrite(
      WidgetTester tester,
      _BlockingSettingsService settings,
    ) async {
      await tester.pumpWidget(buildTestApp(const SizedBox.shrink()));
      await tester.pump();

      settings.finish.complete();
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    }

    testWidgets('dismissing during a delayed switch write does not throw',
        (tester) async {
      final settings = _BlockingSettingsService();
      await openSheet(tester, settings);

      await tester.tap(find.text('Show Tags'));
      await tester.pump();
      await settings.started.future;

      await dismissDuringWrite(tester, settings);
    });

    testWidgets('dismissing during a delayed sort write does not throw',
        (tester) async {
      final settings = _BlockingSettingsService();
      await openSheet(tester, settings);

      await tester.tap(find.text('Title (A-Z)'));
      await tester.pump();
      await settings.started.future;

      await dismissDuringWrite(tester, settings);
    });
  });
}
