import 'package:flutter/material.dart';
import 'package:frontend/controllers/payment_type_controller.dart';
import 'package:frontend/utils/date_formatter.dart';
import 'package:frontend/widget/status_widget.dart';
import 'package:get/get.dart';

class PaymentTypeTableWidget extends StatelessWidget {
  final List<Map<String, dynamic>> paymentTypes;

  const PaymentTypeTableWidget({super.key, required this.paymentTypes});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = Get.find<PaymentTypeController>();

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
                DataColumn(label: Text('Payment type')),
                DataColumn(label: Text('Description')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Created')),
                DataColumn(label: Text('Updated')),
                DataColumn(label: Text('Actions')),
              ],
              rows: paymentTypes.map((paymentType) {
                final paymentTypeId =
                    int.tryParse(paymentType['id']?.toString() ?? '');
                final isActive = paymentType['status'] == true;
                final createdAt = DateTime.tryParse(
                  paymentType['created_at']?.toString() ?? '',
                );
                final updatedAt = DateTime.tryParse(
                  paymentType['updated_at']?.toString() ?? '',
                );

                return DataRow(
                  cells: [
                    DataCell(
                      SizedBox(
                        width: 170,
                        child: Text(
                          paymentType['name']?.toString() ?? '-',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    DataCell(
                      SizedBox(
                        width: 240,
                        child: Text(
                          paymentType['description']?.toString() ?? '-',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    DataCell(
                      StatusWidget(
                        text: isActive ? 'Active' : 'Inactive',
                        color: isActive ? Colors.green : Colors.red,
                      ),
                    ),
                    DataCell(Text(DateFormatter.formatDateTime(createdAt))),
                    DataCell(Text(DateFormatter.formatDateTime(updatedAt))),
                    DataCell(
                      PopupMenuButton<String>(
                        tooltip: 'Actions'.tr,
                        onSelected: (action) {
                          if (paymentTypeId == null) return;
                          if (action == 'edit') {
                            controller.editPaymentType(context, paymentTypeId);
                          } else if (action == 'delete') {
                            controller.onDeletePaymentType(
                              context,
                              paymentTypeId,
                            );
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                const Icon(Icons.edit_outlined, size: 20),
                                const SizedBox(width: 10),
                                Text('Edit'.tr),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Delete'.tr,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          )
        ),
      ),
    );
  }
}
