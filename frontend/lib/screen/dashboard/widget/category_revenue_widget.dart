import 'package:flutter/material.dart';
import 'package:frontend/screen/home/widget/home_tab_layout.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class CategoryRevenueWidget extends StatelessWidget {
  const CategoryRevenueWidget({super.key, required this.data});
  final List<Map<String, dynamic>> data;

  @override
  Widget build(BuildContext context) => HomeSectionCard(
    title: 'Revenue by Category',
    child: data.isEmpty
        ? Padding(
            padding: const EdgeInsets.symmetric(vertical: 64),
            child: Text(
              'No category revenue yet'.tr,
              textAlign: TextAlign.center,
            ),
          )
        : Semantics(
            label:
                '${'Revenue by Category'.tr}: ${data.map((item) => '${item['category']}: ${item['amount'] ?? 0}').join(', ')}',
            child: SizedBox(
              height: 300,
              child: SfCircularChart(
                legend: Legend(
                  isVisible: true,
                  position: LegendPosition.bottom,
                  overflowMode: LegendItemOverflowMode.wrap,
                  textStyle: Theme.of(context).textTheme.bodyMedium,
                ),
                tooltipBehavior: TooltipBehavior(
                  enable: true,
                  header: 'Amount'.tr,
                ),
                series: <CircularSeries>[
                  DoughnutSeries<Map<String, dynamic>, String>(
                    dataSource: data,
                    innerRadius: '72%',
                    animationDuration: MediaQuery.disableAnimationsOf(context)
                        ? 0
                        : 300,
                    xValueMapper: (item, _) =>
                        item['category']?.toString() ?? 'Unknown'.tr,
                    yValueMapper: (item, _) =>
                        double.tryParse(item['amount']?.toString() ?? '') ?? 0,
                    enableTooltip: true,
                  ),
                ],
              ),
            ),
          ),
  );
}
