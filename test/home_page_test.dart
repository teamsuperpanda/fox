import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fox/home_page.dart';
import 'package:fox/note_detail_page.dart';
import 'package:fox/providers/locale_provider.dart';
import 'package:fox/providers/theme_provider.dart';
import 'package:fox/services/notes_controller.dart';
import 'package:fox/services/umami_service.dart';
import 'package:provider/provider.dart';

import 'test_helpers.dart';

Widget _buildHome({required NotesController controller}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: ThemeProvider()),
      ChangeNotifierProvider.value(value: LocaleProvider()),
      Provider.value(value: UmamiService(websiteId: 'test', endpoint: 'https://test.com/api/send')),
    ],
    child: HomePage(controller: controller),
  );
}

void main() {
  group('HomePage', () {
    late MockRepository mockRepo;
    late NotesController controller;

    setUp(() {
      mockRepo = MockRepository();
      controller = NotesController(mockRepo);
    });

    testWidgets('shows empty state when no notes exist', (tester) async {
      await tester.pumpWidget(buildTestApp(home: _buildHome(controller: controller)));
      await tester.pump();
      expect(find.text('No notes yet...'), findsOneWidget);
    });

    testWidgets('shows note in list when note exists', (tester) async {
      await controller.load();
      await controller.addOrUpdate(title: 'Test Note', content: Document());

      await tester.pumpWidget(buildTestApp(home: _buildHome(controller: controller)));
      await tester.pump();
      expect(find.text('Test Note'), findsOneWidget);
    });

    testWidgets('FAB opens note detail page', (tester) async {
      await tester.pumpWidget(buildTestApp(home: _buildHome(controller: controller)));
      await tester.pump();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(NoteDetailPage), findsOneWidget);
    });

    testWidgets('Search icon toggles search bar when notes exist', (tester) async {
      await controller.load();
      await controller.addOrUpdate(title: 'Test', content: Document());

      await tester.pumpWidget(buildTestApp(home: _buildHome(controller: controller)));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.search));
      await tester.pump();

      expect(find.byType(TextField), findsWidgets);
    });

    testWidgets('Folder icon opens folders dialog', (tester) async {
      await tester.pumpWidget(buildTestApp(home: _buildHome(controller: controller)));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.folder_outlined));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Folders'), findsOneWidget);
    });

    testWidgets('Tune icon is present on home page', (tester) async {
      await tester.pumpWidget(buildTestApp(home: _buildHome(controller: controller)));
      await tester.pump();

      expect(find.byIcon(Icons.tune), findsOneWidget);
    });
  });
}
