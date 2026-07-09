import 'package:frontend/services/api_service.dart';

class AuthService {
  final ApiService _api = ApiService();

  Future<Map<String, dynamic>> login({
    required String name,
    required String password,
  }) async {
    final response = await _api.post(
      "auth/login",
      {
        "name": name,
        "password": password,
      },
      
    );

    return Map<String, dynamic>.from(response);
  }
}