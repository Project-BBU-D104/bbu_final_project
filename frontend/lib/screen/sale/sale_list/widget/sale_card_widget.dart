import 'package:flutter/material.dart';
import 'package:frontend/controllers/sale/sale_list_controller.dart';
import 'package:frontend/screen/sale/sale_presentation.dart';
import 'package:frontend/ui/app_list_card.dart';
import 'package:frontend/ui/app_status_badge.dart';
import 'package:frontend/ui/app_tokens.dart';
import 'package:get/get.dart';

class SaleCardWidget extends StatelessWidget {
  const SaleCardWidget({super.key, required this.sale, this.onTap});
  final Map<String, dynamic> sale;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return AppListCard(
      onTap:
          onTap ??
          () => Get.find<SaleListController>().gotoSaleListDetail(sale),
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
              const SizedBox(width: AppSpacing.sm),
              const Icon(Icons.chevron_right),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(saleText(saleMap(sale['customer'])['name'])),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                formatSaleDate(sale['sale_date']),
                style: textTheme.bodySmall,
              ),
              AppStatusBadge(
                label: salePaymentStatusLabel(sale['payment_status']),
                tone: salePaymentStatusTone(sale['payment_status']),
                compact: true,
              ),
            ],
          ),
          const Divider(height: AppSpacing.xxl),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.sm,
            children: [
              for (final (label, field) in [
                ('Total', 'total_amount'),
                ('Paid', 'paid_amount'),
                ('Due', 'due_amount'),
              ])
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label.tr, style: textTheme.bodySmall),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      formatSaleAmount(sale[field]),
                      style: textTheme.titleSmall,
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
