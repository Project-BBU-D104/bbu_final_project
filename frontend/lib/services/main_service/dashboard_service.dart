import 'package:frontend/services/api_service.dart';

class DashboardService {
  final ApiService _api = ApiService();

  // recent KPI
  static const String kpi = "api/kpi-data";

  static const String monthlySale = "api/monthly-sales";

  static const String revenueByCategory = "api/revenue-by-category";

  static const String lowStockProduct = "api/low-stock-products";

  static const String topSaleProduct = "api/top-selling-products";

  /// GET ALL kpi data
  Future<dynamic> getKpiData() async {
    return await _api.get(kpi);
  }

  /// GET ALL Monthly Sale
  Future<dynamic> getMonthlySale() async {
    return await _api.get(monthlySale);
  }

  /// GET ALL RevenueByCategory
  Future<dynamic> getRevenueByCategory() async {
    return await _api.get(revenueByCategory);
  }

  /// GET ALL LowStockProduct
  Future<dynamic> getLowStockProduct() async {
    return await _api.get(lowStockProduct);
  }

  /// GET ALL TopSaleProduct
  Future<dynamic> getTopSaleProduct() async {
    return await _api.get(topSaleProduct);
  }
}
