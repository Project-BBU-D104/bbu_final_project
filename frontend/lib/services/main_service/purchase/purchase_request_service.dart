import 'package:frontend/services/api_service.dart';

class PurchaseRequestService {
  final ApiService _api = ApiService();

  static const String endpoint = "purchase_request";
  static const String itemEndpoint = "purchase_request_items";

  /// GET ALL Purchase Request
  Future<dynamic> getPurchaseRequests() async {
    return await _api.get(endpoint);
  }

  /// GET Purchase Request BY ID
  Future<dynamic> getPurchaseRequestById(int id) async {
    return await _api.getById(endpoint, id.toString());
  }

  /// CREATE Purchase Request
  Future<dynamic> createPurchaseRequest(Map<String, dynamic> data) async {
    return await _api.post(endpoint, data);
  }

  /// UPDATE Purchase Request
  Future<dynamic> updatePurchaseRequest(
    int id,
    Map<String, dynamic> data,
  ) async {
    return await _api.put(endpoint, id.toString(), data);
  }

  /// DELETE Purchase Request
  Future<dynamic> deletePurchaseRequest(int id) async {
    return await _api.delete(endpoint, id.toString());
  }

  Future<dynamic> getPurchaseRequestItems() async {
    return await _api.get(itemEndpoint);
  }

  Future<dynamic> createPurchaseRequestItem(Map<String, dynamic> data) async {
    return await _api.post(itemEndpoint, data);
  }

  Future<dynamic> updatePurchaseRequestItem(
    int id,
    Map<String, dynamic> data,
  ) async {
    return await _api.put(itemEndpoint, id.toString(), data);
  }

  Future<dynamic> deletePurchaseRequestItem(int id) async {
    return await _api.delete(itemEndpoint, id.toString());
  }
}
