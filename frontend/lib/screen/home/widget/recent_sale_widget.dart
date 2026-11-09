import 'package:flutter/material.dart';
import 'package:frontend/controllers/home_controller.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/screen/home/widget/recent_orders_widget.dart';
import 'package:get/get.dart';

class RecentStockOutWidget extends StatelessWidget {
  RecentStockOutWidget({super.key});
  final controller = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) => Obx(
    () => RecentOrdersWidget(
      title: 'Recent Sale Order',
      items: controller.recentSaleList.toList(),
      isPurchase: false,
      loading: controller.salesLoading.value,
      hasError: controller.salesError.value,
      onRetry: controller.getRecentSale,
      onViewAll: () => Get.toNamed(AppRoutes.saleList),
    ),
  );
}
