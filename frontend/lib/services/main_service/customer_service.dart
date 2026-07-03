import 'package:frontend/services/api_service.dart';

class UserService {
  final ApiService _api = ApiService();

  static const String endpoint = "/customers";

  /// GET ALL Customer
  Future<dynamic> getCustomers() async {
    return await _api.get(endpoint);
  }

  /// GET Customer BY ID
  Future<dynamic> getCustomerById(int id) async {
    return await _api.getById(
      endpoint,
      id.toString(),
    );
  }

  /// CREATE Customer
  Future<dynamic> createCustomer(
    Map<String, dynamic> data,
  ) async {
    return await _api.post(
      endpoint,
      data,
    );
  }

  /// UPDATE Customer
  Future<dynamic> updateCustomer(
    int id,
    Map<String, dynamic> data,
  ) async {
    return await _api.put(
      endpoint,
      id.toString(),
      data,
    );
  }

  /// DELETE Customer
  Future<dynamic> deleteCustomer(int id) async {
    return await _api.delete(
      endpoint,
      id.toString(),
    );
  }
}