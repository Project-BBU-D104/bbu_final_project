import 'package:frontend/controllers/stock_adjustment_controller.dart';
import 'package:get/get.dart';

class StockAdjustmentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StockAdjustmentController>(() => StockAdjustmentController());
  }
}
