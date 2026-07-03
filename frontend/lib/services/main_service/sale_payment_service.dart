import 'package:frontend/services/api_service.dart';

class UserService {
  final ApiService _api = ApiService();

  static const String endpoint = "/sale_payments";

  /// GET ALL SALE PAYMENT
  Future<dynamic> getPayments() async {
    return await _api.get(endpoint);
  }

  /// GET Get Sale Payment
  Future<dynamic> getSalePaymentById(int id) async {
    return await _api.getById(
      endpoint,
      id.toString(),
    );
  }

  /// Create Sale Payment
  Future<dynamic> createSalePayment(
    Map<String, dynamic> data,
  ) async {
    return await _api.post(
      endpoint,
      data,
    );
  }

  /// UPDATE Sale Payment
  Future<dynamic> updateSalePayment(
    int id,
    Map<String, dynamic> data,
  ) async {
    return await _api.put(
      endpoint,
      id.toString(),
      data,
    );
  }

  /// DELETE Sale Payment
  Future<dynamic> deleteSalePayment(int id) async {
    return await _api.delete(
      endpoint,
      id.toString(),
    );
  }
}