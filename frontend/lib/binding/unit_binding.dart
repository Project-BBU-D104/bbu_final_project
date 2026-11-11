import 'package:frontend/controllers/unit_controller.dart';
import 'package:get/get.dart';

class UnitBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UnitController>(() => UnitController());
  }
}
