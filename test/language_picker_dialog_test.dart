import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fox/widgets/language_picker_dialog.dart';

import 'test_helpers.dart';

Locale? _result;

Future<void> openPicker(
  WidgetTester tester, {
  String? currentTag,
}) async {
  _result = null;
  await tester.pumpWidget(
    buildTestApp(
      Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () async {
              _result = await showDialog<Locale>(
                context: context,
                builder: (_) => LanguagePickerDialog(
                  currentTag: currentTag,
                  systemDefaultLabel: 'System Default',
                  searchHintLabel: 'Search',
                ),
              );
            },
            child: const Text('open'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows the system default option first', (tester) async {
    await openPicker(tester);

    expect(find.byType(LanguagePickerDialog), findsOneWidget);
    expect(find.text('System Default'), findsOneWidget);
    expect(find.byType(ListTile), findsWidgets);
  });

  testWidgets('marks the current language as selected', (tester) async {
    await openPicker(tester, currentTag: 'fr');

    await tester.enterText(find.byType(TextField), 'fran');
    await tester.pump();

    final tiles = tester.widgetList<ListTile>(find.byType(ListTile));
    final selected = tiles.where(
      (tile) => (tile.leading! as Icon).icon == Icons.radio_button_checked,
    );
    expect(selected, hasLength(1));
    expect((selected.single.title! as Text).data, 'Français');
  });

  testWidgets('search filters the language list', (tester) async {
    await openPicker(tester);

    await tester.enterText(find.byType(TextField), 'deutsch');
    await tester.pump();

    expect(find.text('Deutsch'), findsOneWidget);
    expect(find.text('Français'), findsNothing);
    // The system default row hides once a filter is typed.
    expect(find.text('System Default'), findsNothing);
  });

  testWidgets('search matches a locale tag', (tester) async {
    await openPicker(tester);

    await tester.enterText(find.byType(TextField), 'pt_PT');
    await tester.pump();

    expect(find.text('Português (Portugal)'), findsOneWidget);
  });

  testWidgets('selecting a language returns its Locale', (tester) async {
    await openPicker(tester);

    await tester.enterText(find.byType(TextField), 'english');
    await tester.pump();
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();

    expect(_result, const Locale('en'));
    expect(find.byType(LanguagePickerDialog), findsNothing);
  });

  testWidgets('selecting the system default returns the sentinel', (
    tester,
  ) async {
    await openPicker(tester, currentTag: 'de');

    await tester.tap(find.text('System Default'));
    await tester.pumpAndSettle();

    expect(_result, LanguagePickerDialog.sentinelSystemDefault);
  });

  testWidgets('dismissing the dialog returns null', (tester) async {
    await openPicker(tester);

    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();

    expect(_result, isNull);
    expect(find.byType(LanguagePickerDialog), findsNothing);
  });
}
