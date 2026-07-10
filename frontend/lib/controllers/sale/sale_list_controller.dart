import 'package:flutter/material.dart';
import 'package:frontend/helper/confirm_dialog_helper.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/services/main_service/sale_service.dart';
import 'package:frontend/widget/toast_widget.dart';
import 'package:get/get.dart';
class SaleListController extends GetxController{
  
  var isLoading = false.obs;
 @override
  void onInit() {
    super.onInit();

    onGetSaleList();
  }

  final SaleService service = SaleService();
    final saleList = <Map<String, dynamic>> [].obs;

  void gotoSaleListDetail(Map<String, dynamic> sale){
    Get.toNamed(AppRoutes.saleListDetail, arguments: sale);
  }


void onNewSale(){
    Get.toNamed(AppRoutes.sale);
  }


    Future <void> onGetSaleList() async{
    try{
      isLoading.value = true;

    final resp =  await service.getSales();

      if(resp is List){
        saleList.value = List<Map<String, dynamic>>.from(resp);
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

  Future<void> onDeleteSale(int saleId,BuildContext context) async{
    showConfirmDialog(
      context: context,
      message: "Do you want to delete this sale?".tr,
      onConfirm: () async {
        try{
          await service.deleteSale(saleId);

          Get.back();

          // Refresh category list
          await onGetSaleList();

          ToastWidget.show(
            message: "Category deleted successfully".tr,
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