import 'package:frontend/services/api_service.dart';

class PurchaseRequestService {
  final ApiService _api = ApiService();

  static const String endpoint = "purchase_request";

  /// GET ALL Purchase Request
  Future<dynamic> getPurchaseRequests() async {
    return await _api.get(endpoint);
  }

  /// GET Purchase Request BY ID
  Future<dynamic> getPurchaseRequestById(int id) async {
    return await _api.getById(
      endpoint,
      id.toString(),
    );
  }

  /// CREATE Purchase Request
  Future<dynamic> createPurchaseRequest(
    Map<String, dynamic> data,
  ) async {
    return await _api.post(
      endpoint,
      data,
    );
  }

  /// UPDATE Purchase Request
  Future<dynamic> updatePurchaseRequest(
    int id,
    Map<String, dynamic> data,
  ) async {
    return await _api.put(
      endpoint,
      id.toString(),
      data,
    );
  }

  /// DELETE Purchase Request
  Future<dynamic> deletePurchaseRequest(int id) async {
    return await _api.delete(
      endpoint,
      id.toString(),
    );
  }
}