import 'package:flutter/material.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/screen/purchases/widget/add_purchase_widget.dart';
import 'package:frontend/services/main_service/purchase_service.dart';
import 'package:frontend/widget/bottom_sheets.dart';
import 'package:frontend/widget/toast_widget.dart';
import 'package:get/get.dart';

class PurchaseController extends GetxController{
  final PurchaseService service = PurchaseService();
  var isLoading = false.obs;
  final purchaseList = <Map<String, dynamic>> [].obs;

  @override
  void onInit() {
    super.onInit();
    onGetPurchaseList();
  }
  
  Future<void> onGetPurchaseList() async{
    try{
      isLoading.value = true;

      final resp = await service.getPurchases();

      if(resp is List){
        purchaseList.value = List<Map<String, dynamic>>.from(resp);
      }

      print(purchaseList);
    }catch(e){
      ToastWidget.show(
        message: e.toString(),
        type: ToastType.error,
      );
    }finally{
      isLoading.value = false;
    }
  }


  void addPurchase(BuildContext context){
    AppBottomSheets.show(
      context,
      child: AddPurchaseWidget()
    );
  }

  void gotoPurchaseDetail(Map<String, dynamic> purchase){
    Get.toNamed(AppRoutes.purchaseDetail, arguments: purchase);
  }

  void editPurchase(BuildContext context, Map<String, dynamic> purchase){
    // AppBottomSheets.show(
    //   context,
    //   child: EditPurchaseWidget(purchase: purchase)
    // );
  }

  void deletePurchase(int purchaseId){
    // Implement the logic to delete the purchase with the given purchaseId
  }
}