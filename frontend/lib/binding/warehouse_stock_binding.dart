import 'package:frontend/controllers/warehouse_stock_controller.dart';
import 'package:get/get.dart';

class WarehouseStockBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WarehouseStockController>(() => WarehouseStockController());
  }
}
