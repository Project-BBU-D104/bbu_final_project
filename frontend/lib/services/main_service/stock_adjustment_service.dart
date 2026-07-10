import 'package:frontend/services/api_service.dart';

class StockAdjustmentService {
  final ApiService _api = ApiService();

  static const String endpoint = "stock_adjustment";

  /// GET ALL Stock Adjustment
  Future<dynamic> getStockAdjustments() async {
    return await _api.get(endpoint);
  }

  /// GET Get Stock Adjustment
  Future<dynamic> getStockAdjustmentById(int id) async {
    return await _api.getById(
      endpoint,
      id.toString(),
    );
  }

  /// Create Stock Adjustment
  Future<dynamic> createStockAdjustment(
    Map<String, dynamic> data,
  ) async {
    return await _api.post(
      endpoint,
      data,
    );
  }

  /// UPDATE Stock Adjustment
  Future<dynamic> updateStockAdjustment(
    int id,
    Map<String, dynamic> data,
  ) async {
    return await _api.put(
      endpoint,
      id.toString(),
      data,
    );
  }

  /// DELETE Stock Adjustment
  Future<dynamic> deleteStockAdjustment(int id) async {
    return await _api.delete(
      endpoint,
      id.toString(),
    );
  }
}