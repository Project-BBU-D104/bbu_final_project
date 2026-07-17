import 'package:flutter/material.dart';
import 'package:frontend/helper/confirm_dialog_helper.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/screen/stock/stock_adjustment/widget/add_stock_adjustment_widget.dart';
import 'package:frontend/screen/stock/stock_adjustment/widget/edit_stock_adjustment_type_widget.dart';
import 'package:frontend/services/main_service/stock_adjustment_service.dart';
import 'package:frontend/widget/bottom_sheets.dart';
import 'package:frontend/widget/toast_widget.dart';
import 'package:get/get.dart';

class StockAdjustmentController extends GetxController{
  final StockAdjustmentService service = StockAdjustmentService();

  var isLoading = false.obs;

  final selectedProduct = RxnString();
  final selectedAdjustmentType = RxnString();
  final selectedWarehouse = RxnString();

  final stockAdjustmentList = <Map<String, dynamic>> [].obs;

  @override
  void onInit() async{
    await getStockAdjustments();
    super.onInit();
  }
  void clearForm(){

  selectedProduct.value = null;

  selectedWarehouse.value = null;

  selectedAdjustmentType.value = null;

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
    // 
  }

  void editStockAdjustment(BuildContext context, Map<String, dynamic> stockAdjustment){
    AppBottomSheets.show(
      context,
      child: EditStockAdjustmentTypeWidget()
    );
  }

  void onUpdateStockAdjustment(){
    print("Update stock adjustment");
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
}