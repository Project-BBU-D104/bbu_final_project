import 'package:flutter/material.dart' hide SearchController;
import 'package:frontend/helper/confirm_dialog_helper.dart';
import 'package:frontend/models/supplier_model.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/screen/supplier/widgets/supplier_add_widget.dart';
import 'package:frontend/screen/supplier/widgets/supplier_edit_widget.dart';
import 'package:frontend/services/main_service/supplier_service.dart';
import 'package:frontend/widget/bottom_sheets.dart';
import 'package:frontend/widget/toast_widget.dart';
import 'package:get/get.dart';
import 'package:frontend/controllers/search_controller.dart';

class SupplierController extends GetxController {

  var isLoading = false.obs;
  final selectedTab = "All".obs;
  final SupplierService service = SupplierService();
  final suppliers = <SupplierModel>[].obs;
  final searchSuppliers = <SupplierModel>[].obs;
  final supplierNameController = TextEditingController();
  final supplierPhoneNumberController = TextEditingController();
  final supplierEmailController = TextEditingController();
  final supplierMapController = TextEditingController();
  final supplierAddressController = TextEditingController();
  final status = true.obs;

  @override
  void onInit() {
    super.onInit();
    getSuppliers();

    final searchController = Get.put(SearchController());

    ever(
      searchController.keyword,
      (keyword) {
        searchSupplier(keyword);
      },
    );
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

  void clearSupplier(){
    supplierNameController.clear();
    supplierPhoneNumberController.clear();
    supplierEmailController.clear();
    supplierMapController.clear();
    supplierAddressController.clear();
    status.value = true;
  }

  void onRefresh(){
    getSuppliers();
    print("Helo");
  }

  Future<void> getSuppliers() async {
    try{
      isLoading.value = true;
      final resp = await service.getSuppliers();
      if(resp is List){
        suppliers.value = resp
            .map((item) => SupplierModel.fromJson(item))
            .toList();

        // Show all suppliers initially
        searchSuppliers.value = suppliers;
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

  // search supplier
  void searchSupplier(String keyword){
    final search = keyword.toLowerCase();

    if(search.isEmpty){
      searchSuppliers.value = suppliers;
      return;
    }

    searchSuppliers.value = suppliers.where((supplier) {
      return supplier.name.toLowerCase().contains(search);
    }).toList();
  }

  void gotoSupplierDetail(SupplierModel supplier){
    Get.toNamed(AppRoutes.supplierDetail, arguments: supplier);
  }

  void addSupplier(BuildContext context){
    clearSupplier();
    AppBottomSheets.show(
      context,
      child: SupplierAddWidget()
    );
  }

  void saveSupplier(BuildContext context) async{
    if (supplierPhoneNumberController.text.trim().isEmpty) {
      ToastWidget.show(
        message: "Phone number is required".tr,
        type: ToastType.error,
      );
      return;
    }
    
    try{
      final data = {
        "name": supplierNameController.text.trim(),
        "phone": supplierPhoneNumberController.text.trim(),
        "email": supplierEmailController.text.trim(),
        "map": supplierMapController.text.trim(),
        "address": supplierAddressController.text.trim(),
        "status": status.value
      };

      await service.createSupplier(data);

      // Reload Supplier
      await getSuppliers();

      ToastWidget.show(
        message: "Supplier created successfully",
        type: ToastType.success,
      );

    // Clear textfields
    clearSupplier();

    // Close BottomSheet
    Navigator.pop(context);

    }catch(e){
      ToastWidget.show(
        message: e.toString(),
        type: ToastType.error,
      );
    }
  }

  Future<void> editSupplier(int supplierId,BuildContext context) async {
    try{
      final supplier = await service.getSupplierById(supplierId);

      supplierNameController.text = supplier["name"] ?? "";
      supplierPhoneNumberController.text = supplier["phone"] ?? "";
      supplierEmailController.text = supplier["email"] ?? "";
      supplierMapController.text = supplier["map"] ?? "";
      supplierAddressController.text = supplier["address"] ?? "";
      status.value = supplier["status"] ?? false;

      AppBottomSheets.show(
        context,
        child: SupplierEditWidget(
          supplierId: supplierId
        )
      );
    }catch(e){
      ToastWidget.show(
        message: e.toString(),
        type: ToastType.error,
      );
    }
  }

  Future<void> updateSupplier(int supplierId, BuildContext context) async {
    try{
      final data = {
        "name": supplierNameController.text.trim(),
        "phone": supplierPhoneNumberController.text.trim(),
        "email": supplierEmailController.text.trim(),
        "map": supplierMapController.text.trim(),
        "address": supplierAddressController.text.trim(),
        "status": status.value
      };

      await service.updateSupplier(supplierId, data);

      // Reload Category
      await getSuppliers();

      // Clear textfields
      clearSupplier();

      Get.offNamed(AppRoutes.supplier);

      ToastWidget.show(
        message: "Supplier updated successfully",
        type: ToastType.success,
      );
    }catch(e){
      // Do nothing
    }
  }

  Future<void> deleteSupplier({required int supplierId, required BuildContext context}) async {
    showConfirmDialog(
      context: context,
      message: "Do you want to delete this supplier?".tr,
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