import 'package:frontend/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  AuthService({ApiService? api}) : _api = api ?? ApiService();

  final ApiService _api;

  Future<Map<String, dynamic>> login({
    required String name,
    required String password,
  }) async {
    final response = await _api
        .post("auth/login", {"name": name, "password": password})
        .timeout(const Duration(seconds: 30));

    final data = Map<String, dynamic>.from(response);

    if (data['access_token'] is! String ||
        (data['access_token'] as String).isEmpty) {
      throw const FormatException('Missing access token');
    }
    final prefs = await SharedPreferences.getInstance();
    if (!await prefs.setString('token', data['access_token'])) {
      throw StateError('Unable to persist session');
    }

    return data;
  }
}
