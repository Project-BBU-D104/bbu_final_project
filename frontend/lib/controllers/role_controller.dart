import 'package:flutter/material.dart';
import 'package:frontend/screen/role/widget/add_role_widget.dart';
import 'package:frontend/screen/role/widget/edit_role_widget.dart';
import 'package:frontend/services/main_service/role_service.dart';
import 'package:frontend/widget/bottom_sheets.dart';
import 'package:frontend/widget/toast_widget.dart';
import 'package:get/get.dart';

class RoleController extends GetxController{
  final RoleService service = RoleService();

  var isChecked = false.obs;
  var isLoading = false.obs;

  final roleList = <Map<String, dynamic>> [].obs;

  @override
  void onInit() {
    super.onInit();
    getRoles();
  }

  Future<void> getRoles() async {
    try {
      isLoading.value = true;
      final resp = await service.getRoles();
      if (resp is List) {
        roleList.value = List<Map<String, dynamic>>.from(resp);
      }
    } catch (e) {
        ToastWidget.show(
          message: e.toString(),
          type: ToastType.error,
        );
    } finally {
        isLoading.value = false;
    }
  }

  void addRole(BuildContext context){
    AppBottomSheets.show(
      context,
      child: AddRoleWidget()
    );
  }

  Future<void> onSaveRole() async {
    try{
      isLoading.value = true;
        

    }catch(e){
      // do here
    }
  }

  void editRole(BuildContext context, Map<String, dynamic> role){
    AppBottomSheets.show(
      context,
      child: EditRoleWidget()
    );
  }

  void onDeleteRole(int roleId) {
    print("Delete role with ID: $roleId");
  }
}