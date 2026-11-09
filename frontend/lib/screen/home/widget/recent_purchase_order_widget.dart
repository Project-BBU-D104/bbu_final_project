import 'package:flutter/material.dart';
import 'package:frontend/controllers/home_controller.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/screen/home/widget/recent_orders_widget.dart';
import 'package:get/get.dart';

class RecentStockInWidget extends StatelessWidget {
  RecentStockInWidget({super.key});
  final controller = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) => Obx(
    () => RecentOrdersWidget(
      title: 'Recent Purchase Order',
      items: controller.recentPurchaseList.toList(),
      isPurchase: true,
      loading: controller.purchasesLoading.value,
      hasError: controller.purchasesError.value,
      onRetry: controller.getRecentPurchase,
      onViewAll: () => Get.toNamed(AppRoutes.purchase),
    ),
  );
}
