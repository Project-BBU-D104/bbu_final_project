import 'package:flutter/material.dart';
import 'package:frontend/controllers/purchase/purchase_controller.dart';
import 'package:get/get.dart';

class PurchaseTableWidget extends StatelessWidget {
  final List<Map<String, dynamic>> purchases;

  const PurchaseTableWidget({super.key, required this.purchases});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = Get.find<PurchaseController>();

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
                DataColumn(label: Text('Invoice')),
                DataColumn(label: Text('Supplier')),
                DataColumn(label: Text('Date')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Total'), numeric: true),
                DataColumn(label: Text('Paid'), numeric: true),
                DataColumn(label: Text('Due'), numeric: true),
              ],
              rows: purchases.map((purchase) {
                final supplier = purchase['supplier'] is Map
                    ? Map<String, dynamic>.from(purchase['supplier'] as Map)
                    : <String, dynamic>{};
                final openDetails = () =>
                    controller.gotoPurchaseDetail(purchase);

                return DataRow(
                  cells: [
                    DataCell(
                      SizedBox(
                        width: 130,
                        child: Text(
                          purchase['invoice_no']?.toString() ?? '-',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      onTap: openDetails,
                    ),
                    DataCell(
                      SizedBox(
                        width: 160,
                        child: Text(
                          supplier['name']?.toString() ?? '-',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      onTap: openDetails,
                    ),
                    DataCell(
                      Text(purchase['purchase_date']?.toString() ?? '-'),
                      onTap: openDetails,
                    ),
                    DataCell(
                      Text(purchase['status']?.toString() ?? 'Unknown'),
                      onTap: openDetails,
                    ),
                    DataCell(
                      Text('\$${purchase['total_amount'] ?? '0'}'),
                      onTap: openDetails,
                    ),
                    DataCell(
                      Text('\$${purchase['paid_amount'] ?? '0'}'),
                      onTap: openDetails,
                    ),
                    DataCell(
                      Text('\$${purchase['due_amount'] ?? '0'}'),
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
