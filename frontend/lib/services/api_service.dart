import 'dart:async';
import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/global.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

typedef UnauthorizedHandler = void Function();

/// Thrown when the server rejects an expired or invalid session.
class UnauthorizedException implements Exception {
  UnauthorizedException([
    this.message = 'Session expired. Please log in again.',
  ]);

  final String message;

  @override
  String toString() => message;
}

class ApiService {
  ApiService({
    http.Client? client,
    UnauthorizedHandler? onUnauthorized,
    String? baseUrl,
  }) : _client = client ?? _sharedClient,
       _onUnauthorized = onUnauthorized ?? _defaultUnauthorized,
       _baseUrl = baseUrl ?? dotenv.env['API_URL']!;

  static final http.Client _sharedClient = http.Client();

  final http.Client _client;
  final UnauthorizedHandler _onUnauthorized;
  final String _baseUrl;

  static bool _handlingUnauthorized = false;

  String get baseUrl => _baseUrl;

  Map<String, String> get headers {
    final loginData = storage.lastUserLoginRead;
    final token = loginData["token"];

    return {
      "Content-Type": "application/json",
      "Accept": "application/json",
      if (token != null && token.toString().isNotEmpty)
        "Authorization": "Bearer $token",
    };
  }

  /// GET ALL
  Future<dynamic> get(String endpoint) async {
    final response = await _client.get(
      _buildUri(endpoint, trailingSlash: !endpoint.contains('/')),
      headers: headers,
    );

    return _handleResponse(response, endpoint: endpoint);
  }

  /// GET BY ID
  Future<dynamic> getById(String endpoint, String id) async {
    final response = await _client.get(
      _buildUri("$endpoint/$id"),
      headers: headers,
    );

    return _handleResponse(response, endpoint: endpoint);
  }

  /// POST
  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    final response = await _client.post(
      _buildUri(endpoint, trailingSlash: true),
      headers: headers,
      body: jsonEncode(data),
    );

    return _handleResponse(response, endpoint: endpoint);
  }

  /// PUT
  Future<dynamic> put(
    String endpoint,
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await _client.put(
      _buildUri("$endpoint/$id"),
      headers: headers,
      body: jsonEncode(data),
    );

    return _handleResponse(response, endpoint: endpoint);
  }

  /// DELETE
  Future<dynamic> delete(String endpoint, String id) async {
    final response = await _client.delete(
      _buildUri("$endpoint/$id"),
      headers: headers,
    );

    return _handleResponse(response, endpoint: endpoint);
  }

  Uri _buildUri(String endpoint, {bool trailingSlash = false}) {
    final cleanBaseUrl = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final cleanEndpoint = endpoint.startsWith('/')
        ? endpoint.substring(1)
        : endpoint;
    final path = trailingSlash && !cleanEndpoint.endsWith('/')
        ? '$cleanEndpoint/'
        : cleanEndpoint;

    return Uri.parse('$cleanBaseUrl/$path');
  }

  dynamic _handleResponse(http.Response response, {required String endpoint}) {
    final dynamic body = response.body.isEmpty
        ? null
        : jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    // A failed login is expected to return 401; it must not redirect away
    // from the login screen. Every other 401 means the session has expired.
    if (response.statusCode == 401 && !endpoint.startsWith('auth/')) {
      _onUnauthorized();
      throw UnauthorizedException();
    }

    throw Exception(
      body is Map<String, dynamic>
          ? body["detail"] ?? "API Error (${response.statusCode})"
          : "API Error (${response.statusCode})",
    );
  }

  /// Clear the stale session and send the user back to login.
  static void _defaultUnauthorized() {
    if (_handlingUnauthorized) return;
    _handlingUnauthorized = true;

    unawaited(storage.lastUserLoginRemove());

    if (Get.currentRoute != AppRoutes.login) {
      Get.offAllNamed(AppRoutes.login);
    }

    Future<void>.delayed(const Duration(seconds: 2), () {
      _handlingUnauthorized = false;
    });
  }
}
