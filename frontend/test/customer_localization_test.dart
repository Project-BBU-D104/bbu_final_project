import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/localization/en_us.dart';
import 'package:frontend/localization/km_kh.dart';

void main() {
  test('customer copy has English and Khmer translations', () {
    for (final key in [
      'Customers',
      'Manage customer contacts.',
      'Search Customers',
      'Customer details',
      'Customer name is required',
      'No customers yet',
      'No matching customers',
      'Do you want to delete this customer?',
      'Unable to load customers. Please try again.',
      'Unable to save customer. Please try again.',
      'Unable to open customer. Please try again.',
      'Unable to delete customer. Please try again.',
      'Customer created successfully',
      'Customer updated successfully',
      'Customer deleted successfully',
      'Select Customer',
      'Please select a customer for this sale.',
      'No customers found',
    ]) {
      expect(enUS[key], isNotNull, reason: key);
      expect(kmKH[key], isNotNull, reason: key);
      expect(kmKH[key], isNot(key), reason: key);
    }
  });
}