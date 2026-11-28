import 'package:flutter/material.dart';
import 'package:frontend/utils/date_formatter.dart';
import 'package:frontend/utils/currency_formatter.dart';
import 'package:frontend/ui/app_tokens.dart';
import 'package:get/get.dart';

class RecentOrdersWidget extends StatelessWidget {
  const RecentOrdersWidget({
    super.key,
    required this.title,
    required this.items,
    required this.isPurchase,
    required this.loading,
    required this.hasError,
    required this.onRetry,
    required this.onViewAll,
    this.onOrderTap,
    this.openingOrderId,
  });

  final String title;
  final List<Map<String, dynamic>> items;
  final bool isPurchase;
  final bool loading;
  final bool hasError;
  final VoidCallback onRetry;
  final VoidCallback onViewAll;
  final ValueChanged<Map<String, dynamic>>? onOrderTap;
  final int? openingOrderId;

  String _amount(Map<String, dynamic> order) {
    if (isPurchase) return (order['subtotal'] ?? '').toString();
    final value = order['total_amount'] ?? order['subtotal'];
    final code = order['currency_code']?.toString();
    final symbol = order['currency_symbol']?.toString();
    final amount = double.tryParse(value?.toString() ?? '');
    if (amount == null || !amount.isFinite) return value?.toString() ?? '';
    if (code == null || code.isEmpty || symbol == null || symbol.isEmpty) {
      return value.toString();
    }
    return CurrencyFormatter.format(amount, {'code': code, 'symbol': symbol});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 16,
            children: [
              Text(
                title.tr,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: onViewAll,
                style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
                child: Text('View All'.tr),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: colors.surface,
            border: Border.all(color: theme.dividerColor),
            borderRadius: BorderRadius.circular(20),
          ),
          child: loading
              ? Padding(
                  padding: const EdgeInsets.all(40),
                  child: Center(
                    child: CircularProgressIndicator(
                      semanticsLabel: 'Loading orders'.tr,
                    ),
                  ),
                )
              : hasError
              ? Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(
                        Icons.cloud_off_outlined,
                        color: colors.onSurfaceVariant,
                        size: 32,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Unable to load orders'.tr,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: onRetry,
                        icon: const Icon(Icons.refresh),
                        label: Text('Retry'.tr),
                      ),
                    ],
                  ),
                )
              : items.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        isPurchase
                            ? Icons.local_shipping_outlined
                            : Icons.receipt_long_outlined,
                        size: 32,
                        color: colors.onSurfaceVariant,
                      ),
                      const SizedBox(height: 12),
                      Text('No Data'.tr, style: theme.textTheme.titleMedium),
                    ],
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < items.length; i++) ...[
                      if (i > 0)
                        Divider(
                          height: 1,
                          indent: 20,
                          endIndent: 20,
                          color: theme.dividerColor,
                        ),
                      Material(
                        type: MaterialType.transparency,
                        child: InkWell(
                          onTap: onOrderTap == null || openingOrderId != null
                              ? null
                              : () => onOrderTap!(items[i]),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        items[i]['invoice_no']?.toString() ??
                                            '',
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ),
                                    if (openingOrderId != null &&
                                        items[i]['sale_id']?.toString() ==
                                            openingOrderId.toString())
                                      const SizedBox(
                                        width: AppSpacing.lg,
                                        height: AppSpacing.lg,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                if (isPurchase) ...[
                                  Text(
                                    '${'Supplier'.tr}: ${items[i]['supplier_name'] ?? ''}',
                                  ),
                                  const SizedBox(height: 8),
                                ],
                                Wrap(
                                  spacing: 20,
                                  runSpacing: 8,
                                  children: [
                                    Text(
                                      '${(isPurchase ? 'Total' : 'Amount').tr}: ${_amount(items[i])}',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    if (isPurchase)
                                      Text(
                                        '${'Qty'.tr}: ${items[i]['qty'] ?? ''}',
                                      ),
                                    Text(
                                      DateFormatter.formatDate(
                                        DateTime.tryParse(
                                          items[i][isPurchase
                                                      ? 'purchase_date'
                                                      : 'sale_date']
                                                  ?.toString() ??
                                              '',
                                        ),
                                      ),
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: colors.onSurfaceVariant,
                                          ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
        ),
      ],
    );
  }
}
