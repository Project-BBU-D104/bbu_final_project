import 'package:frontend/controllers/app_controller.dart';
import 'package:frontend/global.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/utils/token_utils.dart';
import 'package:get/get.dart';

class LandingController extends GetxController {
  @override
  void onReady() {
    super.onReady();
    _route();
  }

  void _route() async {
    Get.put(AppController(), permanent: true);
    await Future.delayed(Duration(seconds: 2));
    // Get.offAllNamed(AppRoutes.login);

    final user = storage.lastUserLoginRead;
    final hasValidSession =
        TokenUtils.hasValidSession(user) && storage.appStartUpRead.isNotEmpty;

    if (hasValidSession) {
      Get.offAllNamed(storage.appStartUpRead);
    } else {
      // Never enter the app with an expired token: every API call would
      // return 401 and screens would look empty.
      if (user.isNotEmpty) {
        await storage.lastUserLoginRemove();
      }
      Get.offAllNamed(AppRoutes.login);
    }
  }
}
