import 'package:flutter/material.dart';
import 'package:frontend/constants/constant.dart';
import 'package:frontend/controllers/home_controller.dart';
import 'package:get/get.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final controller = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: PageView(
          controller: controller.pageController,
          physics: const NeverScrollableScrollPhysics(),
          onPageChanged: controller.onPageChanged,
          children: controller.tabPages,
        ),
      ),
      bottomNavigationBar: Obx(() {
        return NavigationBar(
          backgroundColor: titleColor,
          selectedIndex: controller.selectedIndex.value,
          onDestinationSelected: controller.onTabChanged,
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              label: 'Home'.tr,
            ),
            NavigationDestination(
              icon: Icon(Icons.dashboard_customize_outlined),
              label: 'Dashboard'.tr,
            ),
            NavigationDestination(
              icon: Icon(Icons.shopping_bag_outlined),
              label: 'Manage'.tr,
            ),
            NavigationDestination(
              icon: Icon(Icons.person_2_outlined),
              label: 'Profile'.tr,
            ),
          ],
        );
      }),
    );
  }
}
