import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/localization/en_us.dart';
import 'package:frontend/localization/km_kh.dart';

void main() {
  test('adjustment copy exists in English and Khmer', () {
    const keys = [
      'Product and warehouse',
      'Adjustment type and quantity',
      'Current and resulting stock',
      'Reference and reason',
      'Preview reverses the original movement before applying your changes.',
      'Current stock unknown',
      'Enter a whole quantity greater than zero',
      'Unable to load current stock. Please try again.',
      'Quantity exceeds available stock.',
      'Sign in again to save this adjustment.',
      'Unable to load stock adjustments. Please try again.',
      'Unable to save stock adjustment. Please try again.',
      'Unable to open stock adjustment. Please try again.',
      'Unable to delete stock adjustment. Please try again.',
      'Review stock corrections and their quantities.',
      'Stock adjustments',
      'No stock adjustments yet',
      'No matching stock adjustments',
      'Stock adjustment unavailable',
      'Please select an adjustment type',
      'Stock Change',
      'Adjusted Quantity',
      'Do you want to delete this stock adjustment?',
      'Created at',
      'Updated at',
      'Increase',
      'Decrease',
    ];
    for (final key in keys) {
      expect(enUS[key], isNotEmpty, reason: key);
      expect(kmKH[key], isNotEmpty, reason: key);
      expect(kmKH[key], matches(RegExp(r'[\u1780-\u17ff]')), reason: key);
    }
  });
}
