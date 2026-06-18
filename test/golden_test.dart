import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fox/home_page.dart';
import 'package:fox/l10n/app_localizations.dart';
import 'package:fox/models/note.dart';
import 'package:fox/note_detail_page.dart';
import 'package:fox/providers/locale_provider.dart';
import 'package:fox/providers/theme_provider.dart';
import 'package:fox/services/notes_controller.dart';
import 'package:fox/services/settings_service.dart';
import 'package:fox/services/umami_service.dart';
import 'package:fox/theme/app_theme.dart';
import 'package:provider/provider.dart';

import 'store_frame.dart';
import 'test_helpers.dart';

const _golden = <String>['golden'];
const _goldenDir = '../assets/images/screenshots';

const _unstableGoldenTests = <String>{};

class _DeviceConfig {
  const _DeviceConfig(this.size, this.dpr);
  final Size size;
  final double dpr;
}

final _devices = <String, _DeviceConfig>{
  'iphone_6.9': const _DeviceConfig(Size(440, 956), 3),
  'iphone_6.5': const _DeviceConfig(Size(414, 896), 3),
  'android': const _DeviceConfig(Size(360, 640), 3),
  'ipad_12.9': const _DeviceConfig(Size(1024, 1366), 2),
  'ipad_13': const _DeviceConfig(Size(1032, 1376), 2),
};

const _storeTagline = 'Your thoughts, organized.';
const _storeHeadline = 'Capture Ideas Effortlessly';
const _storeFeatures = [
  'Rich Text Editing',
  'Dark Mode Support',
  'Organize with Tags',
];

Widget _buildApp({
  required ThemeMode themeMode,
  required NotesController controller,
  required SettingsService settingsService,
}) {
  final umami = UmamiService(
    websiteId: 'test',
    endpoint: 'https://test.com/api/send',
  );
  return MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: ThemeProvider(settingsRepository: settingsService)),
      ChangeNotifierProvider.value(value: LocaleProvider(settingsRepository: settingsService)),
      Provider.value(value: umami),
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        ...AppLocalizations.localizationsDelegates,
        FlutterQuillLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      themeMode: themeMode,
      theme: () {
        final base =
            AppTheme.light(accentColorOptions.first);
        return base.copyWith(
          appBarTheme: base.appBarTheme.copyWith(
            titleTextStyle: TextStyle(
              fontFamily: 'Roboto',
              color: const Color(0xFF333333),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          floatingActionButtonTheme:
              const FloatingActionButtonThemeData(elevation: 0),
        );
      }(),
      darkTheme: () {
        final base =
            AppTheme.dark(accentColorOptions.first);
        return base.copyWith(
          appBarTheme: base.appBarTheme.copyWith(
            titleTextStyle: TextStyle(
              fontFamily: 'Roboto',
              color: const Color(0xFFF8F5F1),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          floatingActionButtonTheme:
              const FloatingActionButtonThemeData(elevation: 0),
        );
      }(),
      home: HomePage(controller: controller, settingsService: settingsService),
    ),
  );
}

Future<NotesController> _createControllerWithNotes() async {
  final repo = MockRepository();
  final controller = NotesController(repo);
  await controller.load();
  await controller.addOrUpdate(
    title: 'Meeting Notes',
    content: Document()..insert(0, 'Discuss Q3 roadmap and sprint planning'),
  );
  await controller.addOrUpdate(
    title: 'Shopping List',
    content: Document()..insert(0, 'Milk, eggs, bread, coffee'),
  );
  await controller.addOrUpdate(
    title: 'Ideas for Weekend',
    content: Document()..insert(0, 'Hike in the mountains, visit museum'),
  );
  controller.setFabAnimation(false);
  return controller;
}

void main() {
  for (final entry in _devices.entries) {
    final deviceName = entry.key;
    final config = entry.value;

    group(deviceName, () {
      late NotesController controller;
      late SettingsService settingsService;

      setUp(() async {
        controller = await _createControllerWithNotes();
        settingsService = SettingsService();
      });

      void setViewport(WidgetTester tester) {
        tester.view.physicalSize = config.size * config.dpr;
        tester.view.devicePixelRatio = config.dpr;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });
      }

      Widget buildStoreFrame(Widget child) {
        return StoreFrame(
          tagline: _storeTagline,
          headline: _storeHeadline,
          features: _storeFeatures,
          child: child,
        );
      }

      Future<void> pumpRaw({
        required WidgetTester tester,
        required ThemeMode themeMode,
        required String label,
      }) async {
        setViewport(tester);
        await tester.pumpWidget(_buildApp(
          themeMode: themeMode,
          controller: controller,
          settingsService: settingsService,
        ));
        await tester.pump();
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('$_goldenDir/$deviceName/raw/$label.png'),
        );
      }

      Future<void> pumpStore({
        required WidgetTester tester,
        required ThemeMode themeMode,
        required String label,
      }) async {
        setViewport(tester);
        await tester.pumpWidget(buildStoreFrame(_buildApp(
          themeMode: themeMode,
          controller: controller,
          settingsService: settingsService,
        )));
        await tester.pump();
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(StoreFrame),
          matchesGoldenFile('$_goldenDir/$deviceName/store/$label.png'),
        );
      }

      testWidgets('light', (tester) async {
        await pumpRaw(tester: tester, themeMode: ThemeMode.light, label: 'light');
      }, skip: _unstableGoldenTests.contains('$deviceName/light'), tags: _golden);

      testWidgets('dark', (tester) async {
        await pumpRaw(tester: tester, themeMode: ThemeMode.dark, label: 'dark');
      }, skip: _unstableGoldenTests.contains('$deviceName/dark'), tags: _golden);

      testWidgets('settings', (tester) async {
        setViewport(tester);

        await tester.pumpWidget(_buildApp(
          themeMode: ThemeMode.light,
          controller: controller,
          settingsService: settingsService,
        ));
        await tester.pump();
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.tune));
        await tester.pump();
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('$_goldenDir/$deviceName/raw/settings.png'),
        );
      }, tags: _golden);

      testWidgets('detail', (tester) async {
        setViewport(tester);

        await tester.pumpWidget(_buildApp(
          themeMode: ThemeMode.light,
          controller: controller,
          settingsService: settingsService,
        ));
        await tester.pump();
        await tester.pumpAndSettle();

        await tester.tap(find.text('Meeting Notes'));
        await tester.pump();
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('$_goldenDir/$deviceName/raw/detail.png'),
        );
      }, tags: _golden);

      testWidgets('detail_new', (tester) async {
        setViewport(tester);

        final note = Note(
          id: 'new',
          title: '',
          content: '',
          pinned: false,
          updatedAt: DateTime.now(),
        );

        final umami = UmamiService(
          websiteId: 'test',
          endpoint: 'https://test.com/api/send',
        );

        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider.value(value: ThemeProvider(settingsRepository: settingsService)),
              ChangeNotifierProvider.value(value: LocaleProvider(settingsRepository: settingsService)),
              Provider.value(value: umami),
            ],
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              localizationsDelegates: const [
                ...AppLocalizations.localizationsDelegates,
                FlutterQuillLocalizations.delegate,
              ],
              supportedLocales: AppLocalizations.supportedLocales,
              locale: const Locale('en'),
              theme: () {
                final base = AppTheme.light(
                  accentColorOptions.first,
                );
                return base.copyWith(
                  appBarTheme: base.appBarTheme.copyWith(
                    titleTextStyle: TextStyle(
                      fontFamily: 'Roboto',
                      color: const Color(0xFF333333),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  floatingActionButtonTheme:
                      const FloatingActionButtonThemeData(elevation: 0),
                );
              }(),
              home: NoteDetailPage(
                controller: controller,
                existing: note,
                showToolbar: false,
              ),
            ),
          ),
        );
        await tester.pump();
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('$_goldenDir/$deviceName/raw/detail_new.png'),
        );
      }, tags: _golden);

      testWidgets('store_light', (tester) async {
        await pumpStore(tester: tester, themeMode: ThemeMode.light, label: 'light');
      }, skip: _unstableGoldenTests.contains('$deviceName/store_light'), tags: _golden);

      testWidgets('store_dark', (tester) async {
        await pumpStore(tester: tester, themeMode: ThemeMode.dark, label: 'dark');
      }, skip: _unstableGoldenTests.contains('$deviceName/store_dark'), tags: _golden);

      testWidgets('store_settings', (tester) async {
        setViewport(tester);

        await tester.pumpWidget(buildStoreFrame(_buildApp(
          themeMode: ThemeMode.light,
          controller: controller,
          settingsService: settingsService,
        )));
        await tester.pump();
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.tune));
        await tester.pump();
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(StoreFrame),
          matchesGoldenFile('$_goldenDir/$deviceName/store/settings.png'),
        );
      }, tags: _golden);

      testWidgets('store_detail', (tester) async {
        setViewport(tester);

        await tester.pumpWidget(buildStoreFrame(_buildApp(
          themeMode: ThemeMode.light,
          controller: controller,
          settingsService: settingsService,
        )));
        await tester.pump();
        await tester.pumpAndSettle();

        await tester.tap(find.text('Meeting Notes'));
        await tester.pump();
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(StoreFrame),
          matchesGoldenFile('$_goldenDir/$deviceName/store/detail.png'),
        );
      }, tags: _golden);

      testWidgets('store_detail_new', (tester) async {
        setViewport(tester);

        final note = Note(
          id: 'new',
          title: '',
          content: '',
          pinned: false,
          updatedAt: DateTime.now(),
        );

        final umami = UmamiService(
          websiteId: 'test',
          endpoint: 'https://test.com/api/send',
        );

        await tester.pumpWidget(buildStoreFrame(
          MultiProvider(
            providers: [
              ChangeNotifierProvider.value(value: ThemeProvider(settingsRepository: settingsService)),
              ChangeNotifierProvider.value(value: LocaleProvider(settingsRepository: settingsService)),
              Provider.value(value: umami),
            ],
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              localizationsDelegates: const [
                ...AppLocalizations.localizationsDelegates,
                FlutterQuillLocalizations.delegate,
              ],
              supportedLocales: AppLocalizations.supportedLocales,
              locale: const Locale('en'),
              theme: () {
                final base = AppTheme.light(
                  accentColorOptions.first,
                );
                return base.copyWith(
                  appBarTheme: base.appBarTheme.copyWith(
                    titleTextStyle: TextStyle(
                      fontFamily: 'Roboto',
                      color: const Color(0xFF333333),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  floatingActionButtonTheme:
                      const FloatingActionButtonThemeData(elevation: 0),
                );
              }(),
              home: NoteDetailPage(
                controller: controller,
                existing: note,
                showToolbar: false,
              ),
            ),
          ),
        ));
        await tester.pump();
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(StoreFrame),
          matchesGoldenFile('$_goldenDir/$deviceName/store/detail_new.png'),
        );
      }, tags: _golden);
    });
  }
}
