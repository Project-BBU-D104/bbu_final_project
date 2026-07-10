import 'package:frontend/services/api_service.dart';

class SaleService {
  final ApiService _api = ApiService();

  static const String endpoint = "sale";

  /// GET ALL Sale
  Future<dynamic> getSales() async {
    return await _api.get(endpoint);
  }

  /// GET Get Sale
  Future<dynamic> getSaleById(int id) async {
    return await _api.getById(
      endpoint,
      id.toString(),
    );
  }

  /// Create Sale
  Future<dynamic> createSale(
    Map<String, dynamic> data,
  ) async {
    return await _api.post(
      endpoint,
      data,
    );
  }

  /// UPDATE Sale
  Future<dynamic> updateSale(
    int id,
    Map<String, dynamic> data,
  ) async {
    return await _api.put(
      endpoint,
      id.toString(),
      data,
    );
  }

  /// DELETE Sale
  Future<dynamic> deleteSale(int id) async {
    return await _api.delete(
      endpoint,
      id.toString(),
    );
  }
}