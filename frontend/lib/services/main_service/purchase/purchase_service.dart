import 'package:frontend/services/api_service.dart';

class PurchaseService {
  final ApiService _api = ApiService();

  static const String endpoint = "purchase";

  /// GET ALL Purchase
  Future<dynamic> getPurchases() async {
    return await _api.get(endpoint);
  }

  /// GET getPurchaseById
  Future<dynamic> getPurchaseById(int id) async {
    return await _api.getById(
      endpoint,
      id.toString(),
    );
  }

  /// Create Purchase
  Future<dynamic> createPurchase(
    Map<String, dynamic> data,
  ) async {
    return await _api.post(
      endpoint,
      data,
    );
  }

  /// GET Recent Purchases
  Future<dynamic> getRecentPurchases() async {
    return await _api.get(
      "$endpoint/recent",
    );
  }

  /// UPDATE Purchase
  Future<dynamic> updatePurchase(
    int id,
    Map<String, dynamic> data,
  ) async {
    return await _api.put(
      endpoint,
      id.toString(),
      data,
    );
  }

  /// DELETE Purchase
  Future<dynamic> deletePurchase(int id) async {
    return await _api.delete(
      endpoint,
      id.toString(),
    );
  }
}