import 'package:flutter/material.dart';
import 'package:frontend/ui/app_tokens.dart';
import 'package:frontend/utils/currency_formatter.dart';
import 'package:get/get.dart';

class SummaryOrderWidget extends StatelessWidget {
  const SummaryOrderWidget({super.key, required this.subtotal, this.currency});
  final double subtotal;
  final Map<String, dynamic>? currency;
  @override
  Widget build(BuildContext context) => Card(
    color: Theme.of(context).cardColor,
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Order Summary'.tr),
          Text(CurrencyFormatter.format(subtotal, currency)),
        ],
      ),
    ),
  );
}
