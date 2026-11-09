import 'package:flutter/material.dart';
import 'package:frontend/screen/home/widget/home_tab_layout.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class TopProudctWidget extends StatelessWidget {
  const TopProudctWidget({super.key, required this.products});
  final List<Map<String, dynamic>> products;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final money = NumberFormat('#,##0.00');
    return HomeSectionCard(
      title: 'Top Products',
      child: products.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Text('No sales yet'.tr, textAlign: TextAlign.center),
            )
          : Column(
              children: [
                for (var i = 0; i < products.length; i++) ...[
                  if (i > 0) const Divider(height: 32),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: theme.colorScheme.primary.withValues(
                          alpha: 0.12,
                        ),
                        child: Text(
                          '${i + 1}',
                          style: TextStyle(color: theme.colorScheme.primary),
                        ),
                      ),
                      const SizedBox(width: 16),
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
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 16,
                              runSpacing: 8,
                              children: [
                                Text(
                                  '${'Sold'.tr}: ${products[i]['total_sold'] ?? 0}',
                                ),
                                Text(
                                  '${'Revenue'.tr}: ${money.format(num.tryParse(products[i]['total_revenue']?.toString() ?? '') ?? 0)}',
                                ),
                                Text(
                                  '${'ID'.tr}: ${products[i]['product_id'] ?? '-'}',
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
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
