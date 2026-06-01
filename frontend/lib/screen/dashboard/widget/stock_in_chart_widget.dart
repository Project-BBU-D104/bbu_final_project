import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class StockInChartWidget extends StatelessWidget {
  
  const StockInChartWidget({super.key});

  @override
  Widget build(BuildContext context) {
     final List<Map<String, dynamic>> data = [
      {"month": "Jan", "amount": 1200},
      {"month": "Feb", "amount": 1800},
      {"month": "Mar", "amount": 1500},
      {"month": "Apr", "amount": 2200},
      {"month": "May", "amount": 3000},
    ];
    return Card(
      child: SfCartesianChart(title: ChartTitle(
        text: 'Monthly Sales',
        alignment: ChartAlignment.near,
        textStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
        primaryXAxis: CategoryAxis(),
        tooltipBehavior: TooltipBehavior(enable: true),
        series: <CartesianSeries>[
          ColumnSeries<Map<String, dynamic>, String>(
            dataSource: data,
            xValueMapper: (item, _) => item["month"],
            yValueMapper: (item, _) => item["amount"],
            dataLabelSettings: const DataLabelSettings(
              isVisible: true,
            ),
          ),
        ],
      ),
    );
  }
}