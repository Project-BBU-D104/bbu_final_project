import 'package:flutter/material.dart';
import 'package:frontend/controllers/purchase/purchase_controller.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';

class PurchaseCardWidget extends StatelessWidget {
  const PurchaseCardWidget({super.key, required this.purchase});
  final Map<String, dynamic> purchase;

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
    final supplier = purchase['supplier'] is Map
        ? purchase['supplier']['name']?.toString()
        : null;
    Widget info(String label, String value) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label.tr,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
    return Card(
      color: theme.cardColor,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.dividerColor),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () =>
            Get.find<PurchaseController>().gotoPurchaseDetail(purchase),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      purchase['invoice_no']?.toString() ?? '-',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
              const SizedBox(height: 8),
              Text(supplier ?? '-', style: theme.textTheme.bodyMedium),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Divider(height: 1),
              ),
              Wrap(
                spacing: 24,
                runSpacing: 16,
                children: [
                  info(
                    'Date',
                    purchase['purchase_date']?.toString().split('T').first ??
                        '-',
                  ),
                  info(
                    'Status',
                    _statusLabel(
                      purchase['payment_status'] ?? purchase['status'],
                    ),
                  ),
                  info('Total', _amount(purchase['total_amount'])),
                  info('Paid', _amount(purchase['paid_amount'])),
                  info('Due', _amount(purchase['due_amount'])),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
