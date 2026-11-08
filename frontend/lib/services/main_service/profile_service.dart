import 'package:frontend/services/api_service.dart';

class ProfileService {
  ProfileService({ApiService? api}) : _api = api ?? ApiService();

  final ApiService _api;

  Future<dynamic> updateProfile(Map<String, dynamic> data) async {
    return await _api.put('profile', 'me', data);
  }

  Future<dynamic> changePassword(Map<String, dynamic> data) async {
    return await _api.post('profile/change-password', data);
  }
}
