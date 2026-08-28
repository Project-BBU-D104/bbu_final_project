import 'package:frontend/services/api_service.dart';

class HomeService {
  final ApiService _api = ApiService();

  // recent Purchases
  static const String endpoint = "api/recent-purchases";

  // recent Sale
  static const String recentSalesEndpoint = "api/recent-sales";

  /// GET ALL Recent Purchases
  Future<dynamic> getRecentPrucases() async {
    return await _api.get(endpoint);
  }

  /// GET ALL Recent Sale
  Future<dynamic> getRecentSales() async {
    return await _api.get(recentSalesEndpoint);
  }
}
