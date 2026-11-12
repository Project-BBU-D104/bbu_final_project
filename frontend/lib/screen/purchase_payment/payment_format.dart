import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';

String paymentAmountText(Map<String, dynamic> payment) {
  final currency = payment['currency'];
  final symbol = currency is Map ? (currency['symbol'] ?? '') : '';
  final amount = double.tryParse(payment['amount']?.toString() ?? '') ?? 0;
  return NumberFormat.currency(
    symbol: symbol.toString(),
    decimalDigits: 2,
  ).format(amount);
}

String paymentStatusLabel(String? raw) {
  final status = (raw ?? '').toString().trim();
  if (status.isEmpty) return '-';
  final label = status[0].toUpperCase() + status.substring(1).toLowerCase();
  return label.tr;
}

Color paymentStatusColor(BuildContext context, String? raw) {
  switch ((raw ?? '').toString().trim().toLowerCase()) {
    case 'completed':
      return Colors.green;
    case 'pending':
      return Colors.orange;
    case 'failed':
    case 'cancelled':
      return Theme.of(context).colorScheme.error;
    default:
      return Theme.of(context).colorScheme.onSurfaceVariant;
  }
}

String paymentDateText(dynamic raw) {
  if (raw == null) return '-';
  final date = DateTime.tryParse(raw.toString());
  if (date == null) return '-';
  return DateFormat('dd MMM yyyy').format(date);
}
