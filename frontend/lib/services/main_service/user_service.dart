import 'package:frontend/services/api_service.dart';

class UserService {
  final ApiService _api = ApiService();

  static const String endpoint = "/users";

  /// GET ALL USERS
  Future<dynamic> getUsers() async {
    return await _api.get(endpoint);
  }

  /// GET USER BY ID
  Future<dynamic> getUserById(int id) async {
    return await _api.getById(
      endpoint,
      id.toString(),
    );
  }

  /// CREATE USER
  Future<dynamic> createUser(
    Map<String, dynamic> data,
  ) async {
    return await _api.post(
      endpoint,
      data,
    );
  }

  /// UPDATE USER
  Future<dynamic> updateUser(
    int id,
    Map<String, dynamic> data,
  ) async {
    return await _api.put(
      endpoint,
      id.toString(),
      data,
    );
  }

  /// DELETE USER
  Future<dynamic> deleteUser(int id) async {
    return await _api.delete(
      endpoint,
      id.toString(),
    );
  }
}