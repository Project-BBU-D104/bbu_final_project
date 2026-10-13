import 'package:flutter/material.dart';
import 'package:frontend/controllers/product_controller.dart';
import 'package:frontend/controllers/purchase/purchase_controller.dart';
import 'package:frontend/screen/purchase_payment/widget/add_purchase_payment_widget.dart';
import 'package:frontend/services/main_service/purchase/purchase_payment_service.dart';
import 'package:frontend/widget/bottom_sheets.dart';
import 'package:frontend/widget/toast_widget.dart';
import 'package:get/get.dart';

class PurchasePaymentController extends GetxController{
  
  final PurchasePaymentService service = PurchasePaymentService();
  final isLoading = false.obs;
  final purchasePaymentList = <Map<String, dynamic>>[].obs;

  final purchaseCtr = Get.put(PurchaseController());

  final selectedPaymentType = RxnString();
  final selectedPurchase = RxnString();


  @override
  void onInit() {
    onGetPaymentList();
     Get.find<ProductController>().getProducts();
    super.onInit();
  }

  Future<void> onGetPaymentList() async{
    try{
      isLoading.value = true;

      final resp = await service.getPurchasePayments();

      if(resp is List){
        purchasePaymentList.value = List<Map<String, dynamic>>.from(resp);
      }

      // print(purchasePaymentList);

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

  Future<void> addPurchasePayment(BuildContext context) async{
    AppBottomSheets.show(
      context,
      child: AddPurchasePaymentWidget(),
    );
  }
}