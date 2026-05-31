import 'package:frontend/routes/app_routes.dart';
import 'package:get/get.dart';

class ProfileController extends GetxController{
  void onLogoutPress(){
    Get.toNamed(AppRoutes.login);
  }
}