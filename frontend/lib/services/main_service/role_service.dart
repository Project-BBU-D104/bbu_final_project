import 'package:frontend/services/api_service.dart';

class RoleService {
  final ApiService _api = ApiService();

  static const String endpoint = "role/";

  /// GET ALL Role
  Future<dynamic> getRoles() async {
    return await _api.get(endpoint);
  }

  /// GET Get Role
  Future<dynamic> getRoleById(int id) async {
    return await _api.getById(
      endpoint,
      id.toString(),
    );
  }

  /// Create Role
  Future<dynamic> createRole(
    Map<String, dynamic> data,
  ) async {
    return await _api.post(
      endpoint,
      data,
    );
  }

  /// UPDATE Role
  Future<dynamic> updateRole(
    int id,
    Map<String, dynamic> data,
  ) async {
    return await _api.put(
      endpoint,
      id.toString(),
      data,
    );
  }

  /// DELETE Role
  Future<dynamic> deleteRole(int id) async {
    return await _api.delete(
      endpoint,
      id.toString(),
    );
  }
}