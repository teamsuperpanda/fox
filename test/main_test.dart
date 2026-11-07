import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fox/l10n/app_localizations.dart';
import 'package:fox/main.dart';
import 'package:fox/providers/locale_provider.dart';
import 'package:fox/providers/theme_provider.dart';
import 'package:fox/services/constants.dart';
import 'package:fox/services/notes_controller.dart';
import 'package:fox/services/settings_service.dart';
import 'package:provider/provider.dart';

import 'test_helpers.dart';

void main() {
  group('Provider wiring (not main())', () {
    testWidgets('providers are wired correctly', (tester) async {
      await tester.pumpWidget(buildTestApp(
        Builder(
          builder: (context) {
            expect(context.watch<ThemeProvider>(), isNotNull);
            expect(context.watch<LocaleProvider>(), isNotNull);
            return const SizedBox();
          },
        ),
      ));
    });
  });

  group('Locale resolution', () {
    const supported = AppLocalizations.supportedLocales;

    test('an unsupported locale resolves to English', () {
      expect(
          resolveAppLocale(const Locale('sw'), supported), const Locale('en'));
      expect(
          resolveAppLocale(const Locale('cy'), supported), const Locale('en'));
    });

    test('a missing locale resolves to English', () {
      expect(resolveAppLocale(null, supported), const Locale('en'));
    });

    test('supported locales are kept, including RTL ones', () {
      expect(
          resolveAppLocale(const Locale('ar'), supported), const Locale('ar'));
      expect(
          resolveAppLocale(const Locale('he'), supported), const Locale('he'));
    });

    test('a language-only request matches its supported variant', () {
      expect(resolveAppLocale(const Locale('pt', 'BR'), supported),
          const Locale('pt'));
      expect(resolveAppLocale(const Locale('es', 'MX'), supported),
          const Locale('es'));
    });

    testWidgets('MyApp renders English on an unsupported system locale',
        (tester) async {
      tester.platformDispatcher.localesTestValue = <Locale>[
        const Locale('sw'),
      ];
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);

      final settings = SettingsService();
      final controller =
          NotesController(MemoryRepo(), settingsRepository: settings);
      await controller.load();
      final themeProvider = ThemeProvider(settingsRepository: settings);
      final localeProvider = LocaleProvider(settingsRepository: settings);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: themeProvider),
            ChangeNotifierProvider.value(value: localeProvider),
            ChangeNotifierProvider.value(value: controller),
          ],
          child: MyApp(
            notesController: controller,
            settingsService: settings,
          ),
        ),
      );
      await tester.pump();

      final context = tester.element(find.byType(Scaffold).first);
      expect(Localizations.localeOf(context), const Locale('en'));
    });
  });
}
