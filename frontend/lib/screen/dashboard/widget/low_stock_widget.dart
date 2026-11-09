import 'package:flutter/material.dart';
import 'package:frontend/screen/home/widget/home_tab_layout.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class LowStockWidget extends StatelessWidget {
  const LowStockWidget({super.key, required this.products});
  final List<Map<String, dynamic>> products;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return HomeSectionCard(
      title: 'Low Stock Products',
      child: products.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Text(
                'No low stock products'.tr,
                textAlign: TextAlign.center,
              ),
            )
          : Column(
              children: [
                for (var i = 0; i < products.length; i++) ...[
                  if (i > 0) const Divider(height: 32),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: theme.colorScheme.error,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              products[i]['product_name']?.toString() ?? '-',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${'ID'.tr}: ${products[i]['id'] ?? '-'}',
                              style: theme.textTheme.bodySmall,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${'Stock'.tr}: ${NumberFormat.decimalPattern().format(num.tryParse(products[i]['stock_quantity']?.toString() ?? '') ?? 0)}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
    );
  }
}
