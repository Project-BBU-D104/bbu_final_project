import 'package:flutter/material.dart';
import 'package:frontend/global.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/screen/dashboard/dashboard_screen.dart';
import 'package:frontend/screen/home/home_content.dart';
import 'package:frontend/screen/manage/manage_screen.dart';
import 'package:frontend/screen/profile/profile_screen.dart';
import 'package:frontend/services/main_service/home_service.dart';
import 'package:get/get.dart';

class HomeController extends GetxController{

  RxInt selectedIndex = 0.obs;
  final PageController pageController = PageController();

  final Rxn<Map<String, dynamic>> welcomePage = Rxn<Map<String, dynamic>>();

    final HomeService service = HomeService();

  @override
  void onInit() {
    super.onInit();
    getRecentPurchase();
    getRecentSale();
    onWelcome();
  }

  final RxList<Map<String, dynamic>> recentPurchaseList = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> recentSaleList = <Map<String, dynamic>>[].obs;

  Future<void> getRecentPurchase() async {
    final resp = await service.getRecentPrucases();

    if (resp is List) {
      recentPurchaseList.value =
          List<Map<String, dynamic>>.from(resp);
    }
  }

  Future<void> getRecentSale() async {
    final resp = await service.getRecentSales();

    if (resp is List) {
      recentSaleList.value =
          List<Map<String, dynamic>>.from(resp);
    }
  }
  
  void onWelcome() {
    final welcome = storage.lastUserLoginRead;

    if (welcome.isEmpty) return;

    welcomePage.value = welcome["user"] as Map<String, dynamic>?;
}

  void onTabChanged(int index) {
    if (index != selectedIndex.value) {
      selectedIndex.value = index;
      pageController.jumpToPage(
        index,
      );
    }
  }

  void onPageChanged(int index) {
    selectedIndex.value = index;
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  List<Widget> get tabPages => [
    HomeContent(),
    DashboardScreen(),
    ManageScreen(),
    ProfileScreen(),
  ];

  // quick action
  void gotoCategory(){
    Get.toNamed(AppRoutes.category);
  }
  void gotoProduct(){
    Get.toNamed(AppRoutes.product);
  }
  void gotoSupplier(){
    Get.toNamed(AppRoutes.supplier);
  }
  void gotoStock(){
    Get.toNamed(AppRoutes.stockMovement);
  }
  void gotoSale(){
    Get.toNamed(AppRoutes.sale);
  }

}