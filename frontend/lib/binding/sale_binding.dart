import 'package:frontend/controllers/sale/sale_controller.dart';
import 'package:get/get.dart';

class SaleBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SaleController>(() => SaleController());
  }
}
