import 'package:intl/intl.dart';

class CurrencyFormatter {
  static String format(
    double amount,
    Map<String, dynamic>? currency,
  ) {
    if (currency == null) {
      return amount.toStringAsFixed(2);
    }

    final String symbol = currency['symbol'] ?? '';
    // `code` is the ISO code ("KHR"); `name` is the display name. Some payloads
    // (CurrencySimple) only send `name`.
    final String code = (currency['code'] ?? currency['name'] ?? '').toString();

    final int decimalDigits =
        code.toUpperCase() == 'KHR' ? 0 : 2;

    return NumberFormat.currency(
      symbol: symbol,
      decimalDigits: decimalDigits,
    ).format(amount);
  }
}