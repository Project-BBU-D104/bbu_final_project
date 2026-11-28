/// Calculates sale totals in minor units without binary floating-point rounding.
class SaleCurrencyCalculator {
  const SaleCurrencyCalculator._();

  static int decimalPlaces(Map<String, dynamic> currency) =>
      currency['code']?.toString().toUpperCase() == 'KHR' ? 0 : 2;

  static BigInt? convertedLineMinor({
    required Object? price,
    required int quantity,
    required Map<String, dynamic>? source,
    required Map<String, dynamic>? target,
  }) {
    if (source == null || target == null || quantity <= 0) return null;
    final amount = _Fraction.parse(price);
    final sourceRate = _Fraction.parse(source['exchange_rate']);
    final targetRate = _Fraction.parse(target['exchange_rate']);
    if (amount == null ||
        amount.numerator < BigInt.zero ||
        sourceRate == null ||
        sourceRate.numerator <= BigInt.zero ||
        targetRate == null ||
        targetRate.numerator <= BigInt.zero) {
      return null;
    }
    final numerator =
        amount.numerator *
        BigInt.from(quantity) *
        targetRate.numerator *
        sourceRate.denominator *
        BigInt.from(10).pow(decimalPlaces(target));
    final denominator =
        amount.denominator * targetRate.denominator * sourceRate.numerator;
    final rounded =
        (numerator * BigInt.two + denominator) ~/ (denominator * BigInt.two);
    if (amount.numerator > BigInt.zero && rounded == BigInt.zero) return null;
    return rounded;
  }

  static String formatMinor(BigInt value, int decimalPlaces) {
    if (decimalPlaces == 0) return value.toString();
    final digits = value.toString().padLeft(decimalPlaces + 1, '0');
    return '${digits.substring(0, digits.length - decimalPlaces)}.${digits.substring(digits.length - decimalPlaces)}';
  }
}

class _Fraction {
  const _Fraction(this.numerator, this.denominator);
  final BigInt numerator;
  final BigInt denominator;

  static _Fraction? parse(Object? value) {
    final match = RegExp(
      r'^([+-]?)(\d+)(?:\.(\d+))?(?:[eE]([+-]?\d+))?$',
    ).firstMatch(value?.toString().trim() ?? '');
    if (match == null) return null;
    final fraction = match[3] ?? '';
    final exponent = int.tryParse(match[4] ?? '0');
    if (exponent == null || exponent.abs() > 18 || fraction.length > 18) {
      return null;
    }
    var numerator = BigInt.parse('${match[2]}$fraction');
    if (match[1] == '-') numerator = -numerator;
    final scale = fraction.length - exponent;
    return scale >= 0
        ? _Fraction(numerator, BigInt.from(10).pow(scale))
        : _Fraction(numerator * BigInt.from(10).pow(-scale), BigInt.one);
  }
}
