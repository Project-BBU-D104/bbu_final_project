import 'package:flutter/material.dart';
import 'package:frontend/controllers/dashboard_controller.dart';
import 'package:frontend/screen/dashboard/widget/card_kpi_widget.dart';
import 'package:frontend/screen/dashboard/widget/category_revenue_widget.dart';
import 'package:frontend/screen/dashboard/widget/low_stock_widget.dart';
import 'package:frontend/screen/dashboard/widget/stock_in_chart_widget.dart';
import 'package:frontend/screen/dashboard/widget/top_proudct_widget.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static double _toDouble(dynamic value) {
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final ctr = Get.find<DashboardController>();

    return SafeArea(
      child: Scaffold(
        body: Obx(() {
          final kpi = ctr.kpiData;
          final hasData = kpi.isNotEmpty ||
              ctr.monthlySaleList.isNotEmpty ||
              ctr.revenueByCategory.isNotEmpty ||
              ctr.lowstockProducts.isNotEmpty ||
              ctr.topProducts.isNotEmpty;

          if (ctr.isLoading.value && !hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (ctr.errorMessage.value.isNotEmpty && !hasData) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cloud_off, size: 48),
                    const SizedBox(height: 12),
                    const Text(
                      'Failed to load dashboard',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      ctr.errorMessage.value,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: ctr.getDashboardData,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final stockValue = _toDouble(kpi['total_stock_value']);
          final lowStockAlerts =
              _toDouble(kpi['low_stock_alerts']).toInt();
          final stockMovement = _toDouble(kpi['stock_movement']).toInt();

          return RefreshIndicator(
            onRefresh: ctr.getDashboardData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    CardKpiWidget(
                      icon: Icons.wallet,
                      title: 'TOTAL STOCK VALUE',
                      value: NumberFormat.currency(
                        symbol: '\$',
                        decimalDigits: 2,
                      ).format(stockValue),
                      status: 'Inventory',
                    ),
                    CardKpiWidget(
                      icon: Icons.warning_amber_outlined,
                      title: 'LOW STOCK ALERTS',
                      value: '$lowStockAlerts Items',
                      status:
                          lowStockAlerts > 0 ? 'Needs Attention' : 'All Good',
                    ),
                    CardKpiWidget(
                      icon: Icons.compare_arrows_rounded,
                      title: 'STOCK MOVEMENT',
                      value: '$stockMovement Units',
                      status: 'This Month',
                    ),

                    const SizedBox(height: 20),
                    StockInChartWidget(data: ctr.monthlySaleList),
                    const SizedBox(height: 12),
                    CategoryRevenueWidget(data: ctr.revenueByCategory),
                    const SizedBox(height: 12),
                    LowStockWidget(products: ctr.lowstockProducts),
                    const SizedBox(height: 12),
                    TopProudctWidget(products: ctr.topProducts),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
