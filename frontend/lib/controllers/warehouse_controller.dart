import 'package:flutter/material.dart';
import 'package:frontend/helper/confirm_dialog_helper.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/screen/stock/warehouse/widget/add_warehouse_widget.dart';
import 'package:frontend/screen/stock/warehouse/widget/edit_warehouse_widget.dart';
import 'package:frontend/services/main_service/warehouse_service.dart';
import 'package:frontend/widget/bottom_sheets.dart';
import 'package:frontend/widget/toast_widget.dart';
import 'package:get/get.dart';

class WarehouseController extends GetxController{

  final WarehouseService service = WarehouseService();
  var isLoading = false.obs;
  
  final warehouseList = <Map<String, dynamic>>  [].obs;

  final warehouseNameController = TextEditingController();
  final warehouseReferenceNoController = TextEditingController();
  final warehouseLocationController = TextEditingController();
  final warehouseNoteController = TextEditingController();

  @override
  void onInit() {
    getWarehouses();
    super.onInit();
  }

  void onClearWarehouse(){
    warehouseNameController.clear();
    warehouseReferenceNoController.clear();
    warehouseLocationController.clear();
    warehouseNoteController.clear();
  }

  Future<void> getWarehouses() async{
    try{
      isLoading.value = true;

      final resp = await service.getWarehouses();

      if(resp is List){
        warehouseList.value = List<Map<String, dynamic>>.from(resp);
      }

    }catch(e){
      ToastWidget.show(
        message: e.toString(),
        type: ToastType.error,
      );
    }finally{
      isLoading.value = false;
    }
  }

  void gotoWarehouseDetail(Map<String, dynamic> warehouse){
    Get.toNamed(
      AppRoutes.warehouseDetail,
      arguments: warehouse,
    );
  }

  void addWarehouse(BuildContext context){
    onClearWarehouse();
    AppBottomSheets.show(
      context,
      child: AddWarehouseWidget()
    ); 
  }

  Future<void> onSaveWarehouse() async{
    try{
      final data = {
        'name': warehouseNameController.text.trim(),
        'reference_no': warehouseReferenceNoController.text.trim(),
        'location': warehouseLocationController.text.trim(),
        'note': warehouseNoteController.text.trim(),
      };

      await service.createWarehouse(data);

      // Reload Category
      await getWarehouses();

      // Close BottomSheet
      Navigator.pop(Get.context!);

      ToastWidget.show(
        message: "Warehouse created successfully",
        type: ToastType.success,
      );

      // Clear textfields
      onClearWarehouse();

    }catch(e){
      // 
    }
  }

  void editWarehouse(BuildContext context, int warehouseId) async{
    try{

      final warehouse = await service.getWarehouseById(warehouseId);

      warehouseNameController.text = warehouse["name"] ?? "";
      warehouseReferenceNoController.text = warehouse["reference_no"] ?? "";
      warehouseLocationController.text = warehouse["location"] ?? "";
      warehouseNoteController.text = warehouse["note"] ?? "";

      AppBottomSheets.show(
        context,
        child: EditWarehouseWidget(
          warehouseId: warehouseId,
        )
      ); 
    }catch(e){
      // 
    }
  }

  Future<void> onUpdateWarehouse(BuildContext context ,int warehouseId) async{
    try{
      final data = {
        'name': warehouseNameController.text.trim(),
        'reference_no': warehouseReferenceNoController.text.trim(),
        'location': warehouseLocationController.text.trim(),
        'note': warehouseNoteController.text.trim(),
      };

      await service.updateWarehouse(warehouseId, data);

      // Reload Category
      await getWarehouses();

      // Close BottomSheet
      Navigator.pop(Get.context!);

      ToastWidget.show(
        message: "Warehouse updated successfully",
        type: ToastType.success,
      );

      // Clear textfields
      onClearWarehouse();
      
    }catch(e){
      // 
    }
  }

  Future<void> deleteWarehouse(BuildContext context,int warehouseId) async{
    showConfirmDialog(
      context: context,
      message: "Do you want to delete this warehouse?".tr,
      onConfirm: () async {
        try{
          await service.deleteWarehouse(warehouseId);

          // Refresh category list
          await getWarehouses();

          Get.back();

          ToastWidget.show(
            message: "Warehouse deleted successfully".tr,
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
