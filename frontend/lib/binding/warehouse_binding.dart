import 'package:frontend/controllers/warehouse_controller.dart';
import 'package:get/get.dart';

class WarehouseBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WarehouseController>(() => WarehouseController());
  }
}
