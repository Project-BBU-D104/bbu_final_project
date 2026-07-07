import 'package:flutter/material.dart';
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
  var isActive = false.obs;
  final selectedTab = "All".obs;

  final SupplierService service = SupplierService();
  final suppliers = <SupplierModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    getSuppliers();
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

  void saveSupplier(){
    // Implement save supplier logic here
  }

  void deleteSupplier({required int supplierId}){
    print("Delete supplier with ID: $supplierId");
  }

}