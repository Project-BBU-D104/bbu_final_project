import 'package:flutter/material.dart';
import 'package:frontend/screen/sale/sale_presentation.dart';
import 'package:frontend/ui/app_list_card.dart';
import 'package:frontend/ui/app_tokens.dart';
import 'package:get/get.dart';

class PaymentCardListWidget extends StatelessWidget {
  const PaymentCardListWidget({
    super.key,
    required this.payment,
    this.onEdit,
    this.onDelete,
  });
  final Map<String, dynamic> payment;
  final VoidCallback? onEdit, onDelete;
  @override
  Widget build(BuildContext context) {
    final sale = saleMap(payment['sale']);
    final textTheme = Theme.of(context).textTheme;
    return AppListCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(saleText(sale['invoice_no']), style: textTheme.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(saleText(saleMap(sale['customer'])['name'])),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.xl,
            runSpacing: AppSpacing.sm,
            children: [
              _PaymentField(
                label: 'Method',
                value: saleText(payment['payment_method']),
              ),
              _PaymentField(
                label: 'Date',
                value: formatSaleDate(payment['payment_date']),
              ),
              _PaymentField(
                label: 'Reference',
                value: saleText(payment['reference_no']),
              ),
            ],
          ),
          const Divider(height: AppSpacing.xxl),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.sm,
            children: [
              _PaymentField(
                label: 'Amount',
                value: formatSaleAmount(payment['amount']),
                valueStyle: textTheme.titleMedium,
              ),
              Wrap(
                spacing: AppSpacing.sm,
                children: [
                  IconButton.outlined(
                    tooltip: 'Edit'.tr,
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined),
                  ),
                  IconButton.outlined(
                    tooltip: 'Delete'.tr,
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PaymentField extends StatelessWidget {
  const _PaymentField({
    required this.label,
    required this.value,
    this.valueStyle,
  });

  final String label;
  final String value;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label.tr, style: Theme.of(context).textTheme.bodySmall),
      const SizedBox(height: AppSpacing.xs),
      Text(value, style: valueStyle),
    ],
  );
}
