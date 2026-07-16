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
  final selectedProduct = RxnString();

  final productRows = <Map<String, dynamic>>[].obs;

  final warehouseStockQtyController = TextEditingController();

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

      print(warehouseStockList);
      
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

  void addWarehouseStock(BuildContext context){
    AppBottomSheets.show(
      context,
      child: AddWarehouseStockWidget()
    ); 
  }

  Future<void> onSaveWarehouseStock() async{
    try{
      isLoading.value = true;

      final data = {

      "warehouse_id":
          int.parse(selectedWarehouse.value!),

      "items": productRows.map((row){
        return {
          "product_id":
            int.parse(
              (row["product"] as RxnString).value!
            ),
          "qty":
            int.parse(
              (row["qty"] as TextEditingController).text
            ),
        };
      }).toList(),
    };
      await service.createWarehouseStock(data);

      ToastWidget.show(
        message: "Warehouse stock created successfully".tr,
        type: ToastType.success,
      );

      // Reload Category
      await getWarehouseStock();

      // Close BottomSheet
      Navigator.pop(Get.context!);

      // clear
      selectedWarehouse.value = null;
      selectedProduct.value = null;
      productRows.clear();
      warehouseStockQtyController.clear();
      addProductRow();

    }catch(e){
      ToastWidget.show(
        message: e.toString(),
        type: ToastType.error,
      );
    }finally{
      isLoading.value = false;
    }
  }

  void editWarehouseStock(BuildContext context, int warehouseStockId) async {
  try {

    final stock = await service.getWarehouseStockById(
      warehouseStockId,
    );

    print("EDIT RESPONSE:");
    print(stock);


    productRows.clear();

  

   productRows.add({
  "product": RxnString(
    stock["product"]["id"].toString(),
  ),

  "qty": TextEditingController(
    text: stock["qty"].toString(),
  ),
});


    AppBottomSheets.show(
      context,
      child: EditWarehouseStockWidget(
        warehouseStockId: warehouseStockId,
      ),
    );


  } catch(e){

    ToastWidget.show(
      message: e.toString(),
      type: ToastType.error,
    );

  }
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