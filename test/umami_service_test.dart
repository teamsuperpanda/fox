import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fox/services/umami_service.dart';
import 'package:http/http.dart' as http;

class MockClient implements http.Client {
  bool called = false;
  Map<String, dynamic>? lastPayload;

  @override
  Future<http.Response> post(Uri url,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
    called = true;
    if (body != null) {
      lastPayload = jsonDecode(body as String) as Map<String, dynamic>;
    }
    return http.Response('ok', 200);
  }

  @override
  void close() {}

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    throw UnimplementedError();
  }

  @override
  Future<http.Response> head(Uri url, {Map<String, String>? headers}) async {
    throw UnimplementedError();
  }

  @override
  Future<http.Response> get(Uri url, {Map<String, String>? headers}) async {
    throw UnimplementedError();
  }

  @override
  Future<http.Response> patch(Uri url,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
    throw UnimplementedError();
  }

  @override
  Future<http.Response> put(Uri url,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
    throw UnimplementedError();
  }

  @override
  Future<String> read(Uri url, {Map<String, String>? headers}) async {
    throw UnimplementedError();
  }

  @override
  Future<Uint8List> readBytes(Uri url, {Map<String, String>? headers}) async {
    throw UnimplementedError();
  }

  @override
  Future<http.Response> delete(Uri url,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
    throw UnimplementedError();
  }
}

void main() {
  group('UmamiService', () {
    test('track does not send when disabled', () {
      final client = MockClient();
      final service = UmamiService(
        websiteId: 'test-id',
        endpoint: 'https://example.com/api/send',
        client: client,
      );
      service.enabled = false;
      service.track('test_event');
      expect(client.called, isFalse);
    });

    test('track sends when enabled', () async {
      final client = MockClient();
      final service = UmamiService(
        websiteId: 'test-id',
        endpoint: 'https://example.com/api/send',
        client: client,
      );
      service.track('test_event');
      await Future.delayed(const Duration(milliseconds: 100));
      expect(client.called, isTrue);
    });

    test('track includes websiteId in payload', () async {
      final client = MockClient();
      final service = UmamiService(
        websiteId: 'test-id',
        endpoint: 'https://example.com/api/send',
        client: client,
      );
      service.track('test_event');
      await Future.delayed(const Duration(milliseconds: 100));
      expect(client.lastPayload, isNotNull);
      final payload = client.lastPayload;
      expect(payload, isNotNull);
      final payloadMap = payload!['payload'] as Map<String, dynamic>?;
      expect(payloadMap, isNotNull);
      expect(payloadMap!['website'], equals('test-id'));
    });

    test('dispose closes client without throwing', () {
      final client = MockClient();
      final service = UmamiService(
        websiteId: 'test-id',
        endpoint: 'https://example.com/api/send',
        client: client,
      );
      service.dispose();
    });
  });
}
