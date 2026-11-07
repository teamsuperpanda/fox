import 'package:flutter_test/flutter_test.dart';

import '../tool/release_notes.dart';

void main() {
  group('release tag validation', () {
    test('accepts a matching semver tag', () {
      expect(
        () => validateTag('v2.1.1', (version: '2.1.1', build: 20)),
        returnsNormally,
      );
    });

    test('rejects a build-number tag', () {
      expect(
        () => validateTag('v2.1.1+20', (version: '2.1.1', build: 20)),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects a non-v tag', () {
      expect(
        () => validateTag('2.1.1', (version: '2.1.1', build: 20)),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects a tag that disagrees with pubspec', () {
      expect(
        () => validateTag('v2.1.0', (version: '2.1.1', build: 20)),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('pubspec version parsing', () {
    test('reads version and build number', () {
      final parsed = parsePubspecVersion('name: fox\nversion: 2.1.1+20\n');
      expect(parsed.version, '2.1.1');
      expect(parsed.build, 20);
    });

    test('requires a build number', () {
      expect(
        () => parsePubspecVersion('version: 2.1.1'),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('release notes', () {
    test('loads locales and rejects notes longer than the Play limit', () {
      expect(
        loadReleaseNotes('[{"language":"en-US","text":"Hello"}]'),
        {'en-US': 'Hello'},
      );
      expect(
        () => loadReleaseNotes(
          '[{"language":"en-US","text":"${'x' * 501}"}]',
        ),
        throwsA(isA<FormatException>()),
      );
    });

    test('maps release-note locales to iOS metadata folders', () {
      expect(iosLocaleFor('ar'), 'ar-SA');
      expect(iosLocaleFor('id'), 'id-ID');
      expect(iosLocaleFor('vi'), 'vi-VN');
      expect(iosLocaleFor('en-US'), 'en-US');
      expect(iosLocaleFor('pt-BR'), 'pt-BR');
    });
  });
}
