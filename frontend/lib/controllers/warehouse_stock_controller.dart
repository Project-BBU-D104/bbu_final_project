import 'package:flutter/material.dart';
import 'package:frontend/screen/stock/warehouse_stock/widget/add_warehouse_stock_widget.dart';
import 'package:frontend/services/main_service/warehouse_stock_service.dart';
import 'package:frontend/widget/bottom_sheets.dart';
import 'package:get/get.dart';

class WarehouseStockController extends GetxController{
  final WarehouseStockService service = WarehouseStockService();

  final isLoading = false.obs;
  final warehouseStockList = [].obs;

  @override
  void onInit(){
    super.onInit();
    getWarehouseStock();
  }

  Future<void> getWarehouseStock() async{
    try{
      isLoading.value = true;

      final resp = await service.getWarehouseStock();

      if(resp is List){
        warehouseStockList.value = List<Map<String, dynamic>>.from(resp);
      }

      print(warehouseStockList);


    }catch(e){
      // 
    }
    finally{
      isLoading.value = false;
    }
  }

  void addWarehouseStock(BuildContext context){
    AppBottomSheets.show(
      context,
      child: AddWarehouseStockWidget()
    ); 
  }
 
}