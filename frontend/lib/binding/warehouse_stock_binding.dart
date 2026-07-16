import 'package:frontend/controllers/category_controller.dart';
import 'package:frontend/controllers/product_controller.dart';
import 'package:frontend/controllers/supplier_controller.dart';
import 'package:frontend/controllers/warehouse_controller.dart';
import 'package:frontend/controllers/warehouse_stock_controller.dart';
import 'package:get/get.dart';

class WarehouseStockBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WarehouseStockController>(() => WarehouseStockController());
    Get.lazyPut<WarehouseController>(() => WarehouseController());
    Get.lazyPut<CategoryController>(() => CategoryController());
    Get.lazyPut<ProductController>(() => ProductController());
    Get.lazyPut<SupplierController>(() => SupplierController());
  }
}
