import 'package:frontend/controllers/category_controller.dart';
import 'package:frontend/controllers/product_controller.dart';
import 'package:frontend/controllers/purchase/purchase_controller.dart';
import 'package:frontend/controllers/supplier_controller.dart';
import 'package:frontend/controllers/warehouse_controller.dart';
import 'package:get/get.dart';

class PurchaseBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PurchaseController>(() => PurchaseController());
    Get.lazyPut<SupplierController>(() => SupplierController());
    Get.lazyPut<ProductController>(() => ProductController());
    Get.lazyPut<CategoryController>(() => CategoryController());
    Get.lazyPut<WarehouseController>(() => WarehouseController());
  }
}
