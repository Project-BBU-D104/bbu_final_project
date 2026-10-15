import 'package:flutter/material.dart';
import 'package:frontend/controllers/warehouse_stock_controller.dart';
import 'package:get/get.dart';

class WarehouseStockTableWidget extends StatelessWidget {
  final List<Map<String, dynamic>> warehouseStocks;

  const WarehouseStockTableWidget({super.key, required this.warehouseStocks});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = Get.find<WarehouseStockController>();

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
                DataColumn(label: Text('Product')),
                DataColumn(label: Text('Warehouse')),
                DataColumn(label: Text('Category')),
                DataColumn(label: Text('Quantity'), numeric: true),
                DataColumn(label: Text('Cost Price'), numeric: true),
                DataColumn(label: Text('Sale Price'), numeric: true),
                DataColumn(label: Text('Actions')),
              ],
              rows: warehouseStocks.map((stock) {
                final product = stock['product'] is Map
                    ? Map<String, dynamic>.from(stock['product'] as Map)
                    : <String, dynamic>{};
                final warehouse = stock['warehouse'] is Map
                    ? Map<String, dynamic>.from(stock['warehouse'] as Map)
                    : <String, dynamic>{};
                final category = product['category'] is Map
                    ? Map<String, dynamic>.from(product['category'] as Map)
                    : <String, dynamic>{};
                final stockId = int.tryParse(stock['id']?.toString() ?? '');

                return DataRow(
                  cells: [
                    DataCell(
                      SizedBox(
                        width: 170,
                        child: Text(
                          product['name']?.toString() ?? '-',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    DataCell(
                      SizedBox(
                        width: 140,
                        child: Text(
                          warehouse['name']?.toString() ?? '-',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    DataCell(Text(category['name']?.toString() ?? '-')),
                    DataCell(Text(stock['qty']?.toString() ?? '-')),
                    DataCell(Text('\$${product['cost_price'] ?? '-'}')),
                    DataCell(Text('\$${product['sale_price'] ?? '-'}')),
                    DataCell(
                      PopupMenuButton<String>(
                        tooltip: 'Actions',
                        onSelected: (action) {
                          if (stockId == null) return;
                          if (action == 'edit') {
                            controller.editWarehouseStock(context, stockId);
                          } else if (action == 'delete') {
                            controller.onDeleteWarehouseStock(stockId, context);
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(value: 'edit', child: Text('Edit'.tr)),
                          PopupMenuItem(
                            value: 'delete',
                            child: Text(
                              'Delete'.tr,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
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
