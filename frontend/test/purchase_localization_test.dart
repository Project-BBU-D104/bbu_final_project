import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/localization/en_us.dart';
import 'package:frontend/localization/km_kh.dart';

const purchaseKeys = [
  'Manage purchases.',
  'No purchases yet',
  'No matching purchases',
  'Add Purchase',
  'Edit Purchase',
  'Purchase Detail',
  'Purchase details',
  'Invoice Number',
  'Invoice number is required',
  'Purchase Date',
  'Purchase Items',
  'Add Item',
  'Payment details',
  'Subtotal',
  'Tax',
  'Discount',
  'Total',
  'Paid',
  'Partial',
  'Unpaid',
  'Due',
  'Please select a warehouse',
  'Please select a supplier',
  'Select a product',
  'Enter a quantity greater than zero',
  'Enter a cost greater than zero',
  'Choose a product, quantity and cost for each item',
  'Unable to load purchases. Please try again.',
  'Unable to save purchase. Please try again.',
  'Unable to open purchase. Please try again.',
  'Unable to delete purchase. Please try again.',
  'Do you want to delete this purchase?',
  'Purchase created successfully',
  'Purchase updated successfully',
  'Purchase deleted successfully',
  'No items in this purchase',
  'No purchase data found',
  'Created By',
  'Items',
];

void main() {
  test('purchase copy exists in English and Khmer', () {
    for (final key in purchaseKeys) {
      expect(enUS[key], isNotNull, reason: key);
      expect(kmKH[key], isNotNull, reason: key);
      expect(kmKH[key], isNot(key), reason: key);
    }
  });
}
