import 'package:frontend/controllers/product_transfer_controller.dart';
import 'package:get/get.dart';

class StockTransferBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProductTransferController>(() => ProductTransferController());
  }
}
