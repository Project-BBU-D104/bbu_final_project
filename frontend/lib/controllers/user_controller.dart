import 'package:flutter/material.dart' hide SearchController;
import 'package:frontend/controllers/image_upload_controller.dart';
import 'package:frontend/helper/confirm_dialog_helper.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/screen/user/widget/add_user_widget.dart';
import 'package:frontend/screen/user/widget/edit_user_widget.dart';
import 'package:frontend/services/main_service/user_service.dart';
import 'package:frontend/widget/bottom_sheets.dart';
import 'package:frontend/widget/toast_widget.dart';
import 'package:get/get.dart';
import 'package:frontend/controllers/search_controller.dart';
import 'package:frontend/controllers/system_configuration_controller.dart';

class UserController extends GetxController {
  UserController({
    UserService? service,
    SystemConfigurationController? systemConfigurationCtr,
  }) : service = service ?? UserService(),
       systemConfigurationCtr =
           systemConfigurationCtr ?? Get.put(SystemConfigurationController());

  final UserService service;
  final SystemConfigurationController systemConfigurationCtr;
  var selectedUser = RxnString();

  final isLoading = false.obs;
  final loadError = RxnString();
  bool _loadingList = false;
  bool _writeInProgress = false;

  // final selectedRole = ''.obs;
  final selectedRole = RxnString(null);
  final selectedSystemConfiguration = RxnString(null);
  final userList = <Map<String, dynamic>>[].obs;
  final searchUserList = <Map<String, dynamic>>[].obs;
  final userPhotoController = TextEditingController();
  final userNameController = TextEditingController();
  final userEmailController = TextEditingController();
  final userPasswordController = TextEditingController();
  final userPhoneController = TextEditingController();

  final key = GlobalKey<FormState>();
  bool _editSheetOpen = false;

  var isChecked = false.obs;

  static final List<Map<String, dynamic>> _cache = [];
  static DateTime? _cachedAt;
  static const Duration _cacheTtl = Duration(seconds: 60);

  static bool get _hasFreshCache =>
      _cachedAt != null && DateTime.now().difference(_cachedAt!) < _cacheTtl;

  @override
  void onInit() {
    super.onInit();

    if (_hasFreshCache) {
      userList.value = List<Map<String, dynamic>>.from(_cache);
      searchUserList.value = userList;
    } else {
      getUserList();
    }

    final search = Get.put(SearchController());
    ever(search.keyword, (keyword) {
      searchUser(keyword);
    });
  }

  void clearUser() {
    selectedRole.value = null;
    selectedSystemConfiguration.value = null;
    userPhotoController.clear();
    userNameController.clear();
    userEmailController.clear();
    userPhoneController.clear();
    isChecked.value = false;
  }

  Future<void> getUserList() async {
    if (_loadingList) return;
    try {
      _loadingList = true;
      isLoading.value = true;
      loadError.value = null;

      final resp = await service.getUsers();

      if (resp is List) {
        userList.value = List<Map<String, dynamic>>.from(resp);

        searchUserList.value = userList;

        _cache
          ..clear()
          ..addAll(userList);
        _cachedAt = DateTime.now();
      }
    } catch (e) {
      loadError.value = e.toString();
      ToastWidget.show(message: e.toString(), type: ToastType.error);
    } finally {
      _loadingList = false;
      isLoading.value = false;
    }
  }

  void searchUser(String keyword) {
    final search = keyword.trim().toLowerCase();

    if (search.isEmpty) {
      searchUserList.value = userList;
      return;
    }

    searchUserList.value = userList.where((user) {
      return (user["name"] ?? "").toString().toLowerCase().contains(search);
    }).toList();
  }

  void addUser(BuildContext context) {
    clearUser();
    AppBottomSheets.show(context, child: AddUserWidget());
  }

  Future<void> onSaveUser(BuildContext context) async {
    if (_writeInProgress) return;
    try {
      _writeInProgress = true;
      isLoading.value = true;

      final data = {
        'photo': userPhotoController.text.trim(),
        'name': userNameController.text.trim(),
        'email': userEmailController.text.trim(),
        'password': userPasswordController.text.trim(),
        'phone': userPhoneController.text.trim(),
        'role_id': selectedRole.value,
        'system_configuration_id': int.tryParse(
          selectedSystemConfiguration.value ?? '',
        ),
        'is_active': !isChecked.value,
      };

      await service.createUser(data);

      ToastWidget.show(
        message: "User created successfully",
        type: ToastType.success,
      );
      // Reload User
      await getUserList();

      // Clear textfields

      clearUser();

      Get.find<ImageUploadController>().clearImage();

      // Close BottomSheet
      Navigator.pop(context);
    } catch (e) {
      ToastWidget.show(message: e.toString(), type: ToastType.error);
    } finally {
      _writeInProgress = false;
      isLoading.value = false;
    }
  }

  void gotoUserDetail(Map<String, dynamic> user) {
    Get.toNamed(AppRoutes.userDetail, arguments: user);
  }

  void editUser(BuildContext context, int userId) async {
    // The form key is shared, so a second sheet would duplicate the GlobalKey.
    if (_editSheetOpen) return;
    _editSheetOpen = true;
    try {
      final user = await service.getUserById(userId);

      userPhotoController.text = user["photo"] ?? "";
      userNameController.text = user["name"] ?? "";
      userEmailController.text = user["email"] ?? "";
      userPhoneController.text = user["phone"] ?? "";
      userPasswordController.text = user["password"] ?? "";
      selectedRole.value = user["role"]?["id"]?.toString();
      selectedSystemConfiguration.value = user["system_configuration_id"]
          ?.toString();
      isChecked.value = user["is_active"] != true;
      await AppBottomSheets.show(
        context,
        child: EditUserWidget(userId: userId),
      );
    } catch (e) {
      ToastWidget.show(message: e.toString(), type: ToastType.error);
    } finally {
      _editSheetOpen = false;
    }
  }

  Future<void> onUpdateUser(int userId, BuildContext context) async {
    if (_writeInProgress) return;
    try {
      _writeInProgress = true;
      isLoading.value = true;
      final data = {
        "photo": userPhotoController.text.trim(),
        "name": userNameController.text.trim(),
        "email": userEmailController.text.trim(),
        "phone": userPhoneController.text.trim(),
        "password": userPasswordController.text.trim(),
        "role_id": selectedRole.value,
        "system_configuration_id": int.tryParse(
          selectedSystemConfiguration.value ?? '',
        ),
        "is_active": !isChecked.value,
      };

      await service.updateUser(userId, data);

      ToastWidget.show(
        message: "User updated successfully".tr,
        type: ToastType.success,
      );

      Navigator.pop(context);
      await getUserList();

      clearUser();
    } catch (e) {
      ToastWidget.show(message: e.toString(), type: ToastType.error);
    } finally {
      _writeInProgress = false;
      isLoading.value = false;
    }
  }

  Future<void> deleteUser(int userId, BuildContext context) async {
    showConfirmDialog(
      context: context,
      message: "Do you want to delete this user?".tr,
      onConfirm: () async {
        try {
          await service.deleteUser(userId);
          // Refresh user list
          await getUserList();

          Get.back();

          ToastWidget.show(
            message: "User deleted successfully".tr,
            type: ToastType.success,
          );
        } catch (e) {
          ToastWidget.show(message: e.toString(), type: ToastType.error);
        }
      },
      onCancel: () {
        // Do nothing
      },
    );
  }
}
