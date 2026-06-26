import 'package:frontend/controllers/stock_movement_controller.dart';
import 'package:get/get.dart';

class StockMovementBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StockMovementController>(() => StockMovementController());
  }
}
