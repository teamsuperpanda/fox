import 'package:flutter_test/flutter_test.dart';
import 'package:fox/main.dart' as app;
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Smoke Test', () {
    testWidgets('app launches without error', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      expect(find.text('Fox'), findsWidgets);
    });
  });
}
