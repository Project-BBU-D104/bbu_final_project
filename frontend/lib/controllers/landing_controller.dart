import 'package:frontend/controllers/app_controller.dart';
import 'package:frontend/global.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/services/storage_service.dart';
import 'package:frontend/utils/token_utils.dart';
import 'package:get/get.dart';

class LandingController extends GetxController {
  LandingController({IStorageService? sessionStorage})
    : sessionStorage = sessionStorage ?? storage;

  final IStorageService sessionStorage;
  final isLoading = false.obs;
  final hasError = false.obs;

  @override
  void onReady() {
    super.onReady();
    initialize();
  }

  Future<void> initialize() async {
    if (isLoading.value) return;
    isLoading.value = true;
    hasError.value = false;
    try {
      if (!Get.isRegistered<AppController>()) {
        Get.put(AppController(), permanent: true);
      }

      final user = sessionStorage.lastUserLoginRead;
      final hasValidSession =
          TokenUtils.hasValidSession(user) &&
          sessionStorage.appStartUpRead.isNotEmpty;

      if (hasValidSession) {
        Get.offAllNamed(sessionStorage.appStartUpRead);
      } else {
        // Never enter the app with an expired token: every API call would
        // return 401 and screens would look empty.
        if (user.isNotEmpty) {
          await sessionStorage.lastUserLoginRemove();
        }
        Get.offAllNamed(AppRoutes.login);
      }
    } catch (_) {
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }
}
