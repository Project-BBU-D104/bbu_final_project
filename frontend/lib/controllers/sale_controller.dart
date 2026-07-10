import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/services/main_service/sale_service.dart';
import 'package:frontend/widget/toast_widget.dart';
import 'package:get/get.dart';

class SaleController extends GetxController{

  var isLoading = false.obs;
  final saleList = <Map<String, dynamic>> [].obs;

  final SaleService service = SaleService();

  @override
  void onInit() {
    super.onInit();

    onGetSaleList();
  }

  void onNewSale(){
    Get.toNamed(AppRoutes.sale);
  }

  void onCurrentSale(){
    Get.toNamed(AppRoutes.currentSale);
  }

  void onPayment(){
    Get.toNamed(AppRoutes.saleWithPayment);
  }

  void onConfirm(){
    Get.offNamed(AppRoutes.paymentSuccess);
  }

  void gotoSaleListDetail(){
    Get.toNamed(AppRoutes.saleListDetail);
  }

  Future <void> onGetSaleList() async{
    try{
      isLoading.value = true;

    final resp =  await service.getSales();

      if(resp is List){
        saleList.value = List<Map<String, dynamic>>.from(resp);
      }
      print(saleList);
    }catch(e){
      ToastWidget.show(
        message: e.toString(),
        type: ToastType.error,
      );
    }finally{
      isLoading.value = false;
    }
  }  
  
  void onDeleteSale(){
    print("Delete sale");
  }
}