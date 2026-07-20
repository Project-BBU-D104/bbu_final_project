import 'package:flutter/material.dart';
import 'package:frontend/global.dart';
import 'package:frontend/helper/confirm_dialog_helper.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/screen/stock/stock_adjustment/widget/add_stock_adjustment_widget.dart';
import 'package:frontend/screen/stock/stock_adjustment/widget/edit_stock_adjustment_type_widget.dart';
import 'package:frontend/services/main_service/stock_adjustment_service.dart';
import 'package:frontend/widget/bottom_sheets.dart';
import 'package:frontend/widget/toast_widget.dart';
import 'package:get/get.dart';
import 'package:frontend/services/main_service/warehouse_stock_service.dart';

class StockAdjustmentController extends GetxController{
  final StockAdjustmentService service = StockAdjustmentService();
  final WarehouseStockService warehouseStockService = WarehouseStockService();

  var isLoading = false.obs;

  final selectedProduct = RxnString();
  final selectedAdjustmentType = RxnString();
  final selectedWarehouse = RxnString();
  final currentQty = 0.obs;
  final referenceController = TextEditingController();
  final adjustmentQtyController = TextEditingController();
  final reasonController = TextEditingController();
  final currentQtyController = TextEditingController();
  final stockAdjustmentList = <Map<String, dynamic>> [].obs;
  final newQtyController = TextEditingController();


  @override
  void onInit() async{
    await getStockAdjustments();

    adjustmentQtyController.addListener(calculateNewQty);

    super.onInit();
  }
  void clearForm(){
    selectedProduct.value = null;
    selectedWarehouse.value = null;
    selectedAdjustmentType.value = null;

    referenceController.clear();
    adjustmentQtyController.clear();
    reasonController.clear();
    currentQtyController.clear();
    newQtyController.clear();
  }

Future<void> loadCurrentQty() async {
  if (selectedWarehouse.value == null ||
      selectedProduct.value == null) {
        currentQty.value = 0;
        currentQtyController.clear();
        return;
      }

  try {
    final stock = await warehouseStockService.getProductStock(
      warehouseId: int.parse(selectedWarehouse.value!),
      productId: int.parse(selectedProduct.value!),
    );

    currentQty.value = stock["qty"];
    currentQtyController.text = currentQty.value.toString();
    calculateNewQty();
  } catch (e) {
    currentQty.value = 0;
    currentQtyController.text = "0";
    calculateNewQty();
  }
}

void calculateNewQty() {
  final current = int.tryParse(currentQtyController.text) ?? 0;
  final adjust = int.tryParse(adjustmentQtyController.text) ?? 0;

  if (selectedAdjustmentType.value == null) {
    newQtyController.clear();
    return;
  }

  if (selectedAdjustmentType.value == "increase") {
    newQtyController.text = (current + adjust).toString();
  } else {
    newQtyController.text = (current - adjust).toString();
  }
}
  Future<void> getStockAdjustments() async{
    try{
      isLoading.value = true;
      final resp = await service.getStockAdjustments();
      if(resp is List){
        stockAdjustmentList.value = List<Map<String, dynamic>>.from(resp);
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

  void addStockAdjustment(BuildContext context){
    clearForm();
    AppBottomSheets.show(
      context,
      child: AddStockAdjustmentWidget()
    );
  }

  Future<void> onSaveStockAdjustment() async{
    try{
      isLoading.value = true;
      
      final data = {
        'product_id': selectedProduct.value,
        'warehouse_id': selectedWarehouse.value,
        'adjustment_type': selectedAdjustmentType.value,
        'user_id': storage.lastUserLoginRead["user"]["id"],
        'qty': adjustmentQtyController.text,
        'reason': reasonController.text,
        'reference_no': referenceController.text
      };

      await service.createStockAdjustment(data);

      // Refresh category list
      await getStockAdjustments();

      ToastWidget.show(
        message: "Stock adjustment created successfully".tr,
        type: ToastType.success,
      );

      // Close BottomSheet
      Navigator.pop(Get.context!);

      // clearForm();
      clearForm();

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

  void editStockAdjustment(BuildContext context, int stockAdjustmentId) async{
    try{

      final stockAdjustment = await service.getStockAdjustmentById(stockAdjustmentId); 
      selectedProduct.value = stockAdjustment["product"]["id"].toString();
      selectedWarehouse.value = stockAdjustment["warehouse"]["id"].toString();
      selectedAdjustmentType.value = stockAdjustment["adjustment_type"];
      adjustmentQtyController.text = stockAdjustment["qty"].toString();
      currentQtyController.text =
      stockAdjustment["previous_qty"].toString();
      newQtyController.text = stockAdjustment["new_qty"].toString();
      reasonController.text = stockAdjustment["reason"];
      referenceController.text = stockAdjustment["reference_no"];

      AppBottomSheets.show(
        context,
        child: EditStockAdjustmentTypeWidget(
          stockAdjustmentId: stockAdjustment["id"],
        )
      );
    }catch(e){
      ToastWidget.show(
        message: e.toString(),
        type: ToastType.error,
      );
    }
  }

  void onUpdateStockAdjustment(BuildContext context, int stockAdjustmentId) async{
    try{
      isLoading.value = true;
      final data = {
        'product_id': selectedProduct.value,
        'warehouse_id': selectedWarehouse.value,
        'adjustment_type': selectedAdjustmentType.value,
        'user_id': storage.lastUserLoginRead["user"]["id"],
        'qty': adjustmentQtyController.text,
        'previous_qty': currentQtyController.text,
        'new_qty': newQtyController.text,
        'reason': reasonController.text,
        'reference_no': referenceController.text
      };

      await service.updateStockAdjustment(stockAdjustmentId, data);

      // Refresh category list
      await getStockAdjustments();

      ToastWidget.show(
        message: "Stock adjustment updated successfully".tr,
        type: ToastType.success,
      );

      // Close BottomSheet
      Navigator.pop(Get.context!);

      // clearForm();
      clearForm();
    }catch(e){
      ToastWidget.show(
        message: e.toString(),
        type: ToastType.error,
      );
    }finally{
      isLoading.value = false;
    }
  }

  void onDeleteStockAdjustment(int stockAdjustmentId, BuildContext context) async{
    showConfirmDialog(
      context: context,
      message: "Do you want to delete this stock adjustment?".tr,
      onConfirm: () async {
        try{
          await service.deleteStockAdjustment(stockAdjustmentId);

          // Refresh category list
          await getStockAdjustments();

          ToastWidget.show(
            message: "Stock adjustment deleted successfully".tr,
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

  void gotoStockAdjustmentDetailScreen(Map<String, dynamic> stockAdjustment){
    Get.toNamed(AppRoutes.stockAdjustmentDetail, arguments: stockAdjustment);
  }


  @override
  void onClose() {
    adjustmentQtyController.removeListener(calculateNewQty);
    adjustmentQtyController.dispose();
    currentQtyController.dispose();
    newQtyController.dispose();
    referenceController.dispose();
    reasonController.dispose();
    super.onClose();
  }

}