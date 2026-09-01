import 'package:frontend/services/api_service.dart';

class SystemConfigurationService {
  final ApiService _api = ApiService();

  static const String endpoint = "system_configuration";

  /// GET ALL System Configurations
  Future<dynamic> getSystemConfigurations() async {
    return await _api.get(endpoint);
  }

  /// GET System Configuration BY ID
  Future<dynamic> getSystemConfigurationById(int id) async {
    return await _api.getById(
      endpoint,
      id.toString(),
    );
  }

  /// CREATE System Configuration
  Future<dynamic> createSystemConfiguration(
    Map<String, dynamic> data,
  ) async {
    return await _api.post(
      endpoint,
      data,
    );
  }

  /// UPDATE System Configuration
  Future<dynamic> updateSystemConfiguration(
    int id,
    Map<String, dynamic> data,
  ) async {
    return await _api.put(
      endpoint,
      id.toString(),
      data,
    );
  }

  /// DELETE System Configuration
  Future<dynamic> deleteSystemConfiguration(int id) async {
    return await _api.delete(
      endpoint,
      id.toString(),
    );
  }
}