import 'package:flutter/material.dart';
import 'package:frontend/controllers/dashboard_controller.dart';
import 'package:frontend/screen/dashboard/widget/card_kpi_widget.dart';
import 'package:frontend/screen/dashboard/widget/category_revenue_widget.dart';
import 'package:frontend/screen/dashboard/widget/low_stock_widget.dart';
import 'package:frontend/screen/dashboard/widget/stock_in_chart_widget.dart';
import 'package:frontend/screen/dashboard/widget/top_proudct_widget.dart';
import 'package:frontend/screen/home/widget/home_tab_layout.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctr = Get.find<DashboardController>();
    return SafeArea(
      child: Obx(() {
        final kpi = ctr.kpiData;
        final hasData =
            kpi.isNotEmpty ||
            ctr.monthlySaleList.isNotEmpty ||
            ctr.revenueByCategory.isNotEmpty ||
            ctr.lowstockProducts.isNotEmpty ||
            ctr.topProducts.isNotEmpty;
        return RefreshIndicator(
          onRefresh: ctr.getDashboardData,
          child: HomeTabLayout(
            title: 'Dashboard',
            subtitle: 'A clear view of your inventory and sales.',
            action: OutlinedButton.icon(
              onPressed: ctr.isLoading.value ? null : ctr.getDashboardData,
              icon: const Icon(Icons.refresh),
              label: Text('Refresh'.tr),
              style: OutlinedButton.styleFrom(minimumSize: const Size(0, 48)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (ctr.isLoading.value) ...[
                  LinearProgressIndicator(
                    semanticsLabel: 'Loading inventory data...'.tr,
                  ),
                  const SizedBox(height: 24),
                ],
                if (ctr.errorMessage.value.isNotEmpty) ...[
                  HomeSectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.cloud_off_outlined,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Failed to load dashboard'.tr,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          (hasData
                                  ? 'Showing previously loaded data. Please try again.'
                                  : 'Check your connection and try again.')
                              .tr,
                        ),
                        const SizedBox(height: 16),
                        TextButton.icon(
                          onPressed: ctr.isLoading.value
                              ? null
                              : ctr.getDashboardData,
                          icon: const Icon(Icons.refresh),
                          label: Text('Retry'.tr),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                if (hasData ||
                    (!ctr.isLoading.value &&
                        ctr.errorMessage.value.isEmpty)) ...[
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final columns = constraints.maxWidth < 760 ? 1 : 3;
                      final lowStock =
                          num.tryParse(
                            kpi['low_stock_alerts']?.toString() ?? '',
                          ) ??
                          0;
                      final cards = [
                        CardKpiWidget(
                          icon: Icons.account_balance_wallet_outlined,
                          title: 'Total stock value',
                          value: NumberFormat('#,##0.00').format(
                            num.tryParse(
                                  kpi['total_stock_value']?.toString() ?? '',
                                ) ??
                                0,
                          ),
                          status: 'Inventory',
                        ),
                        CardKpiWidget(
                          icon: Icons.warning_amber_outlined,
                          title: 'Low stock alerts',
                          value: lowStock.toString(),
                          status: lowStock > 0 ? 'Needs Attention' : 'All Good',
                        ),
                        CardKpiWidget(
                          icon: Icons.compare_arrows_rounded,
                          title: 'Stock movement',
                          value: (kpi['stock_movement'] ?? 0).toString(),
                          status: 'This Month',
                        ),
                      ];
                      return Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          for (final card in cards)
                            SizedBox(
                              width:
                                  (constraints.maxWidth - 16 * (columns - 1)) /
                                  columns,
                              child: card,
                            ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Amounts are shown as recorded; currency conversion is not applied.'
                        .tr,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 24),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final wide = constraints.maxWidth >= 900;
                      final children = <Widget>[
                        StockInChartWidget(data: ctr.monthlySaleList.toList()),
                        CategoryRevenueWidget(
                          data: ctr.revenueByCategory.toList(),
                        ),
                        LowStockWidget(products: ctr.lowstockProducts.toList()),
                        TopProudctWidget(products: ctr.topProducts.toList()),
                      ];
                      return Wrap(
                        spacing: 24,
                        runSpacing: 24,
                        children: [
                          for (final child in children)
                            SizedBox(
                              width: wide
                                  ? (constraints.maxWidth - 24) / 2
                                  : constraints.maxWidth,
                              child: child,
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      }),
    );
  }
}
