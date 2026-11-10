import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/localization/en_us.dart';
import 'package:frontend/localization/km_kh.dart';

void main() {
  test('category copy has English and Khmer translations', () {
    for (final key in [
      'Categories',
      'Manage product categories.',
      'Search Categories',
      'Category details',
      'Category name is required',
      'No categories yet',
      'No matching categories',
      'Try a different search or clear the filter.',
      'Do you want to delete this category?',
      'Unable to load categories. Please try again.',
      'Unable to save category. Please try again.',
      'Unable to open category. Please try again.',
      'Unable to delete category. Please try again.',
      'Category created successfully',
      'Category updated successfully',
      'Category deleted successfully',
      'Refresh',
      'Retry',
    ]) {
      expect(enUS[key], isNotNull, reason: key);
      expect(kmKH[key], isNotNull, reason: key);
      expect(kmKH[key], isNot(key), reason: key);
    }
  });
}