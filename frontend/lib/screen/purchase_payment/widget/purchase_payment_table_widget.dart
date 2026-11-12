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
    Widget cell(String text, {bool bold = false}) => Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: theme.textTheme.bodyMedium?.copyWith(
        fontWeight: bold ? FontWeight.w600 : null,
      ),
    );
    final colors = theme.colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      color: theme.cardColor,
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: math.max(960, constraints.maxWidth),
              child: DataTable(
                showCheckboxColumn: false,
                dividerThickness: 0,
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
                    DataColumn(
                      label: heading(label),
                      numeric: label == 'Amount',
                    ),
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
                            cell(
                              payment['payment_no']?.toString() ?? '-',
                              bold: true,
                            ),
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
                              tooltip: 'Actions'.tr,
                              icon: const Icon(Icons.more_horiz, size: 20),
                              onSelected: (value) {
                                if (value == 'edit') onEdit?.call(payment);
                                if (value == 'delete') onDelete?.call(payment);
                              },
                              itemBuilder: (_) => [
                                PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      const Icon(Icons.edit_outlined, size: 18),
                                      const SizedBox(width: 12),
                                      Text('Edit'.tr),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.delete_outline,
                                        size: 18,
                                        color: theme.colorScheme.error,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Delete'.tr,
                                        style: TextStyle(
                                          color: theme.colorScheme.error,
                                        ),
                                      ),
                                    ],
                                  ),
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
