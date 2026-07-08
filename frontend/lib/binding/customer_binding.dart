import 'package:frontend/controllers/customer_controller.dart';
import 'package:frontend/controllers/image_upload_controller.dart';
import 'package:get/get.dart';

class CustomerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CustomerController>(() => CustomerController());

    Get.lazyPut(
      () => ImageUploadController(),
    );
  }
}
