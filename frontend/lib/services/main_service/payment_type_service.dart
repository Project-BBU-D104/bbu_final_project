import 'package:frontend/services/api_service.dart';

class PaymentTypeService {
  final ApiService _api = ApiService();

  static const String endpoint = "payment_types";

  /// GET ALL Payment Type
  Future<dynamic> getPaymentTypes() async {
    return await _api.get(endpoint);
  }

  /// GET Get Payment Type
  Future<dynamic> getPaymentTypeById(int id) async {
    return await _api.getById(
      endpoint,
      id.toString(),
    );
  }

  /// Create Payment Type
  Future<dynamic> createPaymentType(
    Map<String, dynamic> data,
  ) async {
    return await _api.post(
      endpoint,
      data,
    );
  }

  /// UPDATE Payment Type
  Future<dynamic> updatePaymentType(
    int id,
    Map<String, dynamic> data,
  ) async {
    return await _api.put(
      endpoint,
      id.toString(),
      data,
    );
  }

  /// DELETE Payment Type
  Future<dynamic> deletePaymentType(int id) async {
    return await _api.delete(
      endpoint,
      id.toString(),
    );
  }
}