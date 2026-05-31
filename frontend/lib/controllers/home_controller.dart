import 'package:flutter/material.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/screen/dashboard/dashboard_screen.dart';
import 'package:frontend/screen/home/home_content.dart';
import 'package:frontend/screen/manage/manage_screen.dart';
import 'package:frontend/screen/profile/profile_screen.dart';
import 'package:get/get.dart';

class HomeController extends GetxController{


  RxInt selectedIndex = 0.obs;
  final PageController pageController = PageController();

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
}