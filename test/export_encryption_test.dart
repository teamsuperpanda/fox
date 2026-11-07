import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fox/models/settings.dart';
import 'package:fox/services/export/export_codec.dart';
import 'package:fox/services/export/export_encryption.dart';
import 'package:fox/services/export/export_service.dart';

import 'test_helpers.dart';

void main() {
  group('ExportEncryption', () {
    // 1000 iterations keeps the tests quick; production uses 120000.
    final encryption = ExportEncryption(iterations: 1000);
    final plain = Uint8List.fromList(utf8.encode('fox-backup-payload'));

    test('round-trips with the same passphrase', () async {
      final encrypted = await encryption.encrypt(
        bytes: plain,
        passphrase: 'correct horse battery staple',
      );

      expect(encryption, isNotNull);
      expect(ExportEncryption.isEncrypted(encrypted), isTrue);
      expect(utf8.decode(encrypted), isNot(contains('fox-backup-payload')));

      final decrypted = await encryption.decrypt(
        bytes: encrypted,
        passphrase: 'correct horse battery staple',
      );
      expect(utf8.decode(decrypted), 'fox-backup-payload');
    });

    test('a wrong passphrase fails cleanly without output', () async {
      final encrypted = await encryption.encrypt(
        bytes: plain,
        passphrase: 'right passphrase',
      );

      await expectLater(
        encryption.decrypt(bytes: encrypted, passphrase: 'wrong passphrase'),
        throwsA(isA<ExportDecryptionException>()),
      );
    });

    test('a tampered file fails cleanly', () async {
      final encrypted = await encryption.encrypt(
        bytes: plain,
        passphrase: 'passphrase',
      );
      final json = jsonDecode(utf8.decode(encrypted)) as Map<String, dynamic>;
      final cipher = base64Decode(json['ciphertext'] as String);
      cipher[0] = cipher[0] ^ 0xFF;
      json['ciphertext'] = base64Encode(cipher);

      await expectLater(
        encryption.decrypt(
          bytes: Uint8List.fromList(utf8.encode(jsonEncode(json))),
          passphrase: 'passphrase',
        ),
        throwsA(isA<ExportDecryptionException>()),
      );
    });

    test('rejects a file that is not an encrypted export', () async {
      await expectLater(
        encryption.decrypt(
          bytes: Uint8List.fromList(utf8.encode('{"notes": []}')),
          passphrase: 'passphrase',
        ),
        throwsA(isA<ExportDecryptionException>()),
      );
      expect(
        ExportEncryption.isEncrypted(
          Uint8List.fromList(utf8.encode('plain text')),
        ),
        isFalse,
      );
    });

    test('uses a fresh salt and nonce for every export', () async {
      final first = await encryption.encrypt(bytes: plain, passphrase: 'same');
      final second = await encryption.encrypt(bytes: plain, passphrase: 'same');

      expect(utf8.decode(first), isNot(utf8.decode(second)));
    });
  });

  group('encrypted export', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('fox_encrypted_test');
    });

    tearDown(() async {
      if (tempDir.existsSync()) await tempDir.delete(recursive: true);
    });

    test('writes a .foxenc that only the passphrase reopens', () async {
      final result = await FoxExporter(
        clock: () => DateTime.utc(2026, 11, 7, 10, 30),
      ).export(
        notes: [
          makeNote(
            id: 'secret',
            title: 'Diary',
            content: r'[{"insert":"private\n"}]',
          ),
        ],
        folders: const [],
        settings: Settings(themeMode: 'system'),
        outputDirectory: tempDir,
        passphrase: 'open sesame',
        encryption: ExportEncryption(iterations: 1000),
      );

      expect(result.encrypted, isTrue);
      expect(result.archive.path, endsWith('.foxenc'));
      expect(result.archive.existsSync(), isTrue);
      expect(ExportEncryption.isEncrypted(result.bytes), isTrue);

      final decrypted = await ExportEncryption(iterations: 1000).decrypt(
        bytes: result.bytes,
        passphrase: 'open sesame',
      );
      final archive = ZipDecoder().decodeBytes(decrypted);
      final envelope = FoxExportArchive.decode(
        utf8.decode(archive.findFile(FoxExportArchive.jsonFileName)!.content),
      );
      expect(envelope.notes.single.title, 'Diary');

      await expectLater(
        ExportEncryption(iterations: 1000).decrypt(
          bytes: result.bytes,
          passphrase: 'not the passphrase',
        ),
        throwsA(isA<ExportDecryptionException>()),
      );
    });

    test('a plain export is not encrypted', () async {
      final result = await FoxExporter(
        clock: () => DateTime.utc(2026, 11, 7, 10, 30),
      ).export(
        notes: [makeNote(id: 'n', title: 'Plain')],
        folders: const [],
        settings: Settings(themeMode: 'system'),
        outputDirectory: tempDir,
      );

      expect(result.encrypted, isFalse);
      expect(result.archive.path, endsWith('.zip'));
      expect(ExportEncryption.isEncrypted(result.bytes), isFalse);
    });
  });
}
