import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:frontend/screen/purchase_payment/payment_format.dart';
import 'package:frontend/screen/purchase_payment/widget/purchase_payment_detail_widget.dart';
import 'package:get/get.dart';

class PurchasePaymentTableWidget extends StatelessWidget {
  final List<Map<String, dynamic>> payments;
  final void Function(Map<String, dynamic>)? onEdit;
  final void Function(Map<String, dynamic>)? onDelete;

  const PurchasePaymentTableWidget({
    super.key,
    required this.payments,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Widget heading(String label) => Flexible(
      child: Text(label.tr, maxLines: 1, overflow: TextOverflow.ellipsis),
    );
    Widget cell(String text) => Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: theme.textTheme.bodyMedium,
    );
    return Card(
      color: theme.cardColor,
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.dividerColor),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: math.max(980, constraints.maxWidth),
              child: DataTable(
                showCheckboxColumn: false,
                headingRowHeight: 48,
                dataRowMinHeight: 56,
                dataRowMaxHeight: 72,
                columnSpacing: 20,
                horizontalMargin: 24,
                columns: [
                  for (final label in const [
                    'Payment No',
                    'Supplier',
                    'Invoice',
                    'Payment Type',
                    'Date',
                    'Amount',
                    'Status',
                    'Actions',
                  ])
                    DataColumn(label: heading(label)),
                ],
                rows: [
                  for (final payment in payments)
                    if (payment['id'] is int)
                      DataRow(
                        onSelectChanged: (_) => Get.to(
                          () => PurchasePaymentDetailWidget(payment: payment),
                        ),
                        cells: [
                          DataCell(
                            cell(payment['payment_no']?.toString() ?? '-'),
                          ),
                          DataCell(
                            cell(
                              payment['supplier'] is Map
                                  ? (payment['supplier']['name'] ?? '-')
                                        .toString()
                                  : '-',
                            ),
                          ),
                          DataCell(
                            cell(
                              payment['purchase'] is Map
                                  ? (payment['purchase']['invoice_no'] ?? '-')
                                        .toString()
                                  : '-',
                            ),
                          ),
                          DataCell(
                            cell(
                              payment['payment_type'] is Map
                                  ? (payment['payment_type']['name'] ?? '-')
                                        .toString()
                                  : '-',
                            ),
                          ),
                          DataCell(
                            cell(paymentDateText(payment['payment_date'])),
                          ),
                          DataCell(cell(paymentAmountText(payment))),
                          DataCell(
                            cell(
                              paymentStatusLabel(payment['status']?.toString()),
                            ),
                          ),
                          DataCell(
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert),
                              onSelected: (value) {
                                if (value == 'edit') onEdit?.call(payment);
                                if (value == 'delete') onDelete?.call(payment);
                              },
                              itemBuilder: (_) => const [
                                PopupMenuItem(
                                  value: 'edit',
                                  child: Text('Edit'),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Delete'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
