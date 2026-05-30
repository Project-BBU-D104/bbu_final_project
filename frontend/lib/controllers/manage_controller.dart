import 'package:frontend/routes/app_routes.dart';
import 'package:get/get.dart';

class ManageController extends GetxController{

  void goToProduct(){
    Get.toNamed(AppRoutes.product);
  }
  void goToCategory(){
    Get.toNamed(AppRoutes.category);
  }
  void goToSupplier(){
    Get.toNamed(AppRoutes.supplier);
  }
  void goToStock(){
    Get.toNamed(AppRoutes.stockMovement);
  }
}