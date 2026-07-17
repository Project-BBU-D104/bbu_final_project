import 'package:frontend/controllers/category_controller.dart';
import 'package:frontend/controllers/product_controller.dart';
import 'package:frontend/controllers/stock_adjustment_controller.dart';
import 'package:frontend/controllers/supplier_controller.dart';
import 'package:frontend/controllers/warehouse_controller.dart';
import 'package:get/get.dart';

class StockAdjustmentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StockAdjustmentController>(() => StockAdjustmentController());
    Get.lazyPut<WarehouseController>(() => WarehouseController());
    Get.lazyPut<ProductController>(() => ProductController());
    Get.lazyPut<CategoryController>(() => CategoryController());
    Get.lazyPut<SupplierController>(() => SupplierController());
  }
}
