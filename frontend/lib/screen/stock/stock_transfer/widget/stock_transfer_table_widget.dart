import 'package:flutter/material.dart';
import 'package:frontend/controllers/product_transfer_controller.dart';
import 'package:frontend/utils/date_formatter.dart';
import 'package:get/get.dart';

class StockTransferTableWidget extends StatelessWidget {
  final List<Map<String, dynamic>> stockTransfers;

  const StockTransferTableWidget({super.key, required this.stockTransfers});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = Get.find<ProductTransferController>();

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
                DataColumn(label: Text('From warehouse')),
                DataColumn(label: Text('To warehouse')),
                DataColumn(label: Text('Quantity'), numeric: true),
                DataColumn(label: Text('Date')),
              ],
              rows: stockTransfers.map((transfer) {
                final product = transfer['product'] is Map
                    ? Map<String, dynamic>.from(transfer['product'] as Map)
                    : <String, dynamic>{};
                final fromWarehouse = transfer['from_warehouse'] is Map
                    ? Map<String, dynamic>.from(
                        transfer['from_warehouse'] as Map,
                      )
                    : <String, dynamic>{};
                final toWarehouse = transfer['to_warehouse'] is Map
                    ? Map<String, dynamic>.from(transfer['to_warehouse'] as Map)
                    : <String, dynamic>{};
                final openDetails = () =>
                    controller.gotoStockTransferDetail(transfer);
                final createdAt = DateTime.tryParse(
                  transfer['created_at']?.toString() ?? '',
                );

                return DataRow(
                  cells: [
                    DataCell(
                      SizedBox(
                        width: 130,
                        child: Text(
                          transfer['reference_no']?.toString() ?? '-',
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
                          fromWarehouse['name']?.toString() ?? '-',
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
                          toWarehouse['name']?.toString() ?? '-',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      onTap: openDetails,
                    ),
                    DataCell(
                      Text(transfer['qty']?.toString() ?? '0'),
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
