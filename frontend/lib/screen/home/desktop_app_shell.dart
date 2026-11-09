import 'package:flutter/material.dart';
import 'package:frontend/constants/constant.dart';
import 'package:frontend/controllers/home_controller.dart';
import 'package:frontend/global.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:get/get.dart';

/// Surrounds the navigator so pushed pages keep the same desktop sidebar.
class DesktopAppShell extends StatelessWidget {
  const DesktopAppShell({super.key, required this.route, required this.child});

  final String route;
  final Widget child;

  static bool isVisible(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_SidebarScope>() != null;

  @override
  Widget build(BuildContext context) {
    final path = Uri.tryParse(route)?.path ?? route;
    if (MediaQuery.sizeOf(context).width < 840 ||
        path.isEmpty ||
        path == '/' ||
        path == AppRoutes.login ||
        path == AppRoutes.landing) {
      return child;
    }
    return _SidebarScope(
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        child: Row(
          children: [
            SafeArea(right: false, child: _AppSidebar(route: path)),
            const VerticalDivider(width: 1),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) => MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    size: Size(constraints.maxWidth, constraints.maxHeight),
                  ),
                  child: child,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarScope extends InheritedWidget {
  const _SidebarScope({required super.child});
  @override
  bool updateShouldNotify(_SidebarScope oldWidget) => false;
}

class _AppSidebar extends StatelessWidget {
  const _AppSidebar({required this.route});
  final String route;

  void _openTab(int index) {
    if (Get.isRegistered<HomeController>()) {
      final controller = Get.find<HomeController>();
      Get.until(
        (route) => route.settings.name == AppRoutes.home || route.isFirst,
      );
      if (Get.currentRoute == AppRoutes.home &&
          controller.pageController.hasClients) {
        controller.onTabChanged(index);
        return;
      }
    }
    Get.offAllNamed(AppRoutes.home, arguments: index);
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<HomeController>()
        ? Get.find<HomeController>()
        : null;
    final canViewReport = controller?.canViewReport ?? storage.hasRole('Admin');
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
      if (canViewReport)
        (
          label: 'Report',
          icon: Icons.receipt_long_outlined,
          selected: Icons.receipt_long,
        ),
    ];
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    Widget rail(int? selected) {
      final profileSelected = selected == destinations.length;
      return NavigationRail(
        backgroundColor: colors.surface,
        indicatorColor: colors.primary.withValues(alpha: 0.12),
        selectedIconTheme: IconThemeData(color: colors.primary),
        selectedLabelTextStyle: theme.textTheme.labelMedium?.copyWith(
          color: colors.primary,
        ),
        selectedIndex: selected != null && selected < destinations.length
            ? selected
            : null,
        onDestinationSelected: _openTab,
        labelType: NavigationRailLabelType.all,
        scrollable: true,
        trailingAtBottom: true,
        leading: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Image.asset(
            logoPath,
            width: 56,
            height: 56,
            fit: BoxFit.contain,
            semanticLabel: 'Logo'.tr,
          ),
        ),
        destinations: [
          for (final item in destinations)
            NavigationRailDestination(
              icon: Icon(item.icon),
              selectedIcon: Icon(item.selected),
              label: Text(item.label.tr),
            ),
        ],
        trailing: Padding(
          padding: const EdgeInsets.fromLTRB(8, 16, 8, 16),
          child: Semantics(
            selected: profileSelected,
            child: TextButton(
              onPressed: () => _openTab(destinations.length),
              style: TextButton.styleFrom(
                foregroundColor: profileSelected
                    ? colors.primary
                    : colors.onSurface,
                backgroundColor: profileSelected
                    ? colors.primary.withValues(alpha: 0.12)
                    : null,
                minimumSize: const Size(64, 64),
                padding: const EdgeInsets.all(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(profileSelected ? Icons.person : Icons.person_outline),
                  const SizedBox(height: 4),
                  Text('Profile'.tr, style: theme.textTheme.labelMedium),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return controller == null
        ? rail(null)
        : Obx(() {
            final selected = controller.selectedIndex.value;
            return rail(route == AppRoutes.home ? selected : null);
          });
  }
}
