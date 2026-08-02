import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fox/providers/locale_provider.dart';
import 'package:fox/providers/theme_provider.dart';
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
}
