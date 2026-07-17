import 'package:intl/intl.dart';

class CurrencyFormatter {

  static String format(
    double amount,
    String currency,
  ) {

    switch(currency.toUpperCase()) {

      case "USD":
        return NumberFormat.currency(
          locale: "en_US",
          symbol: "\$",
          decimalDigits: 2,
        ).format(amount);


      case "KHR":
        return NumberFormat.currency(
          locale: "km_KH",
          symbol: "៛",
          decimalDigits: 0,
        ).format(amount);


      case "THB":
        return NumberFormat.currency(
          locale: "th_TH",
          symbol: "฿",
          decimalDigits: 2,
        ).format(amount);


      case "EUR":
        return NumberFormat.currency(
          locale: "de_DE",
          symbol: "€",
          decimalDigits: 2,
        ).format(amount);


      default:
        return NumberFormat.currency(
          decimalDigits: 2,
          symbol: currency,
        ).format(amount);
    }
  }
}