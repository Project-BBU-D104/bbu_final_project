import 'package:frontend/controllers/category_controller.dart';
import 'package:frontend/controllers/product_controller.dart';
import 'package:frontend/controllers/product_transfer_controller.dart';
import 'package:frontend/controllers/supplier_controller.dart';
import 'package:frontend/controllers/warehouse_controller.dart';
import 'package:get/get.dart';

class StockTransferBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProductTransferController>(() => ProductTransferController());
    Get.lazyPut<WarehouseController>(() => WarehouseController());
    Get.lazyPut<ProductController>(() => ProductController());
    Get.lazyPut<CategoryController>(() => CategoryController());
    Get.lazyPut<SupplierController>(() => SupplierController());
  }
}
