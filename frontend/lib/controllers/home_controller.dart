import 'package:flutter/material.dart';
import 'package:frontend/controllers/dashboard_controller.dart';
import 'package:frontend/global.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/screen/dashboard/dashboard_screen.dart';
import 'package:frontend/screen/home/home_content.dart';
import 'package:frontend/screen/manage/manage_screen.dart';
import 'package:frontend/screen/profile/profile_screen.dart';
import 'package:frontend/screen/report/report_screen.dart';
import 'package:frontend/services/main_service/home_service.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  HomeController({HomeService? homeService})
    : service = homeService ?? HomeService();

  RxInt selectedIndex = 0.obs;
  final PageController pageController = PageController();

  final Rxn<Map<String, dynamic>> welcomePage = Rxn<Map<String, dynamic>>();

  final HomeService service;
  final purchasesLoading = true.obs;
  final salesLoading = true.obs;
  final purchasesError = false.obs;
  final salesError = false.obs;

  @override
  void onInit() {
    super.onInit();
    getRecentPurchase();
    getRecentSale();
    onWelcome();
  }

  bool get canViewReport => storage.hasRole('Admin');

  @override
  void onReady() {
    super.onReady();
    final tab = Get.arguments;
    if (tab is int && tab >= 0 && tab < (canViewReport ? 5 : 4)) {
      onTabChanged(tab);
    }
  }

  final RxList<Map<String, dynamic>> recentPurchaseList =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> recentSaleList =
      <Map<String, dynamic>>[].obs;

  Future<void> getRecentPurchase() async {
    purchasesLoading.value = true;
    purchasesError.value = false;
    try {
      final resp = await service.getRecentPrucases();
      recentPurchaseList.value = List<Map<String, dynamic>>.from(resp as List);
    } catch (_) {
      purchasesError.value = true;
    } finally {
      purchasesLoading.value = false;
    }
  }

  Future<void> getRecentSale() async {
    salesLoading.value = true;
    salesError.value = false;
    try {
      final resp = await service.getRecentSales();
      recentSaleList.value = List<Map<String, dynamic>>.from(resp as List);
    } catch (_) {
      salesError.value = true;
    } finally {
      salesLoading.value = false;
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
      pageController.jumpToPage(index);

      // Refresh the dashboard whenever the user opens its tab.
      if (index == 1) {
        Get.find<DashboardController>().getDashboardData();
      }
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
    if (canViewReport) ReportScreen(),
    ProfileScreen(),
  ];

  // quick action
  void gotoCategory() {
    Get.toNamed(AppRoutes.category);
  }

  void gotoProduct() {
    Get.toNamed(AppRoutes.product);
  }

  void gotoSupplier() {
    Get.toNamed(AppRoutes.supplier);
  }

  void gotoSale() {
    Get.toNamed(AppRoutes.sale);
  }
}
