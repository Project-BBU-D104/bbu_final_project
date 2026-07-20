import 'package:flutter/material.dart';
import 'package:frontend/helper/confirm_dialog_helper.dart';
import 'package:frontend/screen/unit/widget/add_unit_widget.dart';
import 'package:frontend/screen/unit/widget/edit_unit_widget.dart';
import 'package:frontend/services/main_service/unit_service.dart';
import 'package:frontend/widget/bottom_sheets.dart';
import 'package:frontend/widget/toast_widget.dart';
import 'package:get/get.dart';

class UnitController extends GetxController{

  final UnitService service = UnitService();  
  var isLoading = false.obs;
  var unitList = <Map<String, dynamic>>[].obs;

  final unitNameController = TextEditingController();
  final unitShortNameController = TextEditingController();
  final unitDescriptionController = TextEditingController();
  final isActive = false.obs;

  @override
  void onInit() {
    getUnitList();
    super.onInit();
  }

  void onClear() {
    unitNameController.clear();
    unitShortNameController.clear();
    unitDescriptionController.clear();
    isActive.value = false;
  }

  Future<void> getUnitList() async{
    try{
      isLoading.value = true;

      final resp = await service.getUnits();

      if (resp is List) {
        unitList.value = List<Map<String, dynamic>>.from(resp);
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

  void addUnit(BuildContext context) {
    onClear();
    AppBottomSheets.show(
      context,
      child: AddUnitWidget()
    );
  }

  Future<void> onSaveUnit() async{
    try{
      isLoading.value = true;

      final data = {
        "name": unitNameController.text,
        "short_name": unitShortNameController.text,
        "description": unitDescriptionController.text,
        "status": isActive.value,
      };
      
      await service.createUnit(data);

      await getUnitList();

      Navigator.pop(Get.context!);

      onClear();

      ToastWidget.show(
        message: "Unit created successfully",
        type: ToastType.success,
      );
    }catch(e){
      ToastWidget.show(
        message: e.toString(),
        type: ToastType.error,
      );
    }finally{
      isLoading.value = false;
    }
  }

Future<void> editUnit(BuildContext context, int unitId) async {
  try {
    final unit = await service.getUnitById(unitId);
 
    unitNameController.text = unit["name"] ?? "";
    unitShortNameController.text = unit["short_name"] ?? "";
    unitDescriptionController.text = unit["description"] ?? "";
    isActive.value = unit["status"] ?? false;
    

    AppBottomSheets.show(
      context,
      child: EditUnitWidget(
        unitId: unitId
      ),
    );
  } catch (e) {
    ToastWidget.show(
      message: e.toString(),
      type: ToastType.error,
    );
  }
}

  Future<void> onUpdateUnit(
    int unitId
  ) async{
    try{
      isLoading.value = true;

      final data = {
        "name": unitNameController.text,
        "short_name": unitShortNameController.text,
        "description": unitDescriptionController.text,
        "status": isActive.value,
      };
      
      await service.updateUnit(unitId, data);

      await getUnitList();

      Navigator.pop(Get.context!);

      onClear();

      ToastWidget.show(
        message: "Unit updated successfully",
        type: ToastType.success,
      );
    }catch(e){
      ToastWidget.show(
        message: e.toString(),
        type: ToastType.error,
      );
    }finally{
      isLoading.value = false;
    }
  }

  Future<void> onDeleteUnit(BuildContext context,int unitId) async{
    showConfirmDialog(
      context: context,
      message: "Do you want to delete this unit?".tr,
      onConfirm: () async {
        try{
          await service.deleteUnit(unitId);

          // Refresh unit list
          await getUnitList();

          ToastWidget.show(
            message: "Unit deleted successfully".tr,
            type: ToastType.success,
          );

          Get.back();

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