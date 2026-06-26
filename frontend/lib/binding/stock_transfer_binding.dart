import 'package:frontend/controllers/stock_transfer_controller.dart';
import 'package:get/get.dart';

class StockTransferBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StockTransferController>(() => StockTransferController());
  }
}
