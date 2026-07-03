import 'package:frontend/services/api_service.dart';

class UserService {
  final ApiService _api = ApiService();

  static const String endpoint = "/warehouses";

  /// GET ALL Warehouse
  Future<dynamic> getWarehouses() async {
    return await _api.get(endpoint);
  }

  /// GET Get Warehouse
  Future<dynamic> getWarehouseById(int id) async {
    return await _api.getById(
      endpoint,
      id.toString(),
    );
  }

  /// Create Warehouse
  Future<dynamic> createWarehouse(
    Map<String, dynamic> data,
  ) async {
    return await _api.post(
      endpoint,
      data,
    );
  }

  /// UPDATE Warehouse
  Future<dynamic> updateWarehouse(
    int id,
    Map<String, dynamic> data,
  ) async {
    return await _api.put(
      endpoint,
      id.toString(),
      data,
    );
  }

  /// DELETE Warehouse
  Future<dynamic> deleteWarehouse(int id) async {
    return await _api.delete(
      endpoint,
      id.toString(),
    );
  }
}