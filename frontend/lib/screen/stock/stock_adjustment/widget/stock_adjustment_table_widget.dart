import 'package:flutter/material.dart';
import 'package:frontend/controllers/stock_adjustment_controller.dart';
import 'package:frontend/utils/date_formatter.dart';
import 'package:get/get.dart';

class StockAdjustmentTableWidget extends StatelessWidget {
  final List<Map<String, dynamic>> stockAdjustments;

  const StockAdjustmentTableWidget({super.key, required this.stockAdjustments});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = Get.find<StockAdjustmentController>();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.6)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: DataTable(
              headingRowHeight: 48,
              dataRowMinHeight: 56,
              dataRowMaxHeight: 72,
              horizontalMargin: 16,
              columnSpacing: 24,
              dividerThickness: 0.7,
              headingRowColor: WidgetStatePropertyAll(
                theme.colorScheme.primary.withValues(alpha: 0.05),
              ),
              columns: const [
                DataColumn(label: Text('Reference')),
                DataColumn(label: Text('Product')),
                DataColumn(label: Text('Warehouse')),
                DataColumn(label: Text('Type')),
                DataColumn(label: Text('Quantity'), numeric: true),
                DataColumn(label: Text('Date')),
              ],
              rows: stockAdjustments.map((adjustment) {
                final product = adjustment['product'] is Map
                    ? Map<String, dynamic>.from(adjustment['product'] as Map)
                    : <String, dynamic>{};
                final warehouse = adjustment['warehouse'] is Map
                    ? Map<String, dynamic>.from(adjustment['warehouse'] as Map)
                    : <String, dynamic>{};
                final isIncrease = adjustment['adjustment_type'] == 'increase';
                final quantityColor = isIncrease
                    ? Colors.green.shade700
                    : Colors.red.shade700;
                final openDetails = () =>
                    controller.gotoStockAdjustmentDetailScreen(adjustment);
                final createdAt = DateTime.tryParse(
                  adjustment['created_at']?.toString() ?? '',
                );

                return DataRow(
                  cells: [
                    DataCell(
                      SizedBox(
                        width: 130,
                        child: Text(
                          adjustment['reference_no']?.toString() ?? '-',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      onTap: openDetails,
                    ),
                    DataCell(
                      SizedBox(
                        width: 170,
                        child: Text(
                          product['name']?.toString() ?? '-',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      onTap: openDetails,
                    ),
                    DataCell(
                      SizedBox(
                        width: 150,
                        child: Text(
                          warehouse['name']?.toString() ?? '-',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      onTap: openDetails,
                    ),
                    DataCell(
                      Text(isIncrease ? 'Increase' : 'Decrease'),
                      onTap: openDetails,
                    ),
                    DataCell(
                      Text(
                        '${isIncrease ? '+' : '-'}${adjustment['qty'] ?? '0'}',
                        style: TextStyle(
                          color: quantityColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onTap: openDetails,
                    ),
                    DataCell(
                      Text(DateFormatter.formatDate(createdAt)),
                      onTap: openDetails,
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
