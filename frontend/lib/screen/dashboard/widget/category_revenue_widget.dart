import 'package:flutter/material.dart';
import 'package:frontend/constants/constant.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class CategoryRevenueWidget extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const CategoryRevenueWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final NumberFormat money = NumberFormat('#,##0.00');

    return Card(
      color: titleColor,
      margin: const EdgeInsets.all(0),
      child: SizedBox(
        height: 300,
        child: data.isEmpty
            ? const Center(child: Text('No category revenue yet'))
            : SfCircularChart(
                title: ChartTitle(
                  text: 'Revenue by Category',
                  alignment: ChartAlignment.near,
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                legend: const Legend(
                  isVisible: true,
                  position: LegendPosition.bottom,
                ),
                tooltipBehavior: TooltipBehavior(enable: true),
                series: <CircularSeries>[
                  DoughnutSeries<Map<String, dynamic>, String>(
                    dataSource: data,
                    xValueMapper: (item, _) =>
                        item['category']?.toString() ?? 'Unknown',
                    yValueMapper: (item, _) =>
                        double.tryParse(item['amount']?.toString() ?? '') ?? 0,
                    dataLabelMapper: (item, _) =>
                        money.format(double.tryParse(
                              item['amount']?.toString() ?? '',
                            ) ??
                            0),
                    dataLabelSettings: const DataLabelSettings(
                      isVisible: true,
                    ),
                    enableTooltip: true,
                  ),
                ],
              ),
      ),
    );
  }
}
