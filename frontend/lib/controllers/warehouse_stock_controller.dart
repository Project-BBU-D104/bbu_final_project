import 'package:flutter/material.dart';
import 'package:frontend/helper/confirm_dialog_helper.dart';
import 'package:frontend/screen/stock/warehouse_stock/widget/add_warehouse_stock_widget.dart';
import 'package:frontend/screen/stock/warehouse_stock/widget/edit_warehouse_stock_widget.dart';
import 'package:frontend/services/main_service/warehouse_stock_service.dart';
import 'package:frontend/widget/bottom_sheets.dart';
import 'package:frontend/widget/toast_widget.dart';
import 'package:get/get.dart';

class WarehouseStockController extends GetxController{
  final WarehouseStockService service = WarehouseStockService();

  final isLoading = false.obs;
  final warehouseStockList = [].obs;

  final selectedWarehouse = RxnString();
  
  final productRows = <Map<String, dynamic>>[].obs;

  @override
  void onInit(){
    super.onInit();
    addProductRow();
    getWarehouseStock();
  }

  void addProductRow() {
    productRows.add({
      "product": RxnString(),
      "qty": TextEditingController(),
    });
  }

  void removeProductRow(int index) {
    if (productRows.length == 1) return;

    (productRows[index]["qty"] as TextEditingController).dispose();
    productRows.removeAt(index);
  }

  Future<void> getWarehouseStock() async{
    try{
      isLoading.value = true;

      final resp = await service.getWarehouseStock();

      if(resp is List){
        warehouseStockList.value = List<Map<String, dynamic>>.from(resp);
      }
      
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

  Future<void> onSaveWarehouseStock() async{
    // 
  }

  void editWarehouseStock(BuildContext context){
    AppBottomSheets.show(
      context,
      child: EditWarehouseStockWidget()
    ); 
  }

  void onUpdateWarehouseStock() async{
    // 
  }


  Future<void> onDeleteWarehouseStock(int warehouseStockId, BuildContext context) async{
    showConfirmDialog(
      context: context,
      message: "Do you want to delete this warehouse stock?".tr,
      onConfirm: () async {
        try{
          await service.deleteWarehouseStock(warehouseStockId);

          // Refresh warehouse list
          await getWarehouseStock();

          ToastWidget.show(
            message: "Warehouse stock deleted successfully".tr,
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