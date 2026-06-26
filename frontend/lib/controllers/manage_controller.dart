import 'package:frontend/routes/app_routes.dart';
import 'package:get/get.dart';

class ManageController extends GetxController{

  void goToProduct(){
    Get.toNamed(AppRoutes.product);
  }
  void goToCategory(){
    Get.toNamed(AppRoutes.category);
  }
  void goToPurchase(){
    Get.toNamed(AppRoutes.purchase);
  }
  void goToSupplier(){
    Get.toNamed(AppRoutes.supplier);
  }
  void goToCustomer(){
    Get.toNamed(AppRoutes.customer);
  }
  void goToStockMovement(){
    Get.toNamed(AppRoutes.stockMovement);
  }
  void goToStockAdjustment(){
    Get.toNamed(AppRoutes.stockAdjustment);
  }
  void goToStockTransfer(){
    Get.toNamed(AppRoutes.stockTransfer);
  }
  void goToSale(){
    Get.toNamed(AppRoutes.sale);
  }
  void goToSaleList(){
    Get.toNamed(AppRoutes.saleList);
  }
  void goToSalePayment(){
    Get.toNamed(AppRoutes.salePayment);
  }
  void goToRole(){
    Get.toNamed(AppRoutes.role);
  }
  void goToUser(){
    Get.toNamed(AppRoutes.user);
  }
  void goToWareHouse(){
    Get.toNamed(AppRoutes.warehouse);
  }
}