import 'package:flutter/material.dart';
import 'package:frontend/screen/purchase_payment/payment_format.dart';
import 'package:frontend/screen/purchase_payment/widget/purchase_payment_detail_widget.dart';
import 'package:frontend/widget/record_actions_menu.dart';
import 'package:get/get.dart';

class PurchasePaymentCardWidget extends StatelessWidget {
  final Map<String, dynamic> payment;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const PurchasePaymentCardWidget({
    super.key,
    required this.payment,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final purchase = payment['purchase'];
    final supplier = payment['supplier'];
    final paymentType = payment['payment_type'];
    final status = payment['status']?.toString();
    final statusColor = paymentStatusColor(context, status);

    final supplierName = supplier is Map
        ? (supplier['name'] ?? '-').toString()
        : '-';
    final invoiceNo = purchase is Map
        ? (purchase['invoice_no'] ?? '-').toString()
        : '-';
    final paymentTypeName = paymentType is Map
        ? (paymentType['name'] ?? '-').toString()
        : '-';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: theme.cardColor,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.dividerColor),
      ),
      child: InkWell(
        onTap: () =>
            Get.to(() => PurchasePaymentDetailWidget(payment: payment)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.payments_outlined,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          payment['payment_no']?.toString() ?? '-',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          supplierName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        paymentStatusLabel(status),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ),
                  RecordActionsMenu(onEdit: onEdit, onDelete: onDelete),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 10,
                children: [
                  SizedBox(
                    width: 160,
                    child: _Info(
                      icon: Icons.receipt_long_outlined,
                      label: 'Invoice'.tr,
                      value: invoiceNo,
                    ),
                  ),
                  SizedBox(
                    width: 160,
                    child: _Info(
                      icon: Icons.account_balance_wallet_outlined,
                      label: 'Payment Type'.tr,
                      value: paymentTypeName,
                    ),
                  ),
                  SizedBox(
                    width: 160,
                    child: _Info(
                      icon: Icons.calendar_today_outlined,
                      label: 'Date'.tr,
                      value: paymentDateText(payment['payment_date']),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Amount'.tr,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      paymentAmountText(payment),
                      textAlign: TextAlign.end,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Info extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _Info({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 17, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 7),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
