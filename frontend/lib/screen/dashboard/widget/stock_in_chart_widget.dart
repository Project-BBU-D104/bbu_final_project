import 'package:flutter/material.dart';
import 'package:frontend/screen/home/widget/home_tab_layout.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class StockInChartWidget extends StatelessWidget {
  const StockInChartWidget({super.key, required this.data});
  final List<Map<String, dynamic>> data;
  static const _months = [
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
    final year = int.tryParse(item['sale_year']?.toString() ?? '');
    if (month == null || month < 1 || month > 12) return '';
    return '${_months[month - 1].tr} ${year ?? ''}'.trim();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return HomeSectionCard(
      title: 'Monthly Sales',
      child: data.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 64),
              child: Text('No sales data yet'.tr, textAlign: TextAlign.center),
            )
          : Semantics(
              label:
                  '${'Monthly Sales'.tr}: ${data.map((item) => '${_label(item)}: ${item['amount'] ?? 0}').join(', ')}',
              child: SizedBox(
                height: 300,
                child: SfCartesianChart(
                  plotAreaBorderWidth: 0,
                  primaryXAxis: CategoryAxis(
                    labelStyle: theme.textTheme.bodySmall,
                    majorGridLines: const MajorGridLines(width: 0),
                  ),
                  primaryYAxis: NumericAxis(
                    labelStyle: theme.textTheme.bodySmall,
                    numberFormat: NumberFormat.compact(),
                    majorGridLines: MajorGridLines(color: theme.dividerColor),
                  ),
                  tooltipBehavior: TooltipBehavior(
                    enable: true,
                    header: 'Amount'.tr,
                  ),
                  series: <CartesianSeries>[
                    ColumnSeries<Map<String, dynamic>, String>(
                      name: 'Monthly Sales'.tr,
                      dataSource: data,
                      color: theme.colorScheme.primary,
                      animationDuration: MediaQuery.disableAnimationsOf(context)
                          ? 0
                          : 300,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(6),
                      ),
                      xValueMapper: (item, _) => _label(item),
                      yValueMapper: (item, _) =>
                          double.tryParse(item['amount']?.toString() ?? '') ??
                          0,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
