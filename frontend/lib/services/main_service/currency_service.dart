import 'package:frontend/services/api_service.dart';

class CurrencyService {
  final ApiService _api = ApiService();

  static const String endpoint = "currency";

  /// GET ALL Currency
  Future<dynamic> getCurrencies() async {
    return await _api.get(endpoint);
  }

  /// GET Get Currency
  Future<dynamic> getCurrencyById(int id) async {
    return await _api.getById(
      endpoint,
      id.toString(),
    );
  }

  /// Create Currency
  Future<dynamic> createCurrency(
    Map<String, dynamic> data,
  ) async {
    return await _api.post(
      endpoint,
      data,
    );
  }

  /// UPDATE Currency
  Future<dynamic> updateCurrency(
    int id,
    Map<String, dynamic> data,
  ) async {
    return await _api.put(
      endpoint,
      id.toString(),
      data,
    );
  }

  /// DELETE Currency
  Future<dynamic> deleteCurrency(int id) async {
    return await _api.delete(
      endpoint,
      id.toString(),
    );
  }
}