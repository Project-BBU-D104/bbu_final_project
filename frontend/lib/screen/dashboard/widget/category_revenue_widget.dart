import 'package:flutter/material.dart';
import 'package:frontend/constants/constant.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class CategoryRevenueWidget extends StatelessWidget {
  const CategoryRevenueWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> data = [
      {"category": "Coffee", "amount": 2500},
      {"category": "Tea", "amount": 1200},
      {"category": "Cake", "amount": 800},
      {"category": "Snack", "amount": 500},
    ];

    return Card(
      color: titleColor,
      child: SizedBox(
        height: 300,
        child: SfCircularChart(
          title: ChartTitle(text: 'Revenue by Category',
          alignment: ChartAlignment.near,
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          )
          ),
          legend: const Legend(
            isVisible: true,
            position: LegendPosition.bottom,
          ),
          tooltipBehavior: TooltipBehavior(enable: true),
          series: <CircularSeries>[
            DoughnutSeries<Map<String, dynamic>, String>(
              dataSource: data,
              xValueMapper: (item, _) => item["category"],
              yValueMapper: (item, _) => item["amount"],
              dataLabelMapper: (item, _) =>
                  item["amount"].toString(),
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