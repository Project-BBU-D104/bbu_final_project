import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/localization/en_us.dart';
import 'package:frontend/localization/km_kh.dart';

void main() {
  test('warehouse stock copy exists in English and Khmer', () {
    for (final key in [
      "Products and quantities",
      "Enter a whole quantity of zero or more",
      "Select each product only once",
      "Add at least one product",
      "Unable to load warehouse stock. Please try again.",
      "Unable to save warehouse stock. Please try again.",
      "Unable to open warehouse stock. Please try again.",
      "Unable to delete warehouse stock. Please try again.",
      "Unable to load stock options. Please try again.",
      "Manage products and quantities by warehouse.",
      "No warehouse stock yet",
      "No matching warehouse stock",
      "Loading warehouse stock",
      "Warehouse stock unavailable",
      "Remove product",
      "Add product",
      "Clear search",
      "Unavailable",
      "Please select a warehouse",
      "Select a product",
      "Close",
      "Search",
    ]) {
      expect(enUS[key], isNotEmpty, reason: key);
      expect(kmKH[key], isNotEmpty, reason: key);
      expect(kmKH[key], isNot(contains('?')), reason: key);
      expect(
        RegExp(r'[\u1780-\u17ff]').hasMatch(kmKH[key]!),
        isTrue,
        reason: key,
      );
    }
  });
}
