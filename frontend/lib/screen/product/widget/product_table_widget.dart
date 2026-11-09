import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/controllers/product_controller.dart';
import 'package:frontend/utils/currency_formatter.dart';
import 'package:frontend/utils/date_formatter.dart';
import 'package:frontend/widget/app_cached_image.dart';
import 'package:get/get.dart';

class ProductTableWidget extends StatelessWidget {
  final Map<String, dynamic> product;

  const ProductTableWidget({super.key, required this.product});

  void _open() => Get.find<ProductController>().gotoProductDetail(product);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = product['name']?.toString() ?? '';
    final barcode = product['barcode']?.toString() ?? '';
    final createdAt = DateTime.tryParse(
      product['created_at']?.toString() ?? '',
    );
    final price = CurrencyFormatter.format(
      double.tryParse(product['sale_price']?.toString() ?? '') ?? 0,
      product['currency'] as Map<String, dynamic>?,
    );

    return Semantics(
      button: true,
      label: name,
      child: Focus(
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent &&
              (event.logicalKey == LogicalKeyboardKey.enter ||
                  event.logicalKey == LogicalKeyboardKey.numpadEnter)) {
            _open();
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: Material(
          color: theme.cardColor,
          child: InkWell(
            onTap: _open,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: theme.dividerColor)),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: AppCachedImage(
                            url: product['photo']?.toString(),
                            width: 40,
                            height: 40,
                            fallbackIcon: Icons.inventory_2_outlined,
                            fallbackIconSize: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Tooltip(
                            message: name,
                            child: Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Tooltip(
                      message: barcode.isEmpty ? '-' : barcode,
                      child: Text(
                        barcode.isEmpty ? '-' : barcode,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      price,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      createdAt == null
                          ? '-'
                          : DateFormatter.formatDate(createdAt),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
