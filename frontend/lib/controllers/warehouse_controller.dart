import 'package:flutter/material.dart';
import 'package:frontend/screen/stock/warehouse/widget/add_warehouse_widget.dart';
import 'package:frontend/services/main_service/warehouse_service.dart';
import 'package:frontend/widget/bottom_sheets.dart';
import 'package:frontend/widget/toast_widget.dart';
import 'package:get/get.dart';

class WarehouseController extends GetxController{

  final WarehouseService service = WarehouseService();
  var isLoading = false.obs;
  

  final warehouseList = <Map<String, dynamic>>  [].obs;

  @override
  void onInit() {
    getWarehouses();
    super.onInit();
  }

  Future<void> getWarehouses() async{
    try{
      isLoading.value = true;

      final resp = await service.getWarehouses();

      if(resp is List){
        warehouseList.value = List<Map<String, dynamic>>.from(resp);
      }

      print(warehouseList);
    }catch(e){
      ToastWidget.show(
        message: e.toString(),
        type: ToastType.error,
      );
    }finally{
      isLoading.value = false;
    }
  }

  void addWarehouse(BuildContext context){
    AppBottomSheets.show(
      context,
      child: AddWarehouseWidget()
    ); 
  }
}
