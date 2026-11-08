import 'package:flutter/material.dart';
import 'package:frontend/global.dart';
import 'package:frontend/screen/profile/widget/change_password_widget.dart';
import 'package:frontend/screen/profile/widget/edit_profile_widget.dart';
import 'package:frontend/services/main_service/profile_service.dart';
import 'package:frontend/widget/bottom_sheets.dart';
import 'package:frontend/widget/toast_widget.dart';
import 'package:get/get.dart';

class ProfileController extends GetxController {
  ProfileController({ProfileService? service})
      : service = service ?? ProfileService();

  final ProfileService service;

  final username = "".obs;
  final email = "".obs;
  final phone = "".obs;
  final photo = "".obs;
  final role = "".obs;

  final isSaving = false.obs;

  final profileFormKey = GlobalKey<FormState>();
  final passwordFormKey = GlobalKey<FormState>();

  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final photoCtrl = TextEditingController();

  final currentPasswordCtrl = TextEditingController();
  final newPasswordCtrl = TextEditingController();
  final confirmPasswordCtrl = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadUserLogin();
  }

  void loadUserLogin() {
    final data = storage.lastUserLoginRead;
    final user = data["user"];
    if (user is Map) {
      username.value = user["name"]?.toString() ?? "";
      email.value = user["email"]?.toString() ?? "";
      phone.value = user["phone"]?.toString() ?? "";
      photo.value = user["photo"]?.toString() ?? "";
      final storedRole = user["role"];
      role.value = storedRole is Map
          ? (storedRole["name"]?.toString() ?? "")
          : (storedRole?.toString() ?? "");
    }
  }

  void openEditProfile(BuildContext context) {
    nameCtrl.text = username.value;
    emailCtrl.text = email.value;
    phoneCtrl.text = phone.value;
    photoCtrl.text = photo.value;

    AppBottomSheets.show(context, child: EditProfileWidget());
  }

  void openChangePassword(BuildContext context) {
    currentPasswordCtrl.clear();
    newPasswordCtrl.clear();
    confirmPasswordCtrl.clear();

    AppBottomSheets.show(context, child: ChangePasswordWidget());
  }

  Future<void> onUpdateProfile(BuildContext context) async {
    if (isSaving.value) return;
    if (!(profileFormKey.currentState?.validate() ?? false)) return;

    final payload = {
      'name': nameCtrl.text.trim(),
      'email': emailCtrl.text.trim(),
      'phone': phoneCtrl.text.trim(),
      'photo': photoCtrl.text.trim(),
    };

    isSaving.value = true;
    try {
      final result = await service.updateProfile(payload);

      final login = Map<String, dynamic>.from(storage.lastUserLoginRead);
      final rawUser = login['user'];
      final user = rawUser is Map
          ? Map<String, dynamic>.from(rawUser)
          : <String, dynamic>{};
      final resultMap = result is Map
          ? Map<String, dynamic>.from(result)
          : <String, dynamic>{};

      for (final key in const ['name', 'email', 'phone', 'photo']) {
        user[key] = resultMap.containsKey(key) ? resultMap[key] : payload[key];
      }
      login['user'] = user;
      await storage.lastUserLoginWrite(data: login);

      loadUserLogin();

      ToastWidget.show(
        message: "Profile updated successfully".tr,
        type: ToastType.success,
      );
      if (context.mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      ToastWidget.show(message: e.toString(), type: ToastType.error);
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> onChangePassword(BuildContext context) async {
    if (isSaving.value) return;
    if (!(passwordFormKey.currentState?.validate() ?? false)) return;

    final payload = {
      'current_password': currentPasswordCtrl.text,
      'new_password': newPasswordCtrl.text,
    };

    isSaving.value = true;
    try {
      await service.changePassword(payload);

      currentPasswordCtrl.clear();
      newPasswordCtrl.clear();
      confirmPasswordCtrl.clear();

      ToastWidget.show(
        message: "Password changed successfully".tr,
        type: ToastType.success,
      );
      if (context.mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      ToastWidget.show(message: e.toString(), type: ToastType.error);
    } finally {
      isSaving.value = false;
    }
  }

  void onLogoutPress() {
    Get.offAllNamed('/login');

    storage.lastUserLoginRemove();
    storage.appStartUpWrite(route: '/login');
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    photoCtrl.dispose();
    currentPasswordCtrl.dispose();
    newPasswordCtrl.dispose();
    confirmPasswordCtrl.dispose();
    super.onClose();
  }
}
