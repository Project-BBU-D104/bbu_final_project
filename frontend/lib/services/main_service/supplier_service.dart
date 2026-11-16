import 'package:frontend/services/api_service.dart';

class SupplierService {
  final ApiService _api = ApiService();

  static const String endpoint = "supplier";

  /// GET ALL Supplier
  Future<dynamic> getSuppliers() async {
    // The controller caches suppliers. Revalidate HTTP reads so a browser's
    // cached list cannot overwrite a status returned by a successful update.
    return await _api.get(endpoint, forceRefresh: true);
  }

  /// GET Get Supplier
  Future<dynamic> getSupplierById(int id) async {
    return await _api.getById(endpoint, id.toString(), forceRefresh: true);
  }

  /// Create Supplier
  Future<dynamic> createSupplier(Map<String, dynamic> data) async {
    return await _api.post(endpoint, data);
  }

  /// UPDATE Supplier
  Future<dynamic> updateSupplier(int id, Map<String, dynamic> data) async {
    return await _api.put(endpoint, id.toString(), data);
  }

  /// DELETE Supplier
  Future<dynamic> deleteSupplier(int id) async {
    return await _api.delete(endpoint, id.toString());
  }
}
