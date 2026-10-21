import 'package:flutter/material.dart';
import 'package:frontend/constants/constant.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class StockInChartWidget extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const StockInChartWidget({super.key, required this.data});

  static const List<String> _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  String _label(Map<String, dynamic> item) {
    final month = int.tryParse(item['sale_month']?.toString() ?? '');
    if (month == null || month < 1 || month > 12) return '';

    final name = _months[month - 1];
    final year = int.tryParse(item['sale_year']?.toString() ?? '');
    if (year == null) return name;

    return '$name ${year.toString().substring(2)}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(0),
      color: titleColor,
      child: SizedBox(
        height: 300,
        child: data.isEmpty
            ? const Center(child: Text('No sales data yet'))
            : SfCartesianChart(
                title: ChartTitle(
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
                    xValueMapper: (item, _) => _label(item),
                    yValueMapper: (item, _) =>
                        double.tryParse(item['amount']?.toString() ?? '') ?? 0,
                    dataLabelSettings: const DataLabelSettings(
                      isVisible: true,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
