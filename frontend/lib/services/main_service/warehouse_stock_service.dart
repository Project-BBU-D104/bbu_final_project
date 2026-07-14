import 'package:frontend/services/api_service.dart';

class WarehouseStockService {
  final ApiService _api = ApiService();

  static const String endpoint = "warehouse_stock";

  /// GET ALL Warehouse Stock
  Future<dynamic> getWarehouseStock() async {
    return await _api.get(endpoint);
  }

  /// GET Get Warehouse Stock
  Future<dynamic> getWarehouseStockById(int id) async {
    return await _api.getById(
      endpoint,
      id.toString(),
    );
  }

  /// Create Warehouse Stock
  Future<dynamic> createWarehouseStock(
    Map<String, dynamic> data,
  ) async {
    return await _api.post(
      endpoint,
      data,
    );
  }

  /// UPDATE Warehouse Stock
  Future<dynamic> updateWarehouseStock(
    int id,
    Map<String, dynamic> data,
  ) async {
    return await _api.put(
      endpoint,
      id.toString(),
      data,
    );
  }

  /// DELETE Warehouse Stock
  Future<dynamic> deleteWarehouseStock(int id) async {
    return await _api.delete(
      endpoint,
      id.toString(),
    );
  }
}