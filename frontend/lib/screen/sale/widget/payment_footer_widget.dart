import 'package:flutter/material.dart';
import 'package:frontend/ui/app_button_supporting_text.dart';
import 'package:frontend/ui/app_tokens.dart';
import 'package:frontend/utils/currency_formatter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class PaymentFooterWidget extends StatelessWidget {
  const PaymentFooterWidget({
    super.key,
    required this.onTap,
    required this.itemCount,
    required this.total,
    this.currency,
    this.usdToKhrRate,
  });
  final VoidCallback onTap;
  final int itemCount;
  final double total;
  final Map<String, dynamic>? currency;
  final double? usdToKhrRate;
  @override
  Widget build(BuildContext context) {
    final rateText = usdToKhrRate == null
        ? '—'
        : '1\$ = ${NumberFormat('#,##0.########', 'en_US').format(usdToKhrRate)}៛';
    final exchangeRate = 'Exchange rate: @rate'.trParams({'rate': rateText});
    return SafeArea(
      child: Material(
        elevation: AppTokens.saleFooterElevation,
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(AppTokens.radiusControl),
        child: SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Amount: @amount'.trParams({
                            'amount': CurrencyFormatter.format(total, currency),
                          }),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Wrap(
                          spacing: AppSpacing.lg,
                          runSpacing: AppSpacing.xs,
                          children: [
                            AppButtonSupportingText(
                              'Qty: @quantity'.trParams({
                                'quantity': '$itemCount',
                              }),
                            ),
                            AppButtonSupportingText(exchangeRate),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  const Icon(Icons.arrow_forward_rounded),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
