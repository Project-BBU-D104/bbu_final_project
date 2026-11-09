import 'package:flutter/material.dart';
import 'package:frontend/controllers/home_controller.dart';
import 'package:frontend/screen/home/desktop_app_shell.dart';
import 'package:get/get.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});
  final controller = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final destinations = [
      (label: 'Home', icon: Icons.home_outlined, selected: Icons.home),
      (
        label: 'Dashboard',
        icon: Icons.dashboard_outlined,
        selected: Icons.dashboard,
      ),
      (
        label: 'Manage',
        icon: Icons.grid_view_outlined,
        selected: Icons.grid_view_rounded,
      ),
      if (controller.canViewReport)
        (
          label: 'Report',
          icon: Icons.receipt_long_outlined,
          selected: Icons.receipt_long,
        ),
      (label: 'Profile', icon: Icons.person_outline, selected: Icons.person),
    ];
    return Scaffold(
      body: SafeArea(
        child: PageView(
          controller: controller.pageController,
          physics: const NeverScrollableScrollPhysics(),
          onPageChanged: controller.onPageChanged,
          children: controller.tabPages,
        ),
      ),
      bottomNavigationBar: DesktopAppShell.isVisible(context)
          ? null
          : Obx(
              () => NavigationBar(
                backgroundColor: colors.surface,
                indicatorColor: colors.primary.withValues(alpha: 0.12),
                selectedIndex: controller.selectedIndex.value,
                onDestinationSelected: controller.onTabChanged,
                labelBehavior:
                    NavigationDestinationLabelBehavior.onlyShowSelected,
                destinations: [
                  for (final item in destinations)
                    NavigationDestination(
                      icon: Icon(item.icon),
                      selectedIcon: Icon(item.selected, color: colors.primary),
                      label: item.label.tr,
                    ),
                ],
              ),
            ),
    );
  }
}
