import 'package:flutter/material.dart' hide SearchController;
import 'package:frontend/helper/confirm_dialog_helper.dart';
import 'package:frontend/screen/role/widget/add_role_widget.dart';
import 'package:frontend/screen/role/widget/edit_role_widget.dart';
import 'package:frontend/services/main_service/role_service.dart';
import 'package:frontend/widget/bottom_sheets.dart';
import 'package:frontend/widget/toast_widget.dart';
import 'package:get/get.dart';
import 'package:frontend/controllers/search_controller.dart';

class RoleController extends GetxController {
  RoleController({RoleService? service}) : service = service ?? RoleService();

  final RoleService service;

  var isLoading = false.obs;
  final loadError = RxnString();
  bool _loadingList = false;
  bool _writeInProgress = false;
  final roleList = <Map<String, dynamic>>[].obs;
  final searchRoleList = <Map<String, dynamic>>[].obs;
  final roleNameController = TextEditingController();
  final roleDescriptionController = TextEditingController();
  final isActive = false.obs;

  final key = GlobalKey<FormState>();

  static final List<Map<String, dynamic>> _cache = [];
  static DateTime? _cachedAt;
  static const Duration _cacheTtl = Duration(seconds: 60);

  static bool get _hasFreshCache =>
      _cachedAt != null && DateTime.now().difference(_cachedAt!) < _cacheTtl;

  @override
  void onInit() {
    super.onInit();

    if (_hasFreshCache) {
      roleList.value = List<Map<String, dynamic>>.from(_cache);
      searchRoleList.value = roleList;
    } else {
      getRoles();
    }

    final search = Get.put(SearchController());

    ever(search.keyword, (keyword) {
      searchRole(keyword);
    });
  }

  void clearRole() {
    roleNameController.clear();
    roleDescriptionController.clear();
    isActive.value = false;
  }

  Future<void> getRoles() async {
    if (_loadingList) return;
    try {
      _loadingList = true;
      isLoading.value = true;
      loadError.value = null;
      final resp = await service.getRoles();
      if (resp is List) {
        roleList.value = List<Map<String, dynamic>>.from(resp);

        searchRoleList.value = roleList;

        _cache
          ..clear()
          ..addAll(roleList);
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

  void searchRole(String keyword) {
    final search = keyword.trim().toLowerCase();

    if (search.isEmpty) {
      searchRoleList.value = roleList;
      return;
    }

    searchRoleList.value = roleList.where((role) {
      return role["name"].toString().toLowerCase().contains(search);
    }).toList();
  }

  void addRole(BuildContext context) {
    clearRole();
    _showRoleForm(context, const AddRoleWidget());
  }

  Future<void> _showRoleForm(BuildContext context, Widget child) {
    if (MediaQuery.sizeOf(context).width >= 840) {
      return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => Dialog(
          insetPadding: const EdgeInsets.all(32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680, maxHeight: 680),
            child: child,
          ),
        ),
      );
    }

    return AppBottomSheets.show<void>(
      context,
      child: child,
      isDismissible: false,
      enableDrag: false,
    );
  }

  Future<void> onSaveRole() async {
    if (_writeInProgress) return;
    try {
      _writeInProgress = true;
      isLoading.value = true;
      loadError.value = null;
      final data = {
        "name": roleNameController.text.trim(),
        "description": roleDescriptionController.text.trim(),
        "is_active": isActive.value,
      };

      await service.createRole(data);

      // Reload Category
      await getRoles();

      ToastWidget.show(
        message: "Role created successfully",
        type: ToastType.success,
      );

      // Clear textfields
      clearRole();

      // Close BottomSheet
      if (Get.context != null && Navigator.canPop(Get.context!)) {
        Navigator.pop(Get.context!);
      }
    } catch (e) {
      loadError.value = e.toString();
      ToastWidget.show(message: e.toString(), type: ToastType.error);
    } finally {
      _writeInProgress = false;
      isLoading.value = false;
    }
  }

  Future<void> editRole(BuildContext context, int roleId) async {
    final role = await service.getRoleById(roleId);

    roleNameController.text = role["name"] ?? "";
    roleDescriptionController.text = role["description"] ?? "";
    isActive.value = role["is_active"] ?? false;

    if (!context.mounted) return;
    await _showRoleForm(context, EditRoleWidget(roleId: roleId));
  }

  Future<void> updateRole(int roleId, BuildContext context) async {
    if (_writeInProgress) return;
    try {
      _writeInProgress = true;
      isLoading.value = true;
      loadError.value = null;
      final data = {
        "name": roleNameController.text.trim(),
        "description": roleDescriptionController.text.trim(),
        "is_active": isActive.value,
      };

      await service.updateRole(roleId, data);

      // Reload Category
      await getRoles();

      // Close BottomSheet
      if (context.mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      ToastWidget.show(
        message: "Role updated successfully",
        type: ToastType.success,
      );

      // clear
      clearRole();
    } catch (e) {
      loadError.value = e.toString();
      ToastWidget.show(message: e.toString(), type: ToastType.error);
    } finally {
      _writeInProgress = false;
      isLoading.value = false;
    }
  }

  void onDeleteRole(int roleId, BuildContext context) async {
    showConfirmDialog(
      context: context,
      message: "Do you want to delete this role?".tr,
      onConfirm: () async {
        try {
          await service.deleteRole(roleId);

          // Refresh category list
          await getRoles();

          ToastWidget.show(
            message: "Role deleted successfully".tr,
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
