import 'package:frontend/services/main_service/purchase/purchase_payment_service.dart';
import 'package:frontend/widget/toast_widget.dart';
import 'package:get/get.dart';

class PurchasePaymentController extends GetxController{
  
  final PurchasePaymentService service = PurchasePaymentService();
  final isLoading = false.obs;
  final purchasePaymentList = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    onGetPaymentList();
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
}