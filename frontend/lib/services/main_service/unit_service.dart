import 'package:frontend/services/api_service.dart';

class UnitService {
  final ApiService _api = ApiService();

  static const String endpoint = "unit";

  /// GET ALL Unit
  Future<dynamic> getUnits() async {
    return await _api.get(endpoint);
  }

  /// GET Get Unit
  Future<dynamic> getUnitById(int id) async {
    return await _api.getById(
      endpoint,
      id.toString(),
    );
  }

  /// Create Unit
  Future<dynamic> createUnit(
    Map<String, dynamic> data,
  ) async {
    return await _api.post(
      endpoint,
      data,
    );
  }

  /// UPDATE Unit
  Future<dynamic> updateUnit(
    int id,
    Map<String, dynamic> data,
  ) async {
    return await _api.put(
      endpoint,
      id.toString(),
      data,
    );
  }

  /// DELETE Unit
  Future<dynamic> deleteUnit(int id) async {
    return await _api.delete(
      endpoint,
      id.toString(),
    );
  }
}