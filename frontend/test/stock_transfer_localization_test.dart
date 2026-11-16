import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/localization/en_us.dart';
import 'package:frontend/localization/km_kh.dart';

void main() {
  test('transfer draft errors have Khmer copy', () {
    const keys = [
      'Please select a warehouse',
      'Select a product',
      'Enter a whole quantity greater than zero',
      'Choose different warehouses',
      'Add at least one product',
      'Quantity exceeds available stock.',
      'Unable to load current stock. Please try again.',
      'Unable to load stock transfers. Please try again.',
      'Unable to save stock transfer. Please try again.',
      'Unable to open stock transfer. Please try again.',
      'Unable to delete stock transfer. Please try again.',
    ];
    for (final key in keys) {
      expect(enUS[key], key, reason: key);
      expect(kmKH[key], isNotEmpty, reason: key);
      expect(kmKH[key], isNot(key), reason: key);
    }
    expect(kmKH['Choose different warehouses'], 'ជ្រើសរើសឃ្លាំងផ្សេងគ្នា');
  });
}
