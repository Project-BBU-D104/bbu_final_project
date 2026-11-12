import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/localization/en_us.dart';
import 'package:frontend/localization/km_kh.dart';

const purchasePaymentKeys = [
  'Purchase Payments',
  'Manage purchase payments.',
  'Search Purchase Payments',
  'Add Purchase Payment',
  'Edit Purchase Payment',
  'Purchase Payment Detail',
  'Payment details',
  'Payment No',
  'Select Payment Type',
  'Select Currency',
  'Amount',
  'Enter Amount',
  'Payment Date',
  'Note',
  'Enter Note',
  'Invoice',
  'Supplier',
  'Date',
  'Status',
  'Completed',
  'Failed',
  'No purchase payments yet',
  'No matching purchase payments',
  'Select Purchase',
  'No Purchase Found',
  'Please select a purchase',
  'Please select a payment type',
  'Please select a currency',
  'Enter a valid amount',
  'Amount cannot exceed purchase balance',
  'Check the payment details and purchase balance',
  'Unable to load purchase payments. Please try again.',
  'Unable to save purchase payment. Please try again.',
  'Unable to open purchase payment. Please try again.',
  'Unable to delete purchase payment. Please try again.',
  'Purchase payment created successfully',
  'Purchase payment updated successfully',
  'Purchase payment deleted successfully',
  'Do you want to delete this purchase payment?',
  'Purchase',
];

void main() {
  test('purchase payment copy exists in English and Khmer', () {
    for (final key in purchasePaymentKeys) {
      expect(enUS[key], isNotNull, reason: key);
      expect(kmKH[key], isNotNull, reason: key);
      expect(kmKH[key], isNot(key), reason: key);
    }
  });
}
