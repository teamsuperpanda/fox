import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fox/l10n/app_localizations.dart';
import 'package:fox/services/note_links.dart';

import 'test_helpers.dart';

void main() {
  group('openNoteLink', () {
    testWidgets('web links open without a prompt', (tester) async {
      final launched = <Uri>[];
      await tester.pumpWidget(
        buildTestApp(
          Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => openNoteLink(
                  context: context,
                  rawUrl: 'https://example.com/notes',
                  launcher: (uri) async {
                    launched.add(uri);
                    return true;
                  },
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pump();

      expect(launched, hasLength(1));
      expect(launched.single.host, 'example.com');
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('non-web schemes ask for confirmation', (tester) async {
      final launched = <Uri>[];
      await tester.pumpWidget(
        buildTestApp(
          Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => openNoteLink(
                  context: context,
                  rawUrl: 'tel:12345',
                  launcher: (uri) async {
                    launched.add(uri);
                    return true;
                  },
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );
      final l10n = AppLocalizations.of(tester.element(find.text('open')));

      await tester.tap(find.text('open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text(l10n.openLinkConfirm('tel:12345')), findsOneWidget);
      expect(launched, isEmpty);

      await tester.tap(find.text(l10n.cancel));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(launched, isEmpty);

      await tester.tap(find.text('open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text(l10n.openLinkAction));
      await tester.pump();

      expect(launched, hasLength(1));
      expect(launched.single.scheme, 'tel');
    });

    testWidgets('rejects a value that is not a URL', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => openNoteLink(
                  context: context,
                  rawUrl: 'not a url',
                  launcher: (uri) async => true,
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );
      final l10n = AppLocalizations.of(tester.element(find.text('open')));

      await tester.tap(find.text('open'));
      await tester.pump();

      expect(find.text(l10n.invalidUrl), findsOneWidget);
    });
  });
}
