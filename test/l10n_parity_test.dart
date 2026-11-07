import 'package:flutter_test/flutter_test.dart';

import '../tool/check_l10n.dart';

void main() {
  test('every ARB matches app_en.arb and every locale has a display name', () {
    // `dart run tool/check_l10n.dart` runs the same check in CI; this keeps it
    // in the local `flutter test` gate too.
    expect(l10nProblems(), isEmpty);
  });
}
