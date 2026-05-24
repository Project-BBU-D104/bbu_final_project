import 'package:frontend/controllers/app_controller.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:get/get.dart';

class LandingController extends GetxController {
  @override
  void onReady() {
    super.onReady();
    _route();
  }

  void _route() async {
    Get.put(AppController(), permanent: true);
    await Future.delayed(Duration(seconds: 1));
    Get.offAllNamed(AppRoutes.home);
  }
}
