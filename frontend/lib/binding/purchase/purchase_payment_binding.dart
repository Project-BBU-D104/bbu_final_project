import 'package:frontend/controllers/purchase/purchase_payment_controller.dart';
import 'package:get/get.dart';

class PurchasePaymentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PurchasePaymentController>(() => PurchasePaymentController());
  }
}
