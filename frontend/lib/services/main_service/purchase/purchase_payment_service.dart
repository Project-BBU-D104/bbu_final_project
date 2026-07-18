import 'package:frontend/services/api_service.dart';

class PurchasePaymentService {
  final ApiService _api = ApiService();

  static const String endpoint = "purchase_payment";

  /// GET ALL Purchase Payment
  Future<dynamic> getPurchasePayments() async {
    return await _api.get(endpoint);
  }

  /// GET Purchase Payment BY ID
  Future<dynamic> getPurchasePaymentById(int id) async {
    return await _api.getById(
      endpoint,
      id.toString(),
    );
  }

  /// CREATE Purchase Payment
  Future<dynamic> createPurchasePayment(
    Map<String, dynamic> data,
  ) async {
    return await _api.post(
      endpoint,
      data,
    );
  }

  /// UPDATE Purchase Payment
  Future<dynamic> updatePurchasePayment(
    int id,
    Map<String, dynamic> data,
  ) async {
    return await _api.put(
      endpoint,
      id.toString(),
      data,
    );
  }

  /// DELETE Purchase Payment
  Future<dynamic> deletePurchasePayment(int id) async {
    return await _api.delete(
      endpoint,
      id.toString(),
    );
  }
}