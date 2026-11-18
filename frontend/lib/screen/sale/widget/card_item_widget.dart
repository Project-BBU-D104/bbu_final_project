import 'package:frontend/widget/app_cached_image.dart';
import 'package:flutter/material.dart';
import 'package:frontend/ui/app_list_card.dart';
import 'package:frontend/ui/app_tokens.dart';
import 'package:frontend/utils/currency_formatter.dart';
import 'package:get/get.dart';

class CardItemWidget extends StatelessWidget {
  const CardItemWidget({
    super.key,
    required this.product,
    required this.quantity,
    this.currency,
    required this.onTap,
  });
  final Map<String, dynamic> product;
  final int quantity;
  final Map<String, dynamic>? currency;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final photo = product['photo']?.toString() ?? '';
    final price = CurrencyFormatter.format(
      double.tryParse(product['sale_price']?.toString() ?? '') ?? 0,
      currency,
    );
    final soldOut =
        (double.tryParse(product['qty']?.toString() ?? '') ?? 0) <= 0;
    return Semantics(
      button: true,
      excludeSemantics: true,
      onTap: onTap,
      value: [price, if (soldOut) 'Sold out'.tr].join(', '),
      label: 'Add @name, quantity @quantity'.trParams({
        'name': product['name']?.toString() ?? '',
        'quantity': '$quantity',
      }),
      child: AppListCard(
        margin: EdgeInsets.zero,
        onTap: onTap,
        child: LayoutBuilder(
          builder: (context, bounds) {
            final grid = bounds.hasBoundedHeight;
            final image = AppCachedImage(
              url: photo,
              fit: BoxFit.contain,
              fallbackIcon: Icons.inventory_2_outlined,
            );
            final details = [
              Text(
                product['name']?.toString() ?? '',
                maxLines: grid ? 2 : null,
                overflow: grid ? TextOverflow.ellipsis : null,
              ),
              Text(price),
              if (soldOut) Text('Sold out'.tr),
              Text('Quantity: @quantity'.trParams({'quantity': '$quantity'})),
            ];
            if (grid) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: image),
                  ...details,
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox.square(
                  dimension: AppTokens.saleProductThumbnailSize,
                  child: image,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: details,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
