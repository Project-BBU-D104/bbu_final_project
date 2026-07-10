import 'package:flutter/material.dart';
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

  @override
  void onInit() async{
    await getStockAdjustments();
    super.onInit();
  }
  
  final stockAdjustmentList = <Map<String, dynamic>> [].obs;

  Future<void> getStockAdjustments() async{
    try{
      isLoading.value = true;

      final resp = await service.getStockAdjustments();

      if(resp is List){
        stockAdjustmentList.value = List<Map<String, dynamic>>.from(resp);
      }
      print(stockAdjustmentList);
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
    AppBottomSheets.show(
      context,
      child: AddStockAdjustmentWidget()
    );
  }

  void editStockAdjustment(BuildContext context, Map<String, dynamic> stockAdjustment){
    AppBottomSheets.show(
      context,
      child: EditStockAdjustmentTypeWidget()
    );
  }

  void onDeleteStockAdjustment(int id){
    print("Delete stock adjustment with ID: $id");
  }

  void gotoStockAdjustmentDetailScreen(Map<String, dynamic> stockAdjustment){
    Get.toNamed(AppRoutes.stockAdjustmentDetail, arguments: stockAdjustment);
  }
}