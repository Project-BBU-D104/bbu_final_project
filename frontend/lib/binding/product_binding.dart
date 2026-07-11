import 'package:frontend/controllers/category_controller.dart';
import 'package:frontend/controllers/product_controller.dart';
import 'package:frontend/controllers/supplier_controller.dart';
import 'package:get/get.dart';

class ProductBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProductController>(() => ProductController());
    Get.lazyPut<CategoryController>(() => CategoryController());
    Get.lazyPut<SupplierController>(() => SupplierController());
  }
}
