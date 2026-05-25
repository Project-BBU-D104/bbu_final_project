import 'package:frontend/routes/app_routes.dart';
import 'package:get/get.dart';

class ManageController extends GetxController{

  void goToProduct(){
    Get.toNamed(AppRoutes.product);
  }
}