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
                columnSpacing: 24,
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
                    DataColumn(label: Text(label.tr)),
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
                            Text(payment['payment_no']?.toString() ?? '-'),
                          ),
                          DataCell(
                            Text(
                              payment['supplier'] is Map
                                  ? (payment['supplier']['name'] ?? '-')
                                        .toString()
                                  : '-',
                            ),
                          ),
                          DataCell(
                            Text(
                              payment['purchase'] is Map
                                  ? (payment['purchase']['invoice_no'] ?? '-')
                                        .toString()
                                  : '-',
                            ),
                          ),
                          DataCell(
                            Text(
                              payment['payment_type'] is Map
                                  ? (payment['payment_type']['name'] ?? '-')
                                        .toString()
                                  : '-',
                            ),
                          ),
                          DataCell(
                            Text(paymentDateText(payment['payment_date'])),
                          ),
                          DataCell(Text(paymentAmountText(payment))),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: paymentStatusColor(
                                  context,
                                  payment['status']?.toString(),
                                ).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                paymentStatusLabel(
                                  payment['status']?.toString(),
                                ),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: paymentStatusColor(
                                    context,
                                    payment['status']?.toString(),
                                  ),
                                ),
                              ),
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
