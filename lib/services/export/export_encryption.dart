import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

/// Thrown when an encrypted export cannot be opened with the given passphrase.
class ExportDecryptionException implements Exception {
  const ExportDecryptionException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Passphrase based container for export files.
///
/// Format: a single JSON object with
/// `format: fox-export-encrypted`, `version`, `kdf` (PBKDF2-HMAC-SHA256),
/// `iterations`, base64 `salt`, `cipher` (AES-256-GCM), base64 `nonce`,
/// base64 `mac` and base64 `ciphertext`.
///
/// The passphrase is never stored anywhere. There is no recovery: a lost
/// passphrase means a lost backup.
class ExportEncryption {
  ExportEncryption({this.iterations = 120000, Random? random})
      : _random = random ?? Random.secure();

  static const String formatId = 'fox-export-encrypted';
  static const int formatVersion = 1;
  static const String fileExtension = 'foxenc';

  /// PBKDF2 work factor. High enough to slow guessing, low enough to unlock
  /// a backup on a phone in about a second.
  final int iterations;
  final Random _random;

  Future<Uint8List> encrypt({
    required List<int> bytes,
    required String passphrase,
  }) async {
    if (passphrase.isEmpty) {
      throw ArgumentError.value(passphrase, 'passphrase', 'must not be empty');
    }
    final salt = _randomBytes(16);
    final nonce = _randomBytes(12);
    final key = await _deriveKey(passphrase, salt);

    final box = await AesGcm.with256bits().encrypt(
      bytes,
      secretKey: key,
      nonce: nonce,
    );

    final payload = {
      'format': formatId,
      'version': formatVersion,
      'kdf': 'pbkdf2-hmac-sha256',
      'iterations': iterations,
      'salt': base64Encode(salt),
      'cipher': 'aes-256-gcm',
      'nonce': base64Encode(box.nonce),
      'mac': base64Encode(box.mac.bytes),
      'ciphertext': base64Encode(box.cipherText),
    };
    return Uint8List.fromList(utf8.encode(jsonEncode(payload)));
  }

  Future<Uint8List> decrypt({
    required List<int> bytes,
    required String passphrase,
  }) async {
    final header = _parseHeader(bytes);
    final salt = _decode(header, 'salt');
    final nonce = _decode(header, 'nonce');
    final mac = _decode(header, 'mac');
    final cipherText = _decode(header, 'ciphertext');
    final key = await _deriveKey(passphrase, salt);

    try {
      final clear = await AesGcm.with256bits().decrypt(
        SecretBox(cipherText, nonce: nonce, mac: Mac(mac)),
        secretKey: key,
      );
      return Uint8List.fromList(clear);
    } on SecretBoxAuthenticationError {
      throw const ExportDecryptionException(
        'Wrong passphrase, or the file has been damaged.',
      );
    }
  }

  /// True when [bytes] look like this package's encrypted container.
  static bool isEncrypted(List<int> bytes) {
    final head = utf8.decode(
      bytes.take(64).toList(growable: false),
      allowMalformed: true,
    );
    return head.contains(formatId);
  }

  List<int> _randomBytes(int length) =>
      List<int>.generate(length, (_) => _random.nextInt(256));

  Future<SecretKey> _deriveKey(String passphrase, List<int> salt) {
    return Pbkdf2.hmacSha256(iterations: iterations, bits: 256).deriveKey(
      secretKey: SecretKey(utf8.encode(passphrase)),
      nonce: salt,
    );
  }

  Map<String, dynamic> _parseHeader(List<int> bytes) {
    Object? decoded;
    try {
      decoded = jsonDecode(utf8.decode(bytes));
    } on FormatException {
      throw const ExportDecryptionException(
        'This is not an encrypted Fox export.',
      );
    }
    if (decoded is! Map<String, dynamic> ||
        decoded['format'] != formatId ||
        decoded['version'] != formatVersion) {
      throw const ExportDecryptionException(
        'This is not an encrypted Fox export.',
      );
    }
    final iterations = decoded['iterations'];
    if (iterations is! int || iterations < 1) {
      throw const ExportDecryptionException(
        'The encrypted export has an invalid key derivation header.',
      );
    }
    return decoded;
  }

  static List<int> _decode(Map<String, dynamic> header, String key) {
    final value = header[key];
    if (value is! String) {
      throw const ExportDecryptionException(
        'The encrypted export is missing data and cannot be opened.',
      );
    }
    try {
      return base64Decode(value);
    } on FormatException {
      throw const ExportDecryptionException(
        'The encrypted export is damaged and cannot be opened.',
      );
    }
  }
}
