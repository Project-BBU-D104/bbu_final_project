import 'package:frontend/ui/app_list_card.dart';
import 'package:frontend/ui/app_tokens.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:frontend/utils/currency_formatter.dart';
import 'package:frontend/widget/app_cached_image.dart';

class CurrentSaleItemWidget extends StatelessWidget {
  final String productName;
  final String imageUrl;
  final int quantity;
  final double unitPrice;
  final double subtotal;
  final Map<String, dynamic>? currency;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  const CurrentSaleItemWidget({
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
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppTokens.radiusControl),
          child: AppCachedImage(
            url: imageUrl,
            width: AppTokens.saleProductThumbnailSize,
            height: AppTokens.saleProductThumbnailSize,
            fit: BoxFit.cover,
            fallbackIcon: Icons.inventory_2_outlined,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: Text(productName)),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      CurrencyFormatter.format(subtotal, currency),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
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
        ),
      ],
    ),
  );
}
