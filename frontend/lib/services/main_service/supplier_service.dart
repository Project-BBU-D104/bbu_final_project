import 'package:frontend/services/api_service.dart';

class UserService {
  final ApiService _api = ApiService();

  static const String endpoint = "/suppliers";

  /// GET ALL Supplier
  Future<dynamic> getSuppliers() async {
    return await _api.get(endpoint);
  }

  /// GET Get Supplier
  Future<dynamic> getSupplierById(int id) async {
    return await _api.getById(
      endpoint,
      id.toString(),
    );
  }

  /// Create Supplier
  Future<dynamic> createSupplier(
    Map<String, dynamic> data,
  ) async {
    return await _api.post(
      endpoint,
      data,
    );
  }

  /// UPDATE Supplier
  Future<dynamic> updateSupplier(
    int id,
    Map<String, dynamic> data,
  ) async {
    return await _api.put(
      endpoint,
      id.toString(),
      data,
    );
  }

  /// DELETE Supplier
  Future<dynamic> deleteSupplier(int id) async {
    return await _api.delete(
      endpoint,
      id.toString(),
    );
  }
}