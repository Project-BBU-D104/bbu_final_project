import 'package:flutter/material.dart';
import 'package:frontend/ui/app_section_card.dart';
import 'package:frontend/utils/currency_formatter.dart';

class SummaryOrderWidget extends StatelessWidget {
  const SummaryOrderWidget({super.key, required this.subtotal, this.currency});
  final double subtotal;
  final Map<String, dynamic>? currency;
  @override
  Widget build(BuildContext context) => AppSectionCard(
    title: 'Order Summary',
    child: Text(CurrencyFormatter.format(subtotal, currency)),
  );
}
