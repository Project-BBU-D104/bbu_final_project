import 'package:flutter/material.dart';
import 'package:frontend/utils/currency_formatter.dart';

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
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.cardColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.dividerColor, width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Product Image
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: imageUrl.isEmpty
                  ? const Icon(Icons.inventory_2_outlined)
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.inventory_2_outlined),
                      ),
                    ),
            ),

            const SizedBox(width: 16),

            /// Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    productName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      IconButton(
                        tooltip: 'Decrease quantity',
                        onPressed: onDecrease,
                        icon: const Icon(Icons.remove_circle_outline),
                        visualDensity: VisualDensity.compact,
                      ),
                      Text(
                        '$quantity x ${CurrencyFormatter.format(unitPrice, currency)}',
                      ),
                      IconButton(
                        tooltip: 'Increase quantity',
                        onPressed: onIncrease,
                        icon: const Icon(Icons.add_circle_outline),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 16),

            /// Price Section
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  CurrencyFormatter.format(subtotal, currency),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
