import 'package:frontend/controllers/purchase/purchase_request_controller.dart';
import 'package:get/get.dart';

class PurchaseRequestBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PurchaseRequestController>(() => PurchaseRequestController());
  }
}
