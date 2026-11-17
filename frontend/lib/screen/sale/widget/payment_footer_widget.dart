import 'package:flutter/material.dart';
import 'package:frontend/utils/currency_formatter.dart';
import 'package:get/get.dart';

class PaymentFooterWidget extends StatelessWidget {
  const PaymentFooterWidget({
    super.key,
    required this.onTap,
    required this.itemCount,
    required this.total,
    this.currency,
  });
  final VoidCallback onTap;
  final int itemCount;
  final double total;
  final Map<String, dynamic>? currency;
  @override
  Widget build(BuildContext context) => SafeArea(
    child: FilledButton(
      onPressed: onTap,
      child: Text(
        'Continue · @quantity · @total'.trParams({
          'quantity': '$itemCount',
          'total': CurrencyFormatter.format(total, currency),
        }),
      ),
    ),
  );
}
