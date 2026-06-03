import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fox/home_page.dart';
import 'package:fox/l10n/app_localizations.dart';
import 'package:fox/models/settings.dart';
import 'package:fox/models/settings_adapter.dart';
import 'package:fox/providers/locale_provider.dart';
import 'package:fox/providers/theme_provider.dart';
import 'package:fox/services/box_names.dart';
import 'package:fox/services/constants.dart';
import 'package:fox/services/notes_controller.dart';
import 'package:fox/services/umami_service.dart';
import 'package:fox/theme/app_theme.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

import 'test_helpers.dart';

class _Device {
  const _Device(this.name, this.widthDp, this.heightDp);

  final String name;
  final double widthDp;
  final double heightDp;

  String folder(String localeTag) => 'golden/$name/raw/$localeTag';
}

const _devices = [
  _Device('iphone_5.5', 414, 736),
  _Device('iphone_6.9', 440, 956),
  _Device('iphone_6.5', 414, 896),
  _Device('android', 360, 640),
];

const _targetLocales = [
  Locale('ar'),
  Locale('de'),
  Locale('en'),
  Locale('es'),
  Locale('es', '419'),
  Locale('fr'),
  Locale('hi'),
  Locale('id'),
  Locale('it'),
  Locale('ja'),
  Locale('ko'),
  Locale('nl'),
  Locale('pl'),
  Locale('pt'),
  Locale('pt', 'PT'),
  Locale('ru'),
  Locale('sv'),
  Locale('tr'),
  Locale('vi'),
  Locale('zh'),
  Locale('zh', 'TW'),
];

ThemeData _applyFont(ThemeData theme) {
  return theme.copyWith(
    textTheme: theme.textTheme.apply(fontFamily: 'Roboto'),
    appBarTheme: theme.appBarTheme.copyWith(
      titleTextStyle: theme.appBarTheme.titleTextStyle?.copyWith(
        fontFamily: 'Roboto',
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      elevation: 0,
    ),
  );
}

Widget buildApp({
  required ThemeMode themeMode,
  required NotesController controller,
  LocaleProvider? localeProvider,
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: ThemeProvider()),
      ChangeNotifierProvider.value(value: localeProvider ?? LocaleProvider()),
      Provider.value(
        value: UmamiService(
          websiteId: 'test',
          endpoint: 'https://test.com/api/send',
        ),
      ),
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        ...AppLocalizations.localizationsDelegates,
        FlutterQuillLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: localeProvider?.locale,
      themeMode: themeMode,
      theme: _applyFont(
        AppTheme.light(accentColorOptions.first, useGoogleFonts: false),
      ),
      darkTheme: _applyFont(
        AppTheme.dark(accentColorOptions.first, useGoogleFonts: false),
      ),
      home: HomePage(controller: controller, useGoogleFonts: false),
    ),
  );
}

Future<void> precacheIcon(WidgetTester tester) async {
  await tester.runAsync(() => precacheImage(
        const AssetImage('assets/images/icon/icon.png'),
        tester.element(find.byType(MaterialApp)),
      ));
  await tester.pump();
  await tester.pump();
}

void main() {
  late MockRepository mockRepo;
  late NotesController controller;

  setUp(() async {
    Hive.init('./test/hive_screenshot_test');
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(SettingsAdapter());
    }
    await Hive.openBox<Settings>(BoxNames.settings);

    mockRepo = MockRepository();
    controller = NotesController(mockRepo);
    await controller.load();
    controller.setFabAnimation(false);
  });

  tearDown(() async {
    if (Hive.isBoxOpen(BoxNames.settings)) {
      await Hive.box<Settings>(BoxNames.settings).close();
    }
    await Hive.deleteFromDisk();
  });

  Future<void> seedNotes() async {
    await controller.addOrUpdate(
      title: 'Grocery List',
      content: Document()
        ..insert(0,
            'Milk, eggs, bread, butter, cheese, tomatoes, lettuce, olive oil, chicken breast, rice, pasta'),
      pinned: true,
      tags: ['shopping'],
    );
    await controller.addOrUpdate(
      title: 'Meeting Notes - Q3 Planning',
      content: Document()
        ..insert(0,
            'Roadmap discussion:\n\u2022 Feature prioritisation for next quarter\n\u2022 Resource allocation - need 2 more devs\n\u2022 Timeline review - current vs projected\n\u2022 Risk assessment: database migration'),
      tags: ['work', 'project'],
    );
    await controller.addOrUpdate(
      title: 'Pasta alla Carbonara',
      content: Document()
        ..insert(0,
            'Ingredients:\n\u2022 200g spaghetti\n\u2022 3 egg yolks + 1 whole egg\n\u2022 100g guanciale or pancetta\n\u2022 50g Pecorino Romano, finely grated\n\u2022 50g Parmesan\n\u2022 Freshly cracked black pepper\n\nNo cream! The silky sauce comes from eggs and cheese alone.'),
      tags: ['recipes'],
    );
    await controller.addOrUpdate(
      title: 'Book: Deep Work',
      content: Document()
        ..insert(0,
            "Cal Newport - key takeaways:\n\n\u2022 Deep work = professional activity in a state of distraction-free concentration\n\u2022 Schedule every minute of your day\n\u2022 Embrace boredom - don't always reach for your phone\n\u2022 Quit social media (or at least be intentional)\n\u2022 Drain the shallows - minimise shallow tasks"),
      pinned: true,
      tags: ['books', 'self-improvement'],
    );
    await controller.addOrUpdate(
      title: 'Weekend Hike Plans',
      content: Document()
        ..insert(0,
            'Trail: Eagle Falls via the scenic loop\nDistance: 8 km round trip\nElevation gain: ~350 m\nEstimated time: 3-4 hours\n\nPack: water (2L), snacks, first-aid kit, rain jacket, sunscreen, hat. Check trail conditions before heading out.'),
      tags: ['personal', 'outdoors'],
      color: '#66BB6A',
    );
    await controller.addOrUpdate(
      title: 'App Ideas',
      content: Document()
        ..insert(0,
            '\u2022 Plant watering tracker - reminders + photo log\n\u2022 Local music scene - gig listings, venue maps\n\u2022 Fermentation timers - sauerkraut, kombucha, sourdough\n\u2022 Packing list generator - trip length, destination, activities'),
      tags: ['ideas'],
      color: '#FFCA28',
    );
  }

  for (final locale in _targetLocales) {
    final localeTag = localeToTag(locale);

    group(localeTag, () {
      late LocaleProvider localeProvider;

      setUp(() async {
        localeProvider = LocaleProvider();
        await localeProvider.setLocale(locale);
      });

      for (final device in _devices) {
        group(device.name, () {
          for (final tm in [ThemeMode.light, ThemeMode.dark]) {
            final suffix = tm == ThemeMode.light ? 'light' : 'dark';

            group('main', () {
              setUp(() async => seedNotes());

              testWidgets(suffix, (tester) async {
                addTearDown(() => tester.binding.setSurfaceSize(null));
                await tester.binding
                    .setSurfaceSize(Size(device.widthDp, device.heightDp));
                await tester.pumpWidget(buildApp(
                    themeMode: tm,
                    controller: controller,
                    localeProvider: localeProvider));
                await precacheIcon(tester);
                await expectLater(
                  find.byType(MaterialApp),
                  matchesGoldenFile(
                      '${device.folder(localeTag)}/main_$suffix.png'),
                );
              });
            });
          }

          group('new_note', () {
            testWidgets('light', (tester) async {
              addTearDown(() => tester.binding.setSurfaceSize(null));
              await tester.binding
                  .setSurfaceSize(Size(device.widthDp, device.heightDp));
              await tester.pumpWidget(buildApp(
                  themeMode: ThemeMode.light,
                  controller: controller,
                  localeProvider: localeProvider));
              await tester.tap(find.byType(FloatingActionButton));
              await tester.pump();
              await tester.pump(const Duration(milliseconds: 500));
              await expectLater(
                find.byType(MaterialApp),
                matchesGoldenFile(
                    '${device.folder(localeTag)}/new_note_light.png'),
              );
            });
          });

          group('settings', () {
            setUp(() async => seedNotes());

            testWidgets('light', (tester) async {
              addTearDown(() => tester.binding.setSurfaceSize(null));
              await tester.binding
                  .setSurfaceSize(Size(device.widthDp, device.heightDp));
              await tester.pumpWidget(buildApp(
                  themeMode: ThemeMode.light,
                  controller: controller,
                  localeProvider: localeProvider));
              await tester.runAsync(() => precacheImage(
                    const AssetImage('assets/images/icon/icon.png'),
                    tester.element(find.byType(MaterialApp)),
                  ));
              await tester.tap(find.byIcon(Icons.tune));
              await tester.pump();
              await tester.pump(const Duration(milliseconds: 500));
              await expectLater(
                find.byType(MaterialApp),
                matchesGoldenFile(
                    '${device.folder(localeTag)}/settings_light.png'),
              );
            });
          });
        });
      }
    });
  }
}
