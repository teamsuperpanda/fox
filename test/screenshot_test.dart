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

  String folder(String localeTag) => 'golden/$name/$localeTag';
}

const _devices = [
  _Device('iphone_5.5', 414, 736),
  _Device('iphone_6.9', 440, 956),
  _Device('iphone_6.5', 428, 926),
  _Device('android', 360, 640),
];

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
      theme: AppTheme.light(accentColorOptions.first, useGoogleFonts: false).copyWith(
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          elevation: 0,
        ),
      ),
      darkTheme: AppTheme.dark(accentColorOptions.first, useGoogleFonts: false).copyWith(
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          elevation: 0,
        ),
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

  group('store', () {
    const device = _Device('iphone_6.5', 428, 926);
    late LocaleProvider localeProvider;

    setUp(() async {
      localeProvider = LocaleProvider();
      await localeProvider.setLocale(const Locale('en'));
    });

    testWidgets('light', (tester) async {
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await seedNotes();
      await tester.binding
          .setSurfaceSize(Size(device.widthDp, device.heightDp));
      await tester.pumpWidget(buildApp(
          themeMode: ThemeMode.light,
          controller: controller,
          localeProvider: localeProvider));
      await precacheIcon(tester);
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('golden/store/light.png'),
      );
    });

    testWidgets('dark', (tester) async {
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.binding
          .setSurfaceSize(Size(device.widthDp, device.heightDp));
      await tester.pumpWidget(buildApp(
          themeMode: ThemeMode.dark,
          controller: controller,
          localeProvider: localeProvider));
      await precacheIcon(tester);
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('golden/store/dark.png'),
      );
    });

    testWidgets('new_note', (tester) async {
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
        matchesGoldenFile('golden/store/new_note.png'),
      );
    });

    testWidgets('settings', (tester) async {
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await seedNotes();
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
        matchesGoldenFile('golden/store/settings.png'),
      );
    });
  });
}
