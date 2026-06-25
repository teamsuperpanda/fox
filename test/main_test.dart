import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fox/providers/locale_provider.dart';
import 'package:fox/providers/theme_provider.dart';
import 'package:provider/provider.dart';

Widget _buildTestApp({required Widget home}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: ThemeProvider()),
      ChangeNotifierProvider.value(value: LocaleProvider()),
    ],
    child: MaterialApp(home: home),
  );
}

void main() {
  group('Provider wiring (not main())', () {
    testWidgets('providers are wired correctly', (tester) async {
      await tester.pumpWidget(_buildTestApp(
        home: Builder(
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
