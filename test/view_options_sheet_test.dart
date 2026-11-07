import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fox/l10n/app_localizations.dart';
import 'package:fox/models/note_colors.dart';
import 'package:fox/providers/locale_provider.dart';
import 'package:fox/providers/theme_provider.dart';
import 'package:fox/services/notes_controller.dart';
import 'package:fox/services/settings_service.dart';
import 'package:fox/widgets/language_picker_dialog.dart';
import 'package:fox/widgets/view_options_sheet.dart';
import 'package:provider/provider.dart';

import 'test_helpers.dart';

class _ThrowingSettingsService extends SettingsService {
  @override
  Future<void> setSortBy(String value) async {
    throw Exception('disk full');
  }
}

Future<NotesController> buildController() async {
  final controller = NotesController(MemoryRepo());
  await controller.load();
  return controller;
}

Future<void> pumpSheet(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = const Size(1000, 2200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(child);
}

Widget buildSheet(
  NotesController controller,
  SettingsService settings, {
  Locale? locale,
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: ThemeProvider()),
      ChangeNotifierProvider.value(value: LocaleProvider()),
    ],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: locale,
      home: Scaffold(
        body: ViewOptionsSheet(
          controller: controller,
          settingsService: settings,
          accentColorOptions: accentColorOptions,
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('shows sort options with the current one selected', (
    tester,
  ) async {
    final controller = await buildController();

    await pumpSheet(tester, buildSheet(controller, SettingsService()));

    expect(find.text('Date (Newest First)'), findsOneWidget);
    expect(find.text('Title (A-Z)'), findsOneWidget);
    expect(find.byIcon(Icons.radio_button_checked), findsOneWidget);
  });

  testWidgets('selecting a sort order updates controller and settings', (
    tester,
  ) async {
    final controller = await buildController();
    final settings = SettingsService();

    await pumpSheet(tester, buildSheet(controller, settings));
    await tester.tap(find.text('Title (A-Z)'));
    await tester.pumpAndSettle();

    expect(controller.sortBy, SortBy.titleAsc);
    expect(settings.getSortBy(), 'titleAsc');
  });

  testWidgets('every view switch updates controller and settings', (
    tester,
  ) async {
    final controller = await buildController();
    final settings = SettingsService();

    await pumpSheet(tester, buildSheet(controller, settings));

    await tester.tap(find.text('Show Tags'));
    await tester.pumpAndSettle();
    expect(controller.showTags, isFalse);
    expect(settings.getShowTags(), isFalse);

    await tester.tap(find.text('Show Note Previews'));
    await tester.pumpAndSettle();
    expect(controller.showContent, isFalse);
    expect(settings.getShowContent(), isFalse);

    await tester.tap(find.text('Alternating Row Colors'));
    await tester.pumpAndSettle();
    expect(controller.alternatingColors, isTrue);
    expect(settings.getAlternatingColors(), isTrue);

    await tester.tap(find.text('Animate Add Button'));
    await tester.pumpAndSettle();
    expect(controller.fabAnimation, isFalse);
    expect(settings.getFabAnimation(), isFalse);
  });

  testWidgets('tapping an accent colour updates the theme provider', (
    tester,
  ) async {
    final controller = await buildController();

    await pumpSheet(tester, buildSheet(controller, SettingsService()));
    final provider =
        tester.element(find.byType(ViewOptionsSheet)).read<ThemeProvider>();
    final before = provider.accentColor;

    await tester.tap(find.byType(AnimatedContainer).at(1));
    await tester.pumpAndSettle();

    expect(provider.accentColor, isNot(before));
  });

  testWidgets('the language row opens the picker dialog', (tester) async {
    final controller = await buildController();

    await pumpSheet(tester, buildSheet(controller, SettingsService()));
    await tester.tap(find.text('System Default'));
    await tester.pumpAndSettle();

    expect(find.byType(LanguagePickerDialog), findsOneWidget);
  });

  testWidgets('the close button dismisses the sheet route', (tester) async {
    final controller = await buildController();

    await pumpSheet(
      tester,
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: ThemeProvider()),
          ChangeNotifierProvider.value(value: LocaleProvider()),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showModalBottomSheet<void>(
                  context: context,
                  builder: (_) => ViewOptionsSheet(
                    controller: controller,
                    settingsService: SettingsService(),
                    accentColorOptions: accentColorOptions,
                  ),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.byType(ViewOptionsSheet), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    expect(find.byType(ViewOptionsSheet), findsNothing);
  });

  testWidgets('a failed save shows feedback instead of swallowing it', (
    tester,
  ) async {
    final controller = await buildController();

    await pumpSheet(
      tester,
      buildSheet(controller, _ThrowingSettingsService()),
    );
    await tester.tap(find.text('Title (A-Z)'));
    await tester.pumpAndSettle();

    expect(find.text('Could not save your changes'), findsOneWidget);
    // The preference still applies in memory for this session.
    expect(controller.sortBy, SortBy.titleAsc);
  });
}
