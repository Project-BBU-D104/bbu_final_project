import 'package:frontend/widget/app_cached_image.dart';
import 'package:flutter/material.dart';
import 'package:frontend/ui/app_list_card.dart';
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
    return Semantics(
      button: true,
      excludeSemantics: true,
      onTap: onTap,
      label: 'Add @name, quantity @quantity'.trParams({
        'name': product['name']?.toString() ?? '',
        'quantity': '$quantity',
      }),
      child: AppListCard(
        margin: EdgeInsets.zero,
        onTap: onTap,
        child: LayoutBuilder(
          builder: (context, bounds) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (bounds.hasBoundedHeight)
                Expanded(
                  child: AppCachedImage(
                    url: photo,
                    fit: BoxFit.contain,
                    fallbackIcon: Icons.inventory_2_outlined,
                  ),
                )
              else
                AspectRatio(
                  aspectRatio: 1,
                  child: AppCachedImage(
                    url: photo,
                    fit: BoxFit.contain,
                    fallbackIcon: Icons.inventory_2_outlined,
                  ),
                ),
              Text(
                product['name']?.toString() ?? '',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                CurrencyFormatter.format(
                  double.tryParse(product['sale_price']?.toString() ?? '') ?? 0,
                  currency,
                ),
              ),
              if ((double.tryParse(product['qty']?.toString() ?? '') ?? 0) <= 0)
                Text('Sold out'.tr),
              Text('Quantity: @quantity'.trParams({'quantity': '$quantity'})),
            ],
          ),
        ),
      ),
    );
  }
}
