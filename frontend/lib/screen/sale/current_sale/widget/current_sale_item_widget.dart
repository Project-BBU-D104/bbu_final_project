import 'package:frontend/ui/app_list_card.dart';
import 'package:frontend/ui/app_tokens.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:frontend/utils/currency_formatter.dart';

class CurrentSaleItemWidget extends StatelessWidget {
  final String warehouseName;
  final String productName;
  final String imageUrl;
  final int quantity;
  final double unitPrice;
  final double subtotal;
  final Map<String, dynamic>? currency;
  final VoidCallback? onIncrease;
  final VoidCallback onDecrease;

  const CurrentSaleItemWidget({
    required this.warehouseName,
    required this.productName,
    required this.imageUrl,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
    this.currency,
    required this.onIncrease,
    required this.onDecrease,
    super.key,
    this.enabled = true,
  });

  final bool enabled;
  @override
  Widget build(BuildContext context) => AppListCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(productName),
        Text(warehouseName),
        Text(CurrencyFormatter.format(subtotal, currency)),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: AppSpacing.sm,
          children: [
            IconButton(
              tooltip: 'Decrease quantity'.tr,
              onPressed: enabled ? onDecrease : null,
              icon: const Icon(Icons.remove),
            ),
            Text('$quantity'),
            IconButton(
              tooltip: 'Increase quantity'.tr,
              onPressed: enabled ? onIncrease : null,
              icon: const Icon(Icons.add),
            ),
          ],
        ),
      ],
    ),
  );
}
