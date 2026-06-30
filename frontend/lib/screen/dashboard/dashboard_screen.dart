import 'package:flutter/material.dart';
import 'package:frontend/screen/dashboard/widget/card_kpi_widget.dart';
import 'package:frontend/screen/dashboard/widget/category_revenue_widget.dart';
import 'package:frontend/screen/dashboard/widget/stock_in_chart_widget.dart';
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    CardKpiWidget(
                      icon: Icons.wallet,
                      title: "TOTAL STOCK VALUE",
                      value: "\$ 1,000,00",
                      status: "Low Stock",
                    ),
                    CardKpiWidget(
                      icon: Icons.warning_amber_outlined,
                      title: "LOW STOCK ALERTS",
                      value: "42 Items",
                      status: "High Priority",
                    ),
                    CardKpiWidget(
                      icon: Icons.compare_arrows_rounded,
                      title: "STOCK MOVEMENT",
                      value: "8.4x",
                    ),
                      
                    SizedBox(height: 20),
                    StockInChartWidget(),
                    CategoryRevenueWidget(),
                  ],
                ),
              ),
            ),
          )
      ),
    );
  }
}