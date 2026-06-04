import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fox/home_page.dart';
import 'package:fox/l10n/app_localizations.dart';
import 'package:fox/models/note.dart';
import 'package:fox/models/settings.dart';
import 'package:fox/models/settings_adapter.dart';
import 'package:fox/note_detail_page.dart';
import 'package:fox/providers/locale_provider.dart';
import 'package:fox/providers/theme_provider.dart';
import 'package:fox/services/box_names.dart';
import 'package:fox/services/notes_controller.dart';
import 'package:fox/services/umami_service.dart';
import 'package:fox/theme/app_theme.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

import 'test_helpers.dart';

const _goldenDir = 'golden';
const _hiveDir = './test/hive_golden_screenshots';

final _devices = <String, Size>{
  'iphone_6.9': const Size(440, 956),
  'iphone_6.5': const Size(414, 896),
  'android': const Size(360, 640),
};

const _dpr = 3.0;

Widget _buildApp({
  required ThemeMode themeMode,
  required NotesController controller,
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: ThemeProvider()),
      ChangeNotifierProvider.value(value: LocaleProvider()),
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
      locale: const Locale('en'),
      themeMode: themeMode,
      theme: () {
        final base =
            AppTheme.light(accentColorOptions.first, useGoogleFonts: false);
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
            AppTheme.dark(accentColorOptions.first, useGoogleFonts: false);
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
      home: HomePage(controller: controller, useGoogleFonts: false),
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
  Hive.init(_hiveDir);
  Hive.registerAdapter(SettingsAdapter());

  for (final entry in _devices.entries) {
    final deviceName = entry.key;
    final logicalSize = entry.value;

    group(deviceName, () {
      late NotesController controller;

      setUpAll(() async {
        await Hive.openBox<Settings>(BoxNames.settings);
      });

      setUp(() async {
        controller = await _createControllerWithNotes();
      });

      Future<void> pumpGolden({
        required WidgetTester tester,
        required ThemeMode themeMode,
        required String label,
      }) async {
        tester.view.physicalSize = logicalSize * _dpr;
        tester.view.devicePixelRatio = _dpr;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(_buildApp(
          themeMode: themeMode,
          controller: controller,
        ));
        await tester.pump();
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('$_goldenDir/$deviceName/raw/$label.png'),
        );
      }

      testWidgets('light', (tester) async {
        await pumpGolden(
          tester: tester,
          themeMode: ThemeMode.light,
          label: 'light',
        );
      });

      testWidgets('dark', (tester) async {
        await pumpGolden(
          tester: tester,
          themeMode: ThemeMode.dark,
          label: 'dark',
        );
      });

      testWidgets('settings', (tester) async {
        tester.view.physicalSize = logicalSize * _dpr;
        tester.view.devicePixelRatio = _dpr;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(_buildApp(
          themeMode: ThemeMode.light,
          controller: controller,
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
      });

      if (deviceName == 'iphone_6.5') {
        testWidgets('detail', (tester) async {
          tester.view.physicalSize = logicalSize * _dpr;
          tester.view.devicePixelRatio = _dpr;
          addTearDown(() {
            tester.view.resetPhysicalSize();
            tester.view.resetDevicePixelRatio();
          });

          await tester.pumpWidget(_buildApp(
            themeMode: ThemeMode.light,
            controller: controller,
          ));
          await tester.pump();
          await tester.pumpAndSettle();

          await tester.tap(find.text('Meeting Notes'));
          await tester.pump();
          await tester.pumpAndSettle();

          await expectLater(
            find.byType(MaterialApp),
            matchesGoldenFile('$_goldenDir/iphone_6.5/raw/detail.png'),
          );
        });

        testWidgets('detail_new', (tester) async {
          tester.view.physicalSize = logicalSize * _dpr;
          tester.view.devicePixelRatio = _dpr;
          addTearDown(() {
            tester.view.resetPhysicalSize();
            tester.view.resetDevicePixelRatio();
          });

          final note = Note(
            id: 'new',
            title: '',
            content: '',
            pinned: false,
            updatedAt: DateTime.now(),
          );

          await tester.pumpWidget(
            MultiProvider(
              providers: [
                ChangeNotifierProvider.value(value: ThemeProvider()),
                ChangeNotifierProvider.value(value: LocaleProvider()),
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
                locale: const Locale('en'),
                theme: () {
                  final base = AppTheme.light(
                    accentColorOptions.first,
                    useGoogleFonts: false,
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
            matchesGoldenFile('$_goldenDir/iphone_6.5/raw/detail_new.png'),
          );
        });

        testWidgets('detail_half', (tester) async {
          tester.view.physicalSize = logicalSize * _dpr;
          tester.view.devicePixelRatio = _dpr;
          addTearDown(() {
            tester.view.resetPhysicalSize();
            tester.view.resetDevicePixelRatio();
          });

          final halfNote = Note(
            id: 'half',
            title: 'Project Ideas',
            content: Note.documentToContent(
              Document()
                ..insert(0, 'I think we should build a feature that auto-'),
            ),
            pinned: false,
            updatedAt: DateTime.now(),
            tags: ['ideas', 'dev'],
            folderId: null,
            color: null,
          );

          await tester.pumpWidget(
            MultiProvider(
              providers: [
                ChangeNotifierProvider.value(value: ThemeProvider()),
                ChangeNotifierProvider.value(value: LocaleProvider()),
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
                locale: const Locale('en'),
                theme: () {
                  final base = AppTheme.light(
                    accentColorOptions.first,
                    useGoogleFonts: false,
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
                  existing: halfNote,
                ),
              ),
            ),
          );
          await tester.pump();
          await tester.pumpAndSettle();

          await expectLater(
            find.byType(MaterialApp),
            matchesGoldenFile('$_goldenDir/iphone_6.5/raw/detail_half.png'),
          );
        });
      }
    });
  }
}
