import 'package:flutter/material.dart';
import 'package:frontend/constants/constant.dart';
import 'package:frontend/controllers/home_controller.dart';
import 'package:get/get.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final controller = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            // Desktop / Tablet NavigationRail
            if (!isMobile)
              Obx(() {
                return NavigationRail(
                  selectedIndex: controller.selectedIndex.value,
                  onDestinationSelected: controller.onTabChanged,
                  backgroundColor: titleColor,
                  labelType: NavigationRailLabelType.all,
                  destinations: [
                    NavigationRailDestination(
                      icon: Icon(Icons.home_outlined),
                      selectedIcon: Icon(Icons.home),
                      label: Text('Home'.tr),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.dashboard_customize_outlined),
                      selectedIcon: Icon(Icons.dashboard),
                      label: Text('Dashboard'.tr),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.shopping_bag_outlined),
                      selectedIcon: Icon(Icons.shopping_bag),
                      label: Text('Manage'.tr),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.receipt_long_outlined),
                      selectedIcon: Icon(Icons.receipt_long),
                      label: Text('Report'.tr),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.person_2_outlined),
                      selectedIcon: Icon(Icons.person),
                      label: Text('Profile'.tr),
                    ),
                  ],
                );
              }),

            // Page content
            Expanded(
              child: PageView(
                controller: controller.pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: controller.onPageChanged,
                children: controller.tabPages,
              ),
            ),
          ],
        ),
      ),

      // Mobile NavigationBar
      bottomNavigationBar: isMobile
          ? Obx(() {
              return NavigationBar(
                height: 60,
                backgroundColor: titleColor,
                selectedIndex: controller.selectedIndex.value,
                onDestinationSelected: controller.onTabChanged,
                labelBehavior:
                    NavigationDestinationLabelBehavior.alwaysHide,
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
                    icon: Icon(Icons.receipt_long_outlined),
                    label: 'Report'.tr,
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.person_2_outlined),
                    label: 'Profile'.tr,
                  ),
                ],
              );
            })
          : null,
    );
  }
}