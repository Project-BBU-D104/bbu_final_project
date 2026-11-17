import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/screen/sale/sale_presentation.dart';
import 'package:frontend/ui/app_status_badge.dart';

void main() {
  test('decimal strings and nonfinite historical amounts render safely', () {
    expect(formatSaleAmount('12.50'), '\$12.50');
    for (final value in [null, 'bad', 'NaN', double.infinity]) {
      expect(formatSaleAmount(value), '—');
    }
    expect(saleMap(null), isEmpty);
    expect(formatSaleDate('invalid'), '—');
    expect(normalizeSalePaymentStatus(' Partial '), 'partial');
    expect(salePaymentStatusTone(' Partial '), AppStatusTone.warning);
    expect(salePaymentStatusLabel('Custom'), 'Custom');
  });
}
