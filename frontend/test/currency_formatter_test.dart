import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/utils/currency_formatter.dart';

void main() {
  test('KHR is picked up from the ISO code and drops decimals', () {
    final khr = {'name': 'Khmer Riel', 'code': 'KHR', 'symbol': '៛'};
    expect(CurrencyFormatter.format(12000, khr), '៛12,000');
  });

  test('non-KHR keeps the configured symbol and 2 decimals', () {
    final usd = {'name': 'US Dollar', 'code': 'USD', 'symbol': '\$'};
    expect(CurrencyFormatter.format(12, usd), '\$12.00');
  });

  test('without a currency falls back to a plain amount', () {
    expect(CurrencyFormatter.format(12, null), '12.00');
  });
}
