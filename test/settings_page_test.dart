import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fox/models/note_colors.dart';
import 'package:fox/providers/locale_provider.dart';
import 'package:fox/providers/theme_provider.dart';
import 'package:fox/services/notes_controller.dart';
import 'package:fox/services/settings_service.dart';
import 'package:fox/settings_page.dart';
import 'package:fox/widgets/language_picker_dialog.dart';
import 'package:fox/widgets/settings/about_settings_section.dart';
import 'package:fox/widgets/settings/appearance_settings_section.dart';
import 'package:fox/widgets/settings/language_settings_section.dart';
import 'package:fox/widgets/settings/sort_settings_section.dart';
import 'package:fox/widgets/settings/view_settings_section.dart';
import 'package:provider/provider.dart';

import 'test_helpers.dart';

Widget _scaffold(Widget child) => buildTestApp(Scaffold(body: child));

void main() {
  group('SettingsPage', () {
    late NotesController controller;
    late SettingsService settingsService;

    setUp(() {
      controller = NotesController(MockRepository());
      settingsService = SettingsService();
    });

    testWidgets('shows every settings section', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          SettingsPage(
            controller: controller,
            settingsService: settingsService,
          ),
        ),
      );

      expect(find.text('Theme Color'), findsOneWidget);
      expect(find.text('Show Tags'), findsOneWidget);

      await tester.scrollUntilVisible(find.text('Sort By'), 200);
      expect(find.text('Sort By'), findsOneWidget);

      await tester.scrollUntilVisible(find.text('Language'), 200);
      expect(find.text('Language'), findsOneWidget);

      await tester.scrollUntilVisible(find.byType(AboutSettingsSection), 200);
      expect(find.byType(AboutSettingsSection), findsOneWidget);
    });
  });

  group('AppearanceSettingsSection', () {
    testWidgets('tapping a colour updates the theme provider', (tester) async {
      await tester.pumpWidget(
        _scaffold(
          AppearanceSettingsSection(accentColorOptions: accentColorOptions),
        ),
      );
      final provider = tester
          .element(find.byType(AppearanceSettingsSection))
          .read<ThemeProvider>();

      final swatches = find.descendant(
        of: find.byType(AppearanceSettingsSection),
        matching: find.byType(GestureDetector),
      );
      await tester.tap(swatches.at(1));
      await tester.pumpAndSettle();

      expect(provider.accentColor, accentColorOptions[1]);
    });
  });

  group('ViewSettingsSection', () {
    late NotesController controller;
    late SettingsService settingsService;

    setUp(() {
      controller = NotesController(MockRepository());
      settingsService = SettingsService();
    });

    testWidgets('toggling show tags updates controller and service',
        (tester) async {
      await tester.pumpWidget(
        _scaffold(
          ViewSettingsSection(
            controller: controller,
            settingsService: settingsService,
          ),
        ),
      );

      await tester.tap(find.text('Show Tags'));
      await tester.pumpAndSettle();

      expect(controller.showTags, isFalse);
      expect(settingsService.getShowTags(), isFalse);
    });

    testWidgets('toggling note previews persists the preference',
        (tester) async {
      await tester.pumpWidget(
        _scaffold(
          ViewSettingsSection(
            controller: controller,
            settingsService: settingsService,
          ),
        ),
      );

      await tester.tap(find.text('Show Note Previews'));
      await tester.pumpAndSettle();

      expect(controller.showContent, isFalse);
      expect(settingsService.getShowContent(), isFalse);
    });
  });

  group('SortSettingsSection', () {
    late NotesController controller;
    late SettingsService settingsService;

    setUp(() {
      controller = NotesController(MockRepository());
      settingsService = SettingsService();
    });

    testWidgets('selecting a sort order updates controller and service',
        (tester) async {
      await tester.pumpWidget(
        _scaffold(
          SortSettingsSection(
            controller: controller,
            settingsService: settingsService,
          ),
        ),
      );

      await tester.tap(find.text('Title (A-Z)'));
      await tester.pumpAndSettle();

      expect(controller.sortBy, SortBy.titleAsc);
      expect(settingsService.getSortBy(), 'titleAsc');
    });
  });

  group('LanguageSettingsSection', () {
    testWidgets('shows the system default and opens the language picker',
        (tester) async {
      await tester.pumpWidget(
        _scaffold(const LanguageSettingsSection(onLocaleChanged: _noop)),
      );

      expect(find.text('System Default'), findsOneWidget);

      await tester.tap(find.text('System Default'));
      await tester.pumpAndSettle();

      expect(find.byType(LanguagePickerDialog), findsOneWidget);
    });

    testWidgets('displays the persisted locale', (tester) async {
      final settings = SettingsService();
      await settings.setLocale('fr');
      final localeProvider = LocaleProvider(settingsRepository: settings);
      await localeProvider.load();

      await tester.pumpWidget(
        buildTestApp(
          Scaffold(body: const LanguageSettingsSection(onLocaleChanged: _noop)),
          localeProvider: localeProvider,
        ),
      );

      expect(find.text('Français'), findsOneWidget);
    });
  });

  group('AboutSettingsSection', () {
    testWidgets('opens the licence page', (tester) async {
      await tester.pumpWidget(_scaffold(const AboutSettingsSection()));

      final licensesLabel =
          MaterialLocalizations.of(tester.element(find.byType(Scaffold)))
              .licensesPageTitle;
      expect(find.text(licensesLabel), findsOneWidget);

      await tester.tap(find.text(licensesLabel));
      await tester.pumpAndSettle();

      expect(find.byType(LicensePage), findsOneWidget);
    });
  });
}

void _noop() {}
