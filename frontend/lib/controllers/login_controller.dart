import 'package:frontend/routes/app_routes.dart';
import 'package:get/get.dart';
class LoginController extends GetxController {
  void goToLogin() {
    Get.toNamed(AppRoutes.home);
  }
}