import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/services/main_service/sale_service.dart';
import 'package:get/get.dart';

class SaleController extends GetxController{

  final SaleService service = SaleService();

  @override
  void onInit() {
    super.onInit();
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
}