import 'package:flutter/material.dart';
import 'package:frontend/ui/app_section_card.dart';
import 'package:frontend/ui/app_tokens.dart';
import 'package:frontend/utils/currency_formatter.dart';
import 'package:get/get.dart';

class SummaryOrderWidget extends StatelessWidget {
  const SummaryOrderWidget({
    super.key,
    required this.subtotal,
    this.itemCount,
    this.currency,
  });
  final double? subtotal;
  final int? itemCount;
  final Map<String, dynamic>? currency;
  @override
  Widget build(BuildContext context) => AppSectionCard(
    title: 'Order Summary',
    child: Column(
      children: [
        if (itemCount != null) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: Text('Total quantity'.tr)),
              const SizedBox(width: AppSpacing.md),
              Text('$itemCount'),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          const Divider(),
          const SizedBox(height: AppSpacing.sm),
        ],
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: Text('Total'.tr)),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                subtotal == null
                    ? '—'
                    : CurrencyFormatter.format(subtotal!, currency),
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
