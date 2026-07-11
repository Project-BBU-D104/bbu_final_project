import 'package:flutter/material.dart';
import 'package:frontend/models/user_model.dart';
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
  var isChecked = false.obs;
  final isLoading = false.obs;

  // final selectedRole = ''.obs;
  final selectedRole = RxnString();

  final  userList = <Map<String, dynamic>>[].obs;

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

  void gotoUserDetail(Map<String, dynamic> user) {
    Get.toNamed(
      AppRoutes.userDetail,
      arguments: user,
    );
  }

  void editUser(BuildContext context, Map<String, dynamic> user){
    AppBottomSheets.show(
      context,
      child: EditUserWidget()
    );
  }

  void deleteUser(BuildContext context, Map<String, dynamic> user){
    
  }
}