import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UmamiService extends NavigatorObserver {
  UmamiService({
    required this.websiteId,
    required this.endpoint,
    http.Client? client,
  }) : _client = client ?? http.Client();

  final String websiteId;
  final String endpoint;
  final http.Client _client;
  bool enabled = false;

  void track(String event, {Map<String, dynamic>? data}) {
    if (!enabled) return;
    _send('event', {
      'event_name': event,
      if (data != null) ...data,
    });
  }

  void trackPageView(String url) {
    if (!enabled) return;
    _send('event', {'url': url, 'event_name': 'pageview'});
  }

  void _send(String type, Map<String, dynamic> payload) {
    try {
      unawaited(_client
          .post(
            Uri.parse(endpoint),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'type': type,
              'payload': {
                'website': websiteId,
                ...payload,
              },
            }),
          )
          .timeout(const Duration(seconds: 10))
          .then((_) => null)
          .catchError((Object e) {
            debugPrint('UmamiService: send failed: $e');
            return null;
          }));
    } catch (e) {
      debugPrint('UmamiService: send failed (outer): $e');
    }
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    if (!enabled) return;
    final name = route.settings.name;
    if (name != null) {
      trackPageView(name);
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (!enabled) return;
    final name = route.settings.name;
    if (name != null) {
      trackPageView('${name}_pop');
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (!enabled || newRoute == null) return;
    final name = newRoute.settings.name;
    if (name != null) {
      trackPageView('${name}_replace');
    }
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    if (!enabled) return;
    final name = route.settings.name;
    if (name != null) {
      trackPageView('${name}_remove');
    }
  }

  void dispose() {
    _client.close();
  }
}
