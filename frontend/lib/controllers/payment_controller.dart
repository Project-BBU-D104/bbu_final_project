import 'package:frontend/services/main_service/sale_payment_service.dart';
import 'package:frontend/widget/toast_widget.dart';
import 'package:get/get.dart';

class PaymentController extends GetxController{

  final SalePaymentService service = SalePaymentService();
  var isLoading = false.obs;

  var paymentList = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    onGetPaymentList();
  }

  Future<void> onGetPaymentList() async{
      try{
        isLoading.value = true;

        final resp = await service.getPayments();

        if(resp is List){
          paymentList.value = List<Map<String, dynamic>>.from(resp);
        }
        print(paymentList);

      }catch(e){
        ToastWidget.show(
          message: e.toString(),
          type: ToastType.error,
        );
      }finally{
        isLoading.value = false;
      }
  }
  
}