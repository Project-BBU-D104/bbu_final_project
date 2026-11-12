import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:frontend/controllers/purchase/purchase_controller.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';

class PurchaseTableWidget extends StatelessWidget {
  final List<Map<String, dynamic>> purchases;

  const PurchaseTableWidget({super.key, required this.purchases});

  String _amount(dynamic value) => NumberFormat.currency(
    symbol: '\$',
    decimalDigits: 2,
  ).format(double.tryParse(value?.toString() ?? '0') ?? 0);

  String _statusLabel(dynamic raw) {
    final status = (raw ?? '').toString().trim();
    if (status.isEmpty) return '-';
    switch (status.toLowerCase()) {
      case 'paid':
        return 'Paid'.tr;
      case 'partial':
        return 'Partial'.tr;
      case 'unpaid':
        return 'Unpaid'.tr;
      default:
        return status[0].toUpperCase() + status.substring(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final line = colors.onSurface.withValues(alpha: 0.08);
    final controller = Get.find<PurchaseController>();
    Widget heading(String label) => Flexible(
      child: Text(label.tr, maxLines: 1, overflow: TextOverflow.ellipsis),
    );
    Widget cell(String text) => Tooltip(
      message: text,
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodyMedium,
      ),
    );

    return Card(
      elevation: 0,
      color: theme.cardColor,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: line),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: math.max(960, constraints.maxWidth),
            child: Theme(
              data: theme.copyWith(
                dividerColor: line,
                dividerTheme: DividerThemeData(color: line, thickness: 1),
              ),
              child: DataTable(
                showCheckboxColumn: false,
                headingRowHeight: 48,
                dataRowMinHeight: 56,
                dataRowMaxHeight: 72,
                columnSpacing: 20,
                horizontalMargin: 24,
                headingRowColor: WidgetStatePropertyAll(
                  Color.alphaBlend(
                    colors.onSurface.withValues(alpha: 0.025),
                    theme.cardColor,
                  ),
                ),
                headingTextStyle: theme.textTheme.labelMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
                columns: [
                  DataColumn(label: heading('Invoice')),
                  DataColumn(label: heading('Supplier')),
                  DataColumn(label: heading('Date')),
                  DataColumn(label: heading('Status')),
                  DataColumn(label: heading('Total'), numeric: true),
                  DataColumn(label: heading('Paid'), numeric: true),
                  DataColumn(label: heading('Due'), numeric: true),
                ],
                rows: [
                  for (final purchase in purchases)
                    if (purchase['id'] is int) _row(controller, purchase, cell),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  DataRow _row(
    PurchaseController controller,
    Map<String, dynamic> purchase,
    Widget Function(String) cell,
  ) {
    final supplier = purchase['supplier'] is Map
        ? purchase['supplier']['name']?.toString()
        : null;
    return DataRow(
      onSelectChanged: (_) => controller.gotoPurchaseDetail(purchase),
      cells: [
        DataCell(
          Text(
            purchase['invoice_no']?.toString() ?? '-',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        DataCell(cell(supplier ?? '-')),
        DataCell(
          cell(purchase['purchase_date']?.toString().split('T').first ?? '-'),
        ),
        DataCell(
          cell(_statusLabel(purchase['payment_status'] ?? purchase['status'])),
        ),
        DataCell(cell(_amount(purchase['total_amount']))),
        DataCell(cell(_amount(purchase['paid_amount']))),
        DataCell(cell(_amount(purchase['due_amount']))),
      ],
    );
  }
}
