import 'package:flutter/material.dart';
import 'package:frontend/controllers/image_upload_controller.dart';
import 'package:frontend/helper/confirm_dialog_helper.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/screen/user/widget/add_user_widget.dart';
import 'package:frontend/screen/user/widget/edit_user_widget.dart';
import 'package:frontend/services/main_service/user_service.dart';
import 'package:frontend/widget/bottom_sheets.dart';
import 'package:frontend/widget/toast_widget.dart';
import 'package:get/get.dart';

class UserController extends GetxController{
  final UserService service = UserService();
  var selectedUser = RxnString();

  final isLoading = false.obs;

  // final selectedRole = ''.obs;
final selectedRole = RxnString(null);

  final  userList = <Map<String, dynamic>>[].obs;

  final userPhotoController = TextEditingController();
  final userNameController = TextEditingController();
  final userEmailController = TextEditingController();
  final userPasswordController = TextEditingController();
  final userPhoneController = TextEditingController();

  var isChecked = false.obs;


  @override
  void onInit() {
    super.onInit();

    getUserList();
  }

  Future<void> getUserList() async {
    try{
      isLoading.value = true;

      final resp = await service.getUsers();

      if(resp is List){
        userList.value = List<Map<String, dynamic>>.from(resp);
      }
    }catch(e){
      ToastWidget.show(
        message: e.toString(),
        type: ToastType.error,
      );
    }
    finally{
      isLoading.value = false;
    }
  }

  void addUser(BuildContext context){
    AppBottomSheets.show(
      context,
      child: AddUserWidget()
    );
  }

  Future<void> onSaveUser(BuildContext context) async{
    try{
      isLoading.value = true;

      final data = {
        'photo': userPhotoController.text.trim(),
        'name': userNameController.text.trim(),
        'email': userEmailController.text.trim(),
        'password': userPasswordController.text.trim(),
        'phone': userPhoneController.text.trim(),
        'role_id': selectedRole.value
      };

      await service.createUser(data);

      ToastWidget.show(
        message: "User created successfully",
        type: ToastType.success,
      );
       // Reload User
      await getUserList();

    // Clear textfields

    selectedRole.value = null;

    userPhotoController.clear();
    userNameController.clear();
    userEmailController.clear();
    userPhoneController.clear();

    isChecked.value = false;

    Get.find<ImageUploadController>()
    .clearImage();

    // Close BottomSheet
    Navigator.pop(context);

    }catch(e){
      ToastWidget.show(
        message: e.toString(),
        type: ToastType.error,
      );
    }finally{
      isLoading.value = false;
    }
  }

  void gotoUserDetail(Map<String, dynamic> user) {
    Get.toNamed(
      AppRoutes.userDetail,
      arguments: user,
    );
  }

  void editUser(BuildContext context, int userId) async{
    try{
      final user =  await service.getUserById(userId);

      userPhotoController.text = user["photo"] ?? "";
      userNameController.text = user["name"] ?? "";
      userEmailController.text = user["email"] ?? "";
      userPhoneController.text = user["phone"] ?? "";
      userPasswordController.text = user["password"] ?? "";
      selectedRole.value =
        user["role"]?["id"]?.toString();
      isChecked.value = user["is_active"] ?? false;
      AppBottomSheets.show(
      context,
      child: EditUserWidget(
        userId: userId
      )
    );
    }catch(e){
      // 
    }
  }

  Future<void> onUpdateUser(
    int userId,
    BuildContext context,
) async {
  try {
    isLoading.value = true;
    final data = {
      "photo": userPhotoController.text.trim(),
      "name": userNameController.text.trim(),
      "email": userEmailController.text.trim(),
      "phone": userPhoneController.text.trim(),
      "password": userPasswordController.text.trim(),
      "role_id": selectedRole.value,
      "is_active": !isChecked.value,
    };

    await service.updateUser(
      userId,
      data,
    );

    ToastWidget.show(
      message: "User updated successfully".tr,
      type: ToastType.success,
    );

 Navigator.pop(context);
    await getUserList();
  } catch(e){
    ToastWidget.show(
      message: e.toString(),
      type: ToastType.error,
    );
  } finally {
    isLoading.value = false;
  }

}

  Future<void> deleteUser(int userId, BuildContext context) async{
    showConfirmDialog(
      context: context,
      message: "Do you want to delete this user?".tr,
      onConfirm: () async {
        try{
          await service.deleteUser(userId);
          // Refresh user list
          await getUserList();

          Get.back();

          ToastWidget.show(
            message: "User deleted successfully".tr,
            type: ToastType.success,
          );

        }catch(e){
          ToastWidget.show(
            message: e.toString(),
            type: ToastType.error,
          );
        }
      },
      onCancel: () {
        // Do nothing
      },
    );
  }
}