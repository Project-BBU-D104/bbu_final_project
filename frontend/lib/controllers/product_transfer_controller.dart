import 'package:flutter/material.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/screen/stock/stock_transfer/widget/add_stock_transfer_widget.dart';
import 'package:frontend/screen/stock/stock_transfer/widget/edit_stock_transfer_widget.dart';
import 'package:frontend/services/main_service/product_transfer_service.dart';
import 'package:frontend/widget/bottom_sheets.dart';
import 'package:frontend/widget/toast_widget.dart';
import 'package:get/get.dart';

class ProductTransferController extends GetxController{

  var selectedDate = Rxn<DateTime>();
  var isLoading = false.obs;

  final ProductTransferService service = ProductTransferService();
  final stockTransfer = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    onGetProductTransferList();
    super.onInit();
  }

  Future<void> onGetProductTransferList() async{
    try{
      isLoading.value = true;

      final resp = await service.getProductTransfers();

      if(resp is List){
        stockTransfer.value = List<Map<String, dynamic>>.from(resp);
      }

      print(stockTransfer);
    }catch(e){
      ToastWidget.show(
        message: e.toString(),
        type: ToastType.error,
      );
    }finally{
      isLoading.value = false;
    }
  }

  Future<void> pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      selectedDate.value = picked;
    }
  }

  String get formattedDate {
    if (selectedDate.value == null) return "Select Date".tr;
    return selectedDate.value!.toString().split(" ")[0];
  }

  void addStockTransfer(BuildContext context){
    AppBottomSheets.show(
      context,
      child: AddStockTransferWidget()
    );
  }

  void gotoStockTransferDetail(Map<String, dynamic> stockTransfer){
    Get.toNamed(AppRoutes.stockTransferDetail, arguments: stockTransfer);
  }

  void editStockTransfer(BuildContext context, Map<String, dynamic> stockTransfer){
    AppBottomSheets.show(
      context,
      child: EditStockTransferWidget()
    );
  }

  void onDeleteStockTransfer(int id){
    print("Delete stock transfer with ID: $id");
  }
}