import 'package:frontend/routes/app_routes.dart';
import 'package:get/get.dart';

class SaleController extends GetxController{
  
  void onNewSale(){
    Get.toNamed(AppRoutes.sale);
  }
}