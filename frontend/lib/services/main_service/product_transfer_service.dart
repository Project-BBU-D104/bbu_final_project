import 'package:frontend/services/api_service.dart';

class ProductTransferService {
  final ApiService _api = ApiService();

  static const String endpoint = "product_transfer";

  /// GET ALL product transfer
  Future<dynamic> getProductTransfers() async {
    return await _api.get(endpoint);
  }

  /// GET product transfer BY ID
  Future<dynamic> getProductTransferById(int id) async {
    return await _api.getById(
      endpoint,
      id.toString(),
    );
  }

  /// CREATE product transfer
  Future<dynamic> createProductTransfer(
    Map<String, dynamic> data,
  ) async {
    return await _api.post(
      endpoint,
      data,
    );
  }

  /// UPDATE product transfer
  Future<dynamic> updateProductTransfer(
    int id,
    Map<String, dynamic> data,
  ) async {
    return await _api.put(
      endpoint,
      id.toString(),
      data,
    );
  }

  /// DELETE product transfer
  Future<dynamic> deleteProductTransfer(int id) async {
    return await _api.delete(
      endpoint,
      id.toString(),
    );
  }
}