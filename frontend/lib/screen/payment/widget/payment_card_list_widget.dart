import 'package:flutter/material.dart';
import 'package:frontend/screen/payment/widget/payment_actions_widget.dart';
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
          Row(
            children: [
              Expanded(
                child: Text(
                  saleText(sale['invoice_no']),
                  style: textTheme.titleMedium,
                ),
              ),
              PaymentActionsWidget(onEdit: onEdit, onDelete: onDelete),
            ],
          ),
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
          _PaymentField(
            label: 'Amount',
            value: formatSaleAmount(
              payment['amount'],
              currency: saleCurrency(saleMap(payment['sale'])),
            ),
            valueStyle: textTheme.titleMedium,
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
