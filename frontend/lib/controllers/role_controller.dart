import 'package:flutter/material.dart';
import 'package:frontend/helper/confirm_dialog_helper.dart';
import 'package:frontend/screen/role/widget/add_role_widget.dart';
import 'package:frontend/screen/role/widget/edit_role_widget.dart';
import 'package:frontend/services/main_service/role_service.dart';
import 'package:frontend/widget/bottom_sheets.dart';
import 'package:frontend/widget/toast_widget.dart';
import 'package:get/get.dart';

class RoleController extends GetxController{
  final RoleService service = RoleService();

  var isLoading = false.obs;

  final roleList = <Map<String, dynamic>> [].obs;

  final roleNameController = TextEditingController();
  final roleDescriptionController = TextEditingController();

  final isActive = false.obs;

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
      final data = {
        "name": roleNameController.text.trim(),
        "description": roleDescriptionController.text.trim(),
        "is_active": isActive.value
      };

      await service.createRole(data);

      // Reload Category
      await getRoles();

      ToastWidget.show(
        message: "Role created successfully",
        type: ToastType.success,
      );

      // Clear textfields
      roleNameController.clear();
      roleDescriptionController.clear();
      isActive.value = false;

      // Close BottomSheet
      Navigator.pop(Get.context!);

    }catch(e){
      ToastWidget.show(
        message: e.toString(),
        type: ToastType.error,
      );
    }
  }

  Future<void> editRole(BuildContext context, int roleId) async {

    final role = await service.getRoleById(roleId);

    roleNameController.text = role["name"] ?? "";
    roleDescriptionController.text = role["description"] ?? "";
    isActive.value = role["is_active"] ?? false;
    
    AppBottomSheets.show(
      context,
      child: EditRoleWidget(
        roleId: roleId
      )
    );

  }

  Future<void> updateRole(int RoleId, BuildContext context) async {
    try{
      final data = {
        "name": roleNameController.text.trim(),
        "description": roleDescriptionController.text.trim(),
        "is_active": isActive.value
      };

      await service.updateRole(RoleId, data);

      // Reload Category
      await getRoles();

      // Close BottomSheet
      Navigator.pop(context);

      ToastWidget.show(
        message: "Role updated successfully",
        type: ToastType.success,
      );

      // clear
      roleNameController.clear();
      roleDescriptionController.clear();
      isActive.value = false;
      
    }catch(e){
      ToastWidget.show(
        message: e.toString(),
        type: ToastType.error,
      );
    }
  }

  void onDeleteRole(int roleId, BuildContext context) async {
      showConfirmDialog(
      context: context,
      message: "Do you want to delete this role?".tr,
      onConfirm: () async {
        try{
          await service.deleteRole(roleId);

          // Refresh category list
          await getRoles();

          ToastWidget.show(
            message: "Role deleted successfully".tr,
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