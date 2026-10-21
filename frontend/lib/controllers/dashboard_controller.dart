import 'package:get/get.dart';
import 'package:frontend/services/main_service/dashboard_service.dart';

class DashboardController extends GetxController {
  final DashboardService service = DashboardService();

  final RxMap<String, dynamic> kpiData = <String, dynamic>{}.obs;
  final RxList<Map<String, dynamic>> monthlySaleList =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> revenueByCategory =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> lowstockProducts =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> topProducts = <Map<String, dynamic>>[].obs;

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    getDashboardData();
  }

  Future<void> getDashboardData() async {
    if (isLoading.value) return;

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final responses = await Future.wait([
        service.getKpiData(),
        service.getMonthlySale(),
        service.getRevenueByCategory(),
        service.getLowStockProduct(),
        service.getTopSaleProduct(),
      ]);

      kpiData.value = _asMap(responses[0]);
      monthlySaleList.value = _asList(responses[1]);
      revenueByCategory.value = _asList(responses[2]);
      lowstockProducts.value = _asList(responses[3]);
      topProducts.value = _asList(responses[4]);
    } catch (error) {
      errorMessage.value = error.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return <String, dynamic>{};
  }

  List<Map<String, dynamic>> _asList(dynamic value) {
    if (value is List) {
      return value
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }
    return <Map<String, dynamic>>[];
  }
}
