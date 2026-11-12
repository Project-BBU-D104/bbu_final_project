import 'package:flutter/material.dart';
import 'package:frontend/controllers/purchase/purchase_controller.dart';
import 'package:get/get.dart';

class PurchaseCardWidget extends StatelessWidget {
  const PurchaseCardWidget({super.key, required this.purchase});
  final Map<String, dynamic> purchase;
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
                  info('Status', purchase['status']?.toString() ?? '-'),
                  info('Total', '\$${purchase['total_amount'] ?? '0'}'),
                  info('Paid', '\$${purchase['paid_amount'] ?? '0'}'),
                  info('Due', '\$${purchase['due_amount'] ?? '0'}'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
