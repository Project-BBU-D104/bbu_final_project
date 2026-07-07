import 'package:flutter/material.dart';
import 'package:frontend/helper/confirm_dialog_helper.dart';
import 'package:frontend/models/supplier_model.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/screen/supplier/widgets/supplier_add_widget.dart';
import 'package:frontend/screen/supplier/widgets/supplier_edit_widget.dart';
import 'package:frontend/services/main_service/supplier_service.dart';
import 'package:frontend/widget/bottom_sheets.dart';
import 'package:frontend/widget/toast_widget.dart';
import 'package:get/get.dart';

class SupplierController extends GetxController {

  var isLoading = false.obs;
  final selectedTab = "All".obs;

  final SupplierService service = SupplierService();
  final suppliers = <SupplierModel>[].obs;

  final supplierNameController = TextEditingController();
  final supplierPhoneNumberController = TextEditingController();
  final supplierEmailController = TextEditingController();
  final supplierMapController = TextEditingController();
  final supplierAddressController = TextEditingController();

  final status = false.obs;

  @override
  void onInit() {
    super.onInit();
    getSuppliers();
  }

  @override
  void onClose() {
    super.onClose();
    supplierNameController.dispose();
    supplierPhoneNumberController.dispose();
    supplierEmailController.dispose();
    supplierMapController.dispose();
    supplierAddressController.dispose();
  }

  void getSuppliers() async {
    try{
      isLoading.value = true;

      final resp = await service.getSuppliers();

      if(resp is List){
        suppliers.value = resp
            .map((item) => SupplierModel.fromJson(item))
            .toList();
      }

    }catch(e){
        ToastWidget.show(
          message: e.toString(),
          type: ToastType.error,
        );
    }
    finally {
      isLoading.value = false;
    }
  }
  void changeTab(String value){
    selectedTab.value = value;
  }

  void gotoSupplierDetail(SupplierModel supplier){
    Get.toNamed(AppRoutes.supplierDetail, arguments: supplier);
  }

  void addSupplier(BuildContext context){
    AppBottomSheets.show(
      context,
      child: SupplierAddWidget()
    );
  }

  void editSupplier(BuildContext context){
    AppBottomSheets.show(
      context,
      child: SupplierEditWidget()
    );
  }

  void saveSupplier(BuildContext context){
    try{
      final data = {
        "name": supplierNameController.text.trim(),
        "phone": supplierPhoneNumberController.text.trim(),
        "email": supplierEmailController.text.trim(),
        "map": supplierMapController.text.trim(),
        "address": supplierAddressController.text.trim(),
        "status": status.value
      };

      service.createSupplier(data);

      // Reload Supplier
      getSuppliers();

      ToastWidget.show(
        message: "Supplier created successfully",
        type: ToastType.success,
      );

    // Clear textfields
    supplierNameController.clear();
    supplierPhoneNumberController.clear();
    supplierEmailController.clear();
    supplierMapController.clear();
    supplierAddressController.clear();
    status.value = false;

    // Close BottomSheet
    Navigator.pop(context);

    }catch(e){
      ToastWidget.show(
        message: e.toString(),
        type: ToastType.error,
      );
    }
  }

  Future<void> deleteSupplier({required int supplierId, required BuildContext context}) async {
    showConfirmDialog(
      context: context,
      message: "Do you want to delete this category?".tr,
      onConfirm: () async {
        try{
          await service.deleteSupplier(supplierId);

          Get.back();

          // Refresh supplier list
          getSuppliers();

          ToastWidget.show(
            message: "Supplier deleted successfully".tr,
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