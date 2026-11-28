import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:frontend/ui/app_status_badge.dart';
import 'package:frontend/utils/currency_formatter.dart';

Map<String, dynamic> saleMap(Object? value) => value is Map
    ? Map<String, dynamic>.fromEntries(
        value.entries
            .where((e) => e.key is String)
            .map((e) => MapEntry(e.key as String, e.value)),
      )
    : {};
String saleText(Object? value, {String fallback = '—'}) =>
    value == null || value.toString().trim().isEmpty
    ? fallback
    : value.toString();
Map<String, dynamic>? saleCurrency(Map<String, dynamic> sale) {
  final code = sale['currency_code']?.toString();
  final symbol = sale['currency_symbol']?.toString();
  if (code == null || code.isEmpty || symbol == null) return null;
  return {'code': code, 'symbol': symbol};
}

String formatSaleAmount(Object? value, {Map<String, dynamic>? currency}) {
  final amount = double.tryParse(value.toString());
  if (amount == null || !amount.isFinite) return '—';
  return currency == null
      ? '\$${amount.toStringAsFixed(2)}'
      : CurrencyFormatter.format(amount, currency);
}

String formatSaleDate(Object? value) {
  final date = DateTime.tryParse(value.toString());
  return date == null ? '—' : DateFormat('yyyy-MM-dd').format(date.toLocal());
}

String normalizeSalePaymentStatus(Object? value) =>
    value?.toString().trim().toLowerCase() ?? '';
String salePaymentStatusLabel(Object? value) =>
    switch (normalizeSalePaymentStatus(value)) {
      'paid' => 'Paid'.tr,
      'partial' => 'Partial'.tr,
      'unpaid' => 'Unpaid'.tr,
      _ => saleText(value),
    };
AppStatusTone salePaymentStatusTone(Object? value) =>
    switch (normalizeSalePaymentStatus(value)) {
      'paid' => AppStatusTone.success,
      'partial' => AppStatusTone.warning,
      'unpaid' => AppStatusTone.error,
      _ => AppStatusTone.neutral,
    };
