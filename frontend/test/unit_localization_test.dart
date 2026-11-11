import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/localization/en_us.dart';
import 'package:frontend/localization/km_kh.dart';

void main() {
  test('unit copy has English and Khmer translations', () {
    for (final key in [
      'Units',
      'Manage product units.',
      'Search Units',
      'Add Unit',
      'Edit Unit',
      'Unit details',
      'Unit Name',
      'Enter Unit Name',
      'Short Name',
      'Enter Short Name',
      'Unit name is required',
      'Short name is required',
      'No units yet',
      'No matching units',
      'Do you want to delete this unit?',
      'Unable to load units. Please try again.',
      'Unable to save unit. Please try again.',
      'Unable to open unit. Please try again.',
      'Unable to delete unit. Please try again.',
      'Unit created successfully',
      'Unit updated successfully',
      'Unit deleted successfully',
    ]) {
      expect(enUS[key], isNotNull, reason: key);
      expect(kmKH[key], isNotNull, reason: key);
      expect(kmKH[key], isNot(key), reason: key);
    }
  });
}
